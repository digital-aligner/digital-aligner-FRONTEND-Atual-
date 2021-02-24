import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/arco_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/arco_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';

class Apinhamento {
  int id;
  bool ausenciaApinhamento;
  StatusCorrecao statusCorrecao;
  ArcoSuperior arcoSuperior;
  ArcoInferior arcoInferior;
  //arco inf;

  Apinhamento({
    this.id,
    this.ausenciaApinhamento,
    this.statusCorrecao,
    this.arcoSuperior,
    this.arcoInferior,
  });

  factory Apinhamento.fromJson(Map<String, dynamic> data) {
    return Apinhamento(
      id: data['id'],
      ausenciaApinhamento: data['ausencia_apinhamento'],
      statusCorrecao: StatusCorrecao.fromJson(data['status_correcao']),
      arcoSuperior: ArcoSuperior.fromJson(data['arco_superior']),
      arcoInferior: ArcoInferior.fromJson(data['arco_inferior']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ausencia_apinhamento': ausenciaApinhamento,
      'status_correcao': statusCorrecao.toJson(),
      'arco_superior': arcoSuperior.toJson(),
      'arco_inferior': arcoInferior.toJson(),
    };
  }
}
