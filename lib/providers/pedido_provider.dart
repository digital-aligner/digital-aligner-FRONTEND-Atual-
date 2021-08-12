import 'dart:convert';

import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';

class PedidoProvider with ChangeNotifier {
  final List<String> uploaderTypes = const [
    'fotografias',
    'radiografias',
    'modelo superior',
    'modelo inferior',
    'modelo compactado',
  ];
  //pedidos from server
  List<PedidoV1Model> _pedidosV1List = [];
  //selected refinamento
  List<PedidoV1Model> _pedidoRef = [];
  bool _refinamentoSelected = false;

  //for first pedido send
  List<FileModel> _fotografias = [];
  List<FileModel> _radiografias = [];
  List<FileModel> _modeloSuperior = [];
  List<FileModel> _modeloInferior = [];
  List<FileModel> _modeloCompactado = [];

  //upload files helper (for preventing send of files if have any error)
  //and prevent send while a file is uploading

  int _qntUploading = 0;
  int _qntErrors = 0;

  clearUploadAndErrors() {
    _qntUploading = 0;
    _qntErrors = 0;
  }

  int getQntUploading() {
    return _qntUploading;
  }

  decrementQntUploading() {
    if (_qntUploading == 0) return;
    _qntUploading--;
  }

  incrementQntUploading() {
    _qntUploading++;
  }

  int getQntErrors() {
    return _qntErrors;
  }

  decrementQntErrors() {
    if (_qntErrors == 0) return;
    _qntErrors--;
  }

  incrementQntErros() {
    _qntErrors++;
  }

  void clearDataAllProviderData() {
    _pedidosV1List = [];
    _fotografias = [];
    _radiografias = [];
    _modeloSuperior = [];
    _modeloInferior = [];
    _modeloCompactado = [];
  }

  void setRefinamento(PedidoV1Model pedido) {
    _pedidoRef = [];
    _pedidoRef.add(pedido);
    _refinamentoSelected = true;
  }

  void removeRefinamento() {
    _pedidoRef = [];
    _refinamentoSelected = false;
  }

  void saveFilesForFirstPedido({
    List<FileModel> fileList = const [],
    String uploaderType = '',
  }) {
    if (uploaderType == uploaderTypes[0])
      _fotografias = fileList;
    else if (uploaderType == uploaderTypes[1])
      _radiografias = fileList;
    else if (uploaderType == uploaderTypes[2])
      _modeloSuperior = fileList;
    else if (uploaderType == uploaderTypes[3])
      _modeloInferior = fileList;
    else if (uploaderType == uploaderTypes[4]) _modeloCompactado = fileList;
  }

  PedidoV1Model _mapFirstPedidoFilesToObj(PedidoV1Model p) {
    p.fotografias = _fotografias;
    p.radiografias = _radiografias;
    p.modeloSuperior = _modeloSuperior;
    p.modeloInferior = _modeloInferior;
    p.modeloCompactado = _modeloCompactado;
    return p;
  }

  Future<bool> enviarPrimeiroPedido({
    @required PedidoV1Model? pedido,
    @required String? token,
    @required String? tipoPedido,
  }) async {
    PedidoV1Model pedidoCompleto = _mapFirstPedidoFilesToObj(pedido!);
    String rota = '';

    switch (tipoPedido) {
      case 'pedido':
        {
          rota = RotasUrl.rotaPedidosV1;
        }
        break;
      case 'refinamento':
        {
          rota = RotasUrl.rotaPedidosRefinamentoV1;
        }
        break;
      default:
        {
          rota = '';
        }
        break;
    }

    try {
      var _response = await http.post(
        Uri.parse(rota),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(pedidoCompleto.toJson()),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          //using sem method
          if (tipoPedido == 'pedido') {
            clearDataAllProviderData();
          }

          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('enviarPrimeiroPedido ->' + e.toString());
      return false;
    }
  }

  Future<bool> enviarAtualizarPedido({
    PedidoV1Model? pedido,
    String token = '',
  }) async {
    try {
      var _response = await http.put(
        Uri.parse(RotasUrl.rotaPedidosV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(pedido!.toJson()),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          //using sem method
          //clearDataAllProviderData();
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('enviarPrimeiroPedido ->' + e.toString());
      return false;
    }
  }

  Future<bool> fetchAllPedidos({
    String token = '',
    int roleId = 0,
    String query = '',
    String queryStrings = '',
  }) async {
    clearDataAllProviderData();
    try {
      final response = await http.get(
        Uri.parse(
          RotasUrl.rotaPedidosV1 +
              '?roleId=' +
              roleId.toString() +
              '&queryString=' +
              query +
              queryStrings,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      List<dynamic> _pedidos = json.decode(response.body);

      if (_pedidos[0].containsKey('id')) {
        _pedidos.forEach((p) {
          _pedidosV1List.add(PedidoV1Model.fromJson(p));
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> fetchAddMorePedidos({
    String token = '',
    int roleId = 0,
    int pageQuant = 0,
    String query = '',
    String queryStrings = '',
  }) async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaPedidosV1 +
            '?roleId=' +
            roleId.toString() +
            '&pageQuant=' +
            pageQuant.toString() +
            query +
            queryStrings,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    try {
      List<dynamic> _pedidos = json.decode(response.body);
      if (_pedidos[0].containsKey('id')) {
        _pedidos.forEach((p) {
          _pedidosV1List.add(PedidoV1Model.fromJson(p));
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  List<PedidoV1Model> getPedidosInList() {
    return _pedidosV1List;
  }

  PedidoV1Model getPedido({int position = 0}) {
    if (_refinamentoSelected) return _pedidoRef[0];
    return _pedidosV1List.elementAt(position);
  }
}
