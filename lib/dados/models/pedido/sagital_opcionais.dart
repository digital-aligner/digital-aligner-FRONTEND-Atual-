class SagitalOpcionais {
  int id;
  bool desgastesInterproximais;
  bool recorteElasticoAlinhador;
  bool recorteAlinhadorBotao;
  bool alivioAlinhadorBracoForca;

  SagitalOpcionais({
    this.id,
    this.desgastesInterproximais,
    this.recorteElasticoAlinhador,
    this.recorteAlinhadorBotao,
    this.alivioAlinhadorBracoForca,
  });

  factory SagitalOpcionais.fromJson(Map<String, dynamic> data) {
    return SagitalOpcionais(
      id: data['id'],
      desgastesInterproximais: data['desgastes_interproximais'],
      recorteElasticoAlinhador: data['recorte_elastico_alinhador'],
      recorteAlinhadorBotao: data['recorte_alinhador_botao'],
      alivioAlinhadorBracoForca: data['alivio_alinhador_braco_forca'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desgastes_interproximais': desgastesInterproximais,
      'recorte_elastico_alinhador': recorteElasticoAlinhador,
      'recorte_alinhador_botao': recorteAlinhadorBotao,
      'alivio_alinhador_braco_forca': alivioAlinhadorBracoForca,
    };
  }
}
