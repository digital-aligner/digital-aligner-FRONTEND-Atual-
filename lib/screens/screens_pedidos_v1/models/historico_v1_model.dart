import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/relatorio_v1_model.dart';

class StatusHistoricoV1 {
  int id;
  String status;
  String codigoStatus;
  String createdAt;
  Map<String, dynamic>? payload;

  StatusHistoricoV1({
    this.id = 0,
    this.status = '',
    this.codigoStatus = '',
    this.createdAt = '',
    this.payload,
  });

  factory StatusHistoricoV1.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return StatusHistoricoV1();
    return StatusHistoricoV1(
        id: data['id'] ?? 0,
        status: data['status'] ?? '',
        codigoStatus: data['codigo_status'] ?? '',
        createdAt: data['created_at'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'codigo_status': status,
      'created_at': createdAt,
      'payload': payload,
    };
  }
}

class HistoricoPacV1 {
  int id;
  StatusHistoricoV1? status;
  String informacao;
  PedidoV1Model? pedido;
  PedidoV1Model? pedidoRefinamento;
  RelatorioV1Model? relatorio;
  String createdAt;
  Map<String, dynamic>? payload;

  HistoricoPacV1({
    this.id = 0,
    this.status,
    this.informacao = '',
    this.pedido,
    this.pedidoRefinamento,
    this.relatorio,
    this.createdAt = '',
    this.payload,
  });

  factory HistoricoPacV1.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return HistoricoPacV1();
    return HistoricoPacV1(
      id: data['id'] ?? 0,
      informacao: data['informacao'] ?? '',
      status: StatusHistoricoV1.fromJson(data['status'] ?? Map()),
      pedido: PedidoV1Model.fromJson(data['pedido'] ?? Map()),
      pedidoRefinamento: PedidoV1Model.fromJson(
        data['pedido_refinamento'] ?? Map(),
      ),
      relatorio: RelatorioV1Model.fromJson(
        data['relatorio'] ?? Map(),
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
      'relatorio': relatorio?.toJson() ?? '',
      'created_at': createdAt,
      'payload': payload,
    };
  }
}
