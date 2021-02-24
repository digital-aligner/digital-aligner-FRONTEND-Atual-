class OpcionaisMordidaCruzPost {
  int id;
  bool recorteElasticoAlinhador;
  bool recorteAlinhadorBotao;

  OpcionaisMordidaCruzPost({
    this.id,
    this.recorteElasticoAlinhador,
    this.recorteAlinhadorBotao,
  });

  factory OpcionaisMordidaCruzPost.fromJson(Map<String, dynamic> data) {
    return OpcionaisMordidaCruzPost(
      id: data['id'],
      recorteElasticoAlinhador: data['recorte_elastico_alinhador'],
      recorteAlinhadorBotao: data['recorte_alinhador_botao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recorte_elastico_alinhador': recorteElasticoAlinhador,
      'recorte_alinhador_botao': recorteAlinhadorBotao,
    };
  }
}
