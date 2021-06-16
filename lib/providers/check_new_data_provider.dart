import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';
import 'dart:convert';

class CheckNewDataProvider with ChangeNotifier {
  int novosPedidosCount = -1;

  String _token = '';
  //public var
  bool _fetchData = true;

  bool getFetchDataBool() {
    return _fetchData;
  }

  void setfetchDataBool(bool value) {
    _fetchData = value;
  }

  void setToken(String t) {
    _token = t;
  }

  Future<void> fetchNovoPedidoCount() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaNovosPedidosCount),
        headers: requestHeaders,
      );
      var data = json.decode(response.body);

      if (data is int) {
        novosPedidosCount = data;
      } else {
        novosPedidosCount = 0;
      }
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> checkNovosPedidoCount() async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaNovosPedidosCount),
        headers: requestHeaders,
      );
      var data = json.decode(response.body);

      if (data is int) {
        novosPedidosCount = data;
      } else {
        novosPedidosCount = 0;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> pedidoVisualizado(int id, bool visualizado) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    try {
      final response = await http.put(
          Uri.parse(RotasUrl.rotaPedidos + id.toString()),
          headers: requestHeaders,
          body: json.encode({'visualizado': visualizado}));
    } catch (error) {
      print(error);
      return;
    }
  }
}
