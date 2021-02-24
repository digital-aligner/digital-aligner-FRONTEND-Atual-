import 'status_correcao.dart';

class SobremordidaProfunda {
  int id;
  StatusCorrecao statusCorrecao;
  String intrusaoDentesAnterioresSup;
  String intrusaoDentesAnterioresInf;
  String extrusaoDentesPosterioresSup;
  String extrusaoDentesPosterioresInf;

  SobremordidaProfunda({
    this.id,
    this.statusCorrecao,
    this.intrusaoDentesAnterioresSup,
    this.intrusaoDentesAnterioresInf,
    this.extrusaoDentesPosterioresSup,
    this.extrusaoDentesPosterioresInf,
  });

  factory SobremordidaProfunda.fromJson(Map<String, dynamic> data) {
    return SobremordidaProfunda(
      id: data['id'],
      statusCorrecao: StatusCorrecao.fromJson(data['status_correcao']),
      intrusaoDentesAnterioresSup: data['intrusao_dentes_anteriores_sup'],
      intrusaoDentesAnterioresInf: data['intrusao_dentes_anteriores_inf'],
      extrusaoDentesPosterioresSup: data['extrusao_dentes_posteriores_sup'],
      extrusaoDentesPosterioresInf: data['extrusao_dentes_posteriores_inf'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_correcao': statusCorrecao.toJson(),
      'intrusao_dentes_anteriores_sup': intrusaoDentesAnterioresSup,
      'intrusao_dentes_anteriores_inf': intrusaoDentesAnterioresInf,
      'extrusao_dentes_posteriores_sup': extrusaoDentesPosterioresSup,
      'extrusao_dentes_posteriores_inf': extrusaoDentesPosterioresInf,
    };
  }
}
