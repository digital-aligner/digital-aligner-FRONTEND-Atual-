import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';

class MordidaAbertaAnterior {
  int id;
  StatusCorrecao statusCorrecao;
  String extrusaoDentesAnterioresSup;
  String extrusaoDentesAnterioresInf;
  String intrusaoDentesPosterioresSup;
  String intrusaoDentesPosterioresInf;

  MordidaAbertaAnterior({
    this.id,
    this.statusCorrecao,
    this.extrusaoDentesAnterioresSup,
    this.extrusaoDentesAnterioresInf,
    this.intrusaoDentesPosterioresSup,
    this.intrusaoDentesPosterioresInf,
  });

  factory MordidaAbertaAnterior.fromJson(Map<String, dynamic> data) {
    return MordidaAbertaAnterior(
      id: data['id'],
      statusCorrecao: StatusCorrecao.fromJson(data['status_correcao']),
      extrusaoDentesAnterioresSup: data['extrusao_dentes_anteriores_sup'],
      extrusaoDentesAnterioresInf: data['extrusao_dentes_anteriores_inf'],
      intrusaoDentesPosterioresSup: data['intrusao_dentes_posteriores_sup'],
      intrusaoDentesPosterioresInf: data['intrusao_dentes_posteriores_inf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_correcao': statusCorrecao.toJson(),
      'extrusao_dentes_anteriores_sup': extrusaoDentesAnterioresSup,
      'extrusao_dentes_anteriores_inf': extrusaoDentesAnterioresInf,
      'intrusao_dentes_posteriores_sup': intrusaoDentesPosterioresSup,
      'intrusao_dentes_posteriores_inf': intrusaoDentesPosterioresInf,
    };
  }
}
