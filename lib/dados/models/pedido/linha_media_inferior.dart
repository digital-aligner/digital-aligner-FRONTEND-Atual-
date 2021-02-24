import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';

class LinhaMediaInferior {
  int id;
  StatusCorrecao statusCorrecao;
  String moverDireita;
  String moverEsquerda;

  LinhaMediaInferior({
    this.id,
    this.statusCorrecao,
    this.moverDireita,
    this.moverEsquerda,
  });

  factory LinhaMediaInferior.fromJson(Map<String, dynamic> data) {
    return LinhaMediaInferior(
      id: data['id'],
      statusCorrecao: StatusCorrecao.fromJson(data['status_correcao']),
      moverDireita: data['mover_direita'],
      moverEsquerda: data['mover_esquerda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_correcao': statusCorrecao.toJson(),
      'mover_direita': moverDireita,
      'mover_esquerda': moverEsquerda,
    };
  }
}
