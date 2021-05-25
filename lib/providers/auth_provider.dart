import 'dart:convert';

import '../rotas_url.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  //Dados token
  String _token;
  DateTime _expiryDate;

  //Dados usuário
  int _userId;
  String _userName;
  String _role;

  int get id {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get name {
    return _userName;
  }

  String get role {
    return _role;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('digitalAlignerData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('digitalAlignerData'))
        as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _userName = extractedUserData['userName'];
    _role = extractedUserData['role'];
    _expiryDate = expiryDate;
    //notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _role = null;
    _expiryDate = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('digitalAlignerData');
    //notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Authorization': ''
    };

    try {
      final response = await http.post(
        Uri.parse(RotasUrl.rotaLogin),
        headers: requestHeaders,
        body: {
          'identifier': email,
          'password': password,
        },
      );
      final responseData = json.decode(response.body);

      if (responseData.containsKey('error')) {
        if (responseData['message'][0]['messages'][0]['id'] ==
            'Auth.form.error.blocked') {
          return {
            'message':
                'Seu cadastro está sendo averiguado e será aprovado em até 48h.',
            'error': true
          };
        }
        if (responseData['message'][0]['messages'][0]['id'] ==
            'Auth.form.error.invalid') {
          return {
            'message': 'Usuário ou senha incorreta.',
            'error': true,
          };
        }
      }

      //Extracting user dada
      _token = responseData['jwt'];
      _expiryDate = DateTime.now().add(
        Duration(days: 1),
      );

      _userId = responseData['user']['id'];
      _userName = responseData['user']['nome'];
      _role = responseData['user']['role']['name'];

      //notifyListeners();
      //Save token in device (web or mobile)
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'userName': _userName,
        'role': _role,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('digitalAlignerData', userData);

      return {'message': 'login realizado com sucesso!'};
    } catch (error) {
      //If managed to get here, error connecting to strapi server
      print(error);
      return {
        'message': 'Erro ao se connectar com o servidor.',
        'error': true,
      };
    }
  }

  Future<dynamic> getCountryAndStateData() async {
    var _response =
        await http.get(Uri.parse(RotasUrl.rotaGetPaisesAndState), headers: {
      'Content-Type': 'application/json',
    });

    List<dynamic> localData = json.decode(_response.body);

    return localData;
  }

  List<String> mapCountriesDataToUiList(List<dynamic> local) {
    List<String> countries = [];
    for (int i = 0; i < local.length; i++) {
      countries.add(local[i]['pais']);
    }
    return countries;
  }

  List<String> mapCountryToStatesToUiList({
    List<dynamic> local,
    String selectedCountry,
  }) {
    //If no country is selected, then return default states to display
    if (selectedCountry == null) {
      List<String> states = [];
      for (int i = 0; i < local[0]['estado_brasils'].length; i++) {
        states.add(local[0]['estado_brasils'][i]['estado']);
      }
      return states;
    }

    if (selectedCountry == 'Brasil') {
      List<String> states = [];
      for (int i = 0; i < local[0]['estado_brasils'].length; i++) {
        states.add(local[0]['estado_brasils'][i]['estado']);
      }
      return states;
    }
    if (selectedCountry == 'Portugal') {
      List<String> states = [];
      for (int i = 0; i < local[1]['estado_portugals'].length; i++) {
        states.add(local[1]['estado_portugals'][i]['estado']);
      }
      return states;
    }
    return null;
  }

  Future<dynamic> getCitiesData({
    List<dynamic> local,
    String selectedState,
    String selectedCountry,
  }) async {
    int stateId = 0;

    if (selectedState == '') {
      return [];
    }

    //get the id from the list based on selected state
    if (selectedCountry == 'Brasil') {
      for (int i = 0; i < local[0]['estado_brasils'].length; i++) {
        if (local[0]['estado_brasils'][i]['estado'] == selectedState) {
          stateId = local[0]['estado_brasils'][i]['id'];
        }
      }
    }

    var _response = await http.get(
      Uri.parse(
        RotasUrl.rotaGetCities + '?stateId=' + stateId.toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    List<dynamic> responseData = json.decode(_response.body);

    if (responseData[0].containsKey('error')) {
      return [];
    } else {
      List<String> cities = [];
      responseData.forEach((city) => cities.add(city['city_name']));
      return cities;
    }
  }

  List<String> mapStatesToCitiesToUiList({
    List<dynamic> local,
    String selectedCountry,
  }) {
    //If no country is selected, then return default states to display
    if (selectedCountry == null) {
      List<String> states = [];
      for (int i = 0; i < local[0]['estado_brasils'].length; i++) {
        states.add(local[0]['estado_brasils'][i]['estado']);
      }
      return states;
    }

    if (selectedCountry == 'Brasil') {
      List<String> states = [];
      for (int i = 0; i < local[0]['estado_brasils'].length; i++) {
        states.add(local[0]['estado_brasils'][i]['estado']);
      }
      return states;
    }
    if (selectedCountry == 'Portugal') {
      List<String> states = [];
      for (int i = 0; i < local[1]['estado_portugals'].length; i++) {
        states.add(local[1]['estado_portugals'][i]['estado']);
      }
      return states;
    }
    return null;
  }
}
