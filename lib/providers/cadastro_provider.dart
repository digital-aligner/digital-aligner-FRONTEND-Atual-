import 'dart:convert';

import '../dados/models/cadastro/aprovacao_usuario_model.dart';
import '../dados/models/cadastro/role_model.dart';

import '../dados/models/cadastro/cadastro_model.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../rotas_url.dart';

class CadastroProvider with ChangeNotifier {
  //Converted json string to map
  List<dynamic> _cadastros;
  //Currently selected cadastro obj
  CadastroModel _selectedCad;
  //Token for requests
  String _token;

  //For gerenciar cadastro screen
  String _cadDropdownValue = 'Todos';
  //For permissões cadastro screen
  String _permDropdownValue = 'Todos';

  void setCadDropdownValue(String value) {
    _cadDropdownValue = value;
  }

  String getCadDropdownValue() {
    return _cadDropdownValue;
  }

  void setPermDropdownValue(String value) {
    _permDropdownValue = value;
  }

  String getPermDropdownValue() {
    return _permDropdownValue;
  }

  //For query
  String _queryString = '';

  void setQuery(String value) {
    _queryString = value;
  }

  void clearCadastrosAndUpdate() {
    _cadastros = null;
    _selectedCad = null;
    notifyListeners();
  }

  void setNotify() {
    notifyListeners();
  }

  CadastroModel selectedCad() {
    return _selectedCad;
  }

  void clearCadastros() {
    _cadastros = null;
    _cadDropdownValue = 'Todos';
    _permDropdownValue = 'Todos';
    _queryString = '';
  }

  void clearSelectedCad() {
    _selectedCad = null;
  }

  void clearToken() {
    _token = null;
  }

  void setToken(var t) {
    _token = t;
  }

  List<dynamic> getCadastros() {
    return _cadastros;
  }

  void setSelectedCad(int index) {
    _selectedCad = CadastroModel(
      id: _cadastros[index]['id'],
      usernameCpf: _cadastros[index]['username'],
      email: _cadastros[index]['email'],
      blocked: _cadastros[index]['blocked'],
      role: RoleModel(
          id: _cadastros[index]['role']['id'],
          name: _cadastros[index]['role']['name']),
      nome: _cadastros[index]['nome'],
      sobrenome: _cadastros[index]['sobrenome'],
      cro_uf: _cadastros[index]['cro_uf'],
      cro_num: _cadastros[index]['cro_num'],
      data_nasc: _cadastros[index]['data_nasc'],
      telefone: _cadastros[index]['telefone'],
      celular: _cadastros[index]['celular'],
      aprovacao_usuario: AprovacaoUsuarioModel(
          id: _cadastros[index]['aprovacao_usuario']['id'],
          status: _cadastros[index]['aprovacao_usuario']['status']),
    );
  }

  void setMyCad(List<dynamic> data) {
    _selectedCad = CadastroModel(
      id: data[0]['id'],
      usernameCpf: data[0]['username'],
      email: data[0]['email'],
      blocked: data[0]['blocked'],
      role: RoleModel(
        id: data[0]['role']['id'],
        name: data[0]['role']['name'],
      ),
      nome: data[0]['nome'],
      sobrenome: data[0]['sobrenome'],
      cro_uf: data[0]['cro_uf'],
      cro_num: data[0]['cro_num'],
      data_nasc: data[0]['data_nasc'],
      telefone: data[0]['telefone'],
      celular: data[0]['celular'],
      aprovacao_usuario: AprovacaoUsuarioModel(
        id: data[0]['aprovacao_usuario']['id'],
        status: data[0]['aprovacao_usuario']['status'],
      ),
    );
  }

