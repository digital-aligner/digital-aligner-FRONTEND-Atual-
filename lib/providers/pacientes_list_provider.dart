import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';

class PacientesListProvider with ChangeNotifier {
  String _token;
  int _id;
  String _queryString = '';

  void setToken(String t) {
    _token = t;
  }

  void setUserId(int id) {
    _id = id;
  }

  //---- GERENCIAR PACIENTES ------

  //Converted json string to map
  List<dynamic> _pacientes;

  void clearPacientes() {
    _pacientes = null;
    _queryString = '';
  }

  //For clearing and updating ui with query search
  void clearPacientesAndUpdate() {
    _pacientes = null;
    notifyListeners();
  }

  void setQuery(String value) {
    _queryString = value;
  }

  List<dynamic> getPacientesList() {
    return _pacientes;
  }

  Future<List<dynamic>> fetchPacientes(int startPage) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(
          RotasUrl.rotaMeusPacientes +
              '?id=' +
              _id.toString() +
              '&queryString=' +
              _queryString +
              '&startPage=' +
              startPage.toString(),
        ),
        headers: requestHeaders,
      );
      _pacientes = json.decode(response.body);

      return _pacientes;
    } catch (error) {
      print(error);
      return error;
    }
  }

  Future<List<dynamic>> fetchAllPacientes(int startPage) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(
          RotasUrl.rotaGerenciarPacientes +
              '?queryString=' +
              _queryString +
              '&startPage=' +
              startPage.toString(),
        ),
        headers: requestHeaders,
      );
      _pacientes = json.decode(response.body);

      return _pacientes;
    } catch (error) {
      print(error);
      return [];
    }
  }
}
