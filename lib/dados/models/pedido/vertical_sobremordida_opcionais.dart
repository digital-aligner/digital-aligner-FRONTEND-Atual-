class VerticalSobremordidaOpcionais {
  int id;
  bool batentesMordida;
  bool lingualIncisivosSuperiores;
  bool lingualCaninoACaninoSuperior;
  String outros;

  VerticalSobremordidaOpcionais({
    this.id,
    this.batentesMordida,
    this.lingualIncisivosSuperiores,
    this.lingualCaninoACaninoSuperior,
    this.outros,
  });

  factory VerticalSobremordidaOpcionais.fromJson(Map<String, dynamic> data) {
    return VerticalSobremordidaOpcionais(
      id: data['id'],
      batentesMordida: data['batentes_mordida'],
      lingualIncisivosSuperiores: data['lingual_incisivos_superiores'],
      lingualCaninoACaninoSuperior: data['lingual_canino_a_canino_superior'],
      outros: data['outros'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batentes_mordida': batentesMordida,
      'lingual_incisivos_superiores': lingualIncisivosSuperiores,
      'lingual_canino_a_canino_superior': lingualCaninoACaninoSuperior,
      'outros': outros,
    };
  }
}
