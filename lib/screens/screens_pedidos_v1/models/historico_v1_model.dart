import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';

class StatusHistoricoV1 {
  int id;
  String status;
  String createdAt;

  StatusHistoricoV1({
    this.id = 0,
    this.status = '',
    this.createdAt = '',
  });

  factory StatusHistoricoV1.fromJson(Map<String, dynamic> data) {
    return StatusHistoricoV1(
        id: data['id'] ?? 0,
        status: data['status'] ?? '',
        createdAt: data['created_at'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'created_at': createdAt,
    };
  }
}

class HistoricoPacV1 {
  int id;
  StatusHistoricoV1? status;
  String informacao;
  PedidoV1Model? pedido;
  PedidoV1Model? pedidoRefinamento;
  String createdAt;
  //relatorios model vai estar aqui

  HistoricoPacV1({
    this.id = 0,
    this.status,
    this.informacao = '',
    this.pedido,
    this.pedidoRefinamento,
    this.createdAt = '',
  });

  factory HistoricoPacV1.fromJson(Map<String, dynamic> data) {
    return HistoricoPacV1(
      id: data['id'] ?? 0,
      informacao: data['informacao'] ?? '',
      status: StatusHistoricoV1.fromJson(data['status'] ?? Map()),
      pedido: PedidoV1Model.fromJson(data['pedido'] ?? Map()),
      pedidoRefinamento: PedidoV1Model.fromJson(
        data['pedido_refinamento'] ?? Map(),
      ),
      createdAt: data['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'informacao': informacao,
      'status': status?.toJson() ?? '',
      'pedido': pedido?.toJson() ?? '',
      'pedido_refinamento': pedidoRefinamento?.toJson() ?? '',
      'created_at': createdAt,
    };
  }
}
