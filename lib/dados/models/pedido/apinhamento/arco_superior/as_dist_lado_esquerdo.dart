class AsDistLadoEsquerdo {
  int id;
  bool ate1_5mm;
  bool ate3mm;
  bool qtoNecessarioEvitarDip;
  String outros;

  AsDistLadoEsquerdo({
    this.id,
    this.ate1_5mm,
    this.ate3mm,
    this.qtoNecessarioEvitarDip,
    this.outros,
  });

  factory AsDistLadoEsquerdo.fromJson(Map<String, dynamic> data) {
    return AsDistLadoEsquerdo(
      id: data['id'],
      ate1_5mm: data['ate_1_5mm'],
      ate3mm: data['ate_3mm'],
      qtoNecessarioEvitarDip: data['qto_necessario_evitar_dip'],
      outros: data['outros'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ate_1_5mm': ate1_5mm,
      'ate_3mm': ate3mm,
      'qto_necessario_evitar_dip': qtoNecessarioEvitarDip,
      'outros': outros,
    };
  }
}
