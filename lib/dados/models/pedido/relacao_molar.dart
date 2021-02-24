import 'package:digital_aligner_app/dados/models/pedido/Tipo_procedimento.dart';
import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';

class RelacaoMolar {
  int id;
  StatusCorrecao ladoDireito;
  StatusCorrecao ladoEsquerdo;
  TipoProcedimento superiorDireito;
  TipoProcedimento inferiorDireito;
  TipoProcedimento superiorEsquerdo;
  TipoProcedimento inferiorEsquerdo;
  String outro;

  RelacaoMolar({
    this.id,
    this.ladoDireito,
    this.ladoEsquerdo,
    this.superiorDireito,
    this.inferiorDireito,
    this.superiorEsquerdo,
    this.inferiorEsquerdo,
    this.outro,
  });

  factory RelacaoMolar.fromJson(Map<String, dynamic> data) {
    return RelacaoMolar(
      id: data['id'],
      ladoDireito: StatusCorrecao.fromJson(data['lado_direito']),
      ladoEsquerdo: StatusCorrecao.fromJson(data['lado_esquerdo']),
      superiorDireito: TipoProcedimento.fromJson(data['superior_direito']),
      inferiorDireito: TipoProcedimento.fromJson(data['inferior_direito']),
      superiorEsquerdo: TipoProcedimento.fromJson(data['superior_esquerdo']),
      inferiorEsquerdo: TipoProcedimento.fromJson(data['inferior_esquerdo']),
      outro: data['outro'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lado_direito': ladoDireito.toJson(),
      'lado_esquerdo': ladoEsquerdo.toJson(),
      'superior_direito': superiorDireito.toJson(),
      'inferior_direito': inferiorDireito.toJson(),
      'superior_esquerdo': superiorEsquerdo.toJson(),
      'inferior_esquerdo': inferiorEsquerdo.toJson(),
      'outro': outro,
    };
  }
}
