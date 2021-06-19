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
  List<PedidoV1Model> _pedidosV1List = [];
  //for first pedido send
  List<FileModel> _fotografias = [];
  List<FileModel> _radiografias = [];
  List<FileModel> _modeloSuperior = [];
  List<FileModel> _modeloInferior = [];
  List<FileModel> _modeloCompactado = [];

  void clearDataOnRouteChange() {
    _pedidosV1List = [];
    _fotografias = [];
    _modeloSuperior = [];
    _modeloInferior = [];
    _modeloCompactado = [];
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

  Future<bool> enviarPrimeiroPedido(PedidoV1Model p, String token) async {
    PedidoV1Model pedidoCompleto = _mapFirstPedidoFilesToObj(p);

    try {
      var _response = await http.post(
        Uri.parse(RotasUrl.rotaPedidosV1),
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
          clearDataOnRouteChange();
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
}
