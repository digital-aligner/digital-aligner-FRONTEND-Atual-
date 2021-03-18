import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';

class PedidosListProvider with ChangeNotifier {
  String _token;
  String _queryString = '';
  String _dropownValue = 'Todos';

  void setDropdownValue(String value) {
    _dropownValue = value;
  }

  String getDropdownValue() {
    return _dropownValue;
  }

  void setToken(String t) {
    _token = t;
  }

  void setQuery(String value) {
    _queryString = value;
  }

  //---- GERENCIAR PEDIDO ------

  //Converted json string to map
  List<dynamic> _pedidos;

  //For when leaving screen and running deactivate state
  void clearPedidosOnLeave() {
    _pedidos = null;
    _queryString = '';
    _dropownValue = 'Todos';
  }

  //For clearing and updating ui with query search
  void clearPedidosAndUpdate() {
    _pedidos = null;
    notifyListeners();
  }

  List<dynamic> getPedidosList() {
    return _pedidos;
  }

  Future<dynamic> deletarPedido(int id) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.post(
        RotasUrl.rotaDeletePedido,
        headers: requestHeaders,
        body: json.encode({'id_pedido': id.toString()}),
      );
      var _data = json.decode(response.body);

      return _data;
    } catch (error) {
      print(error);
      return error;
    }
  }

  Future<List<dynamic>> fetchPedidos() async {
    //Check dropdown to change route: Todos, pedidos aprovados, etc.
    String _routeType;
    if (_dropownValue == 'Todos') {
      _routeType = RotasUrl.rotaPedidos;
    } else if (_dropownValue == 'Pedidos Aprovados') {
      _routeType = RotasUrl.rotaPedidosAprovados;
    } else if (_dropownValue == 'Refinamentos') {
      _routeType = RotasUrl.rotaRefinamentos;
    }

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        _routeType + '?queryString=' + _queryString,
        headers: requestHeaders,
      );
      _pedidos = json.decode(response.body);
      print(_pedidos);
      //Clearing query string
      _queryString = '';
      return _pedidos;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<List<dynamic>> fetchMeusPedidos(int id) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        RotasUrl.rotaMeusPedidos +
            '?pacienteId=' +
            id.toString() +
            '&queryString=' +
            _queryString,
        headers: requestHeaders,
      );
      _pedidos = json.decode(response.body);

      return _pedidos;
    } catch (error) {
      print(error);
      return error;
    }
  }

  Future<List<dynamic>> fetchMeusSetups(int id) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        RotasUrl.rotaMeusSetups +
            '?userId=' +
            id.toString() +
            '&queryString=' +
            _queryString,
        headers: requestHeaders,
      );
      _pedidos = json.decode(response.body);

      return _pedidos;
    } catch (error) {
      print(error);
      return error;
    }
  }

  Future<List<dynamic>> fetchMeusRefinamentos(int id) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        RotasUrl.rotaMeusRefinamentos +
            '?pacienteId=' +
            id.toString() +
            '&queryString=' +
            _queryString,
        headers: requestHeaders,
      );
      _pedidos = json.decode(response.body);

      return _pedidos;
    } catch (error) {
      print(error);
      return error;
    }
  }
}