  Future<List<dynamic>> fetchMyCadastro() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        RotasUrl.rotaUserMe,
        headers: requestHeaders,
      );
      _cadastros = json.decode(response.body);

      setMyCad(_cadastros);
      return _cadastros;
    } catch (error) {
      print('Ops, error occurred! Status code: ' + error.toString());
    }
    return _cadastros;
  }

  Future<List<dynamic>> fetchCadastros() async {
    if (_cadastros != null && !_cadastros[0].containsKey('error')) {
      return _cadastros;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    //Check dropdown to change route: Todos, pedidos aprovados, etc.
    String _routeType;
    if (_cadDropdownValue == 'Todos') {
      _routeType = RotasUrl.rotaCadastro;
    } else if (_cadDropdownValue == 'Aprovado') {
      _routeType = RotasUrl.rotaCadastrosAprovados;
    } else if (_cadDropdownValue == 'Aguardando') {
      _routeType = RotasUrl.rotaCadastrosAguardando;
    } else if (_cadDropdownValue == 'Negado') {
      _routeType = RotasUrl.rotaCadastrosNegado;
    } else if (_permDropdownValue == 'Administrador') {
      _routeType = RotasUrl.rotaCadastrosAdministrador;
    } else if (_permDropdownValue == 'Gerente') {
      _routeType = RotasUrl.rotaCadastrosGerente;
    } else if (_permDropdownValue == 'Credenciado') {
      _routeType = RotasUrl.rotaCadastrosCredenciado;
    }

    try {
      final response = await http.get(
        _routeType + '?queryString=' + _queryString,
        headers: requestHeaders,
      );
      _cadastros = json.decode(response.body);
      //Clearing query string
      _queryString = '';
      return _cadastros;
    } catch (error) {
      print('Ops, error occurred! Status code: ' + error.toString());
    }
    return _cadastros;
  }

  Future<List<dynamic>> fetchCadastrosPerm() async {
    if (_cadastros != null && !_cadastros[0].containsKey('error')) {
      return _cadastros;
    }
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    //Check dropdown to change route: Todos, pedidos aprovados, etc.
    String _routeType;
    if (_permDropdownValue == 'Todos') {
      _routeType = RotasUrl.rotaCadastro;
    } else if (_permDropdownValue == 'Administrador') {
      _routeType = RotasUrl.rotaCadastrosAdministrador;
    } else if (_permDropdownValue == 'Gerente') {
      _routeType = RotasUrl.rotaCadastrosGerente;
    } else if (_permDropdownValue == 'Credenciado') {
      _routeType = RotasUrl.rotaCadastrosCredenciado;
    }

    try {
      final response = await http.get(
        _routeType + '?queryString=' + _queryString,
        headers: requestHeaders,
      );
      _cadastros = json.decode(response.body);
      //Clearing query string
      _queryString = '';
      return _cadastros;
    } catch (error) {
      print('Ops, error occurred! Status code: ' + error.toString());
    }
    return _cadastros;
  }

  Future<dynamic> aprovarCadastro(int id) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: json.encode(
          {
            'aprovacao_usuario': '1',
            'blocked': false,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> sendCadistaState(int id, bool value) async {
    String url = RotasUrl.rotaCadastro + id.toString();

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: json.encode(
          {
            'is_cadista': value,
          },
        ),
      );
      Map responseData = json.decode(response.body);

      clearCadastrosAndUpdate();
      return responseData;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
  }

  Future<dynamic> enviarCadastro() async {
    var _response =
        await http.put(RotasUrl.rotaCadastro + _selectedCad.id.toString(),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_token'
            },
            body: json.encode(_selectedCad.toJson()));

    Map _data = json.decode(_response.body);
    clearCadastrosAndUpdate();
    return _data;
  }

  //Converted json string to map
  List<dynamic> _aprovTableMap;
  //List of string just for widget
  List<String> _aprovTableList;

  List<String> getAprovTableList() {
    return _aprovTableList;
  }

  void handleAprovRelation(String status) {
    _aprovTableMap.forEach((element) {
      if (element['status'] == status) {
        _selectedCad.aprovacao_usuario.id = element['id'];
        _selectedCad.aprovacao_usuario.status = status;

        if (element['status'] != 'Aprovado') {
          _selectedCad.blocked = true;
        } else {
          _selectedCad.blocked = false;
        }
      }
    });
  }

  Future<List<String>> getAprovacaoTable() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final _response = await http.get(
        RotasUrl.rotaAprovacao,
        headers: requestHeaders,
      );
      _aprovTableMap = json.decode(_response.body);

      _aprovTableList = _aprovTableMap.map((tablevalue) {
        return tablevalue['status'].toString();
      }).toList();

      return _aprovTableList;
    } catch (error) {
      print('Error! Status code: ' + error.toString());
    }
    return [];
  }
}
