import 'dart:convert';

import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';

class PedidoProvider with ChangeNotifier {
  List<PedidoV1Model> _pedidosV1List = [];
  //for first pedido send
  List<FileModel> _serverFiles = [];

  void saveFilesForFirstPedido(List<FileModel> f) {
    _serverFiles = f;
  }

  PedidoV1Model _mapFirstPedidoFilesToObj(PedidoV1Model p) {
    p.fotografias = _serverFiles;
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
        if (data.containsKey('id')) return true;
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
