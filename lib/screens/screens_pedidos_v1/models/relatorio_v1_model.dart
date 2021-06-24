import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';

class RelatorioV1Model {
  int id;
  String visualizador1;
  String visualizador2;
  bool aprovado;
  FileModel? relatorio;
  Map<String, dynamic>? payload;

  RelatorioV1Model({
    this.id = 0,
    this.visualizador1 = '',
    this.visualizador2 = '',
    this.aprovado = false,
    this.relatorio,
    this.payload,
  });

  factory RelatorioV1Model.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return RelatorioV1Model();
    return RelatorioV1Model(
      id: data['id'] ?? 0,
      visualizador1: data['visualizador_1'] ?? '',
      visualizador2: data['visualizador_2'] ?? '',
      aprovado: data['aprovado'] ?? false,
      relatorio: FileModel.fromJson(data['relatorio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visualizador_1': visualizador1,
      'visualizador_2': visualizador2,
      'aprovado': aprovado,
      'relatorio': relatorio,
      'payload': payload,
    };
  }
}
