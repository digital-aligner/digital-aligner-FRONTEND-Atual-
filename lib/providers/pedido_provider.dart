import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:flutter/material.dart';

class PedidoProvider with ChangeNotifier {
  List<PedidoV1Model> _pedidosV1List = [];

  Future<bool> enviarPrimeiroPedido() async {
    return false;
  }
}
