class OpcionaisMordidaCruzPost {
  int id;
  bool recorteElasticoAlinhador;
  bool recorteAlinhadorBotao;
  String localMcpRecElastAlinh;
  String localMcpRecAlinhBotao;

  OpcionaisMordidaCruzPost({
    this.id,
    this.recorteElasticoAlinhador,
    this.recorteAlinhadorBotao,
    this.localMcpRecElastAlinh,
    this.localMcpRecAlinhBotao,
  });

  factory OpcionaisMordidaCruzPost.fromJson(Map<String, dynamic> data) {
    return OpcionaisMordidaCruzPost(
      id: data['id'],
      recorteElasticoAlinhador: data['recorte_elastico_alinhador'],
      recorteAlinhadorBotao: data['recorte_alinhador_botao'],
      localMcpRecElastAlinh: data['local_mcp_rec_elast_alinh'],
      localMcpRecAlinhBotao: data['local_mcp_rec_alinh_botao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recorte_elastico_alinhador': recorteElasticoAlinhador,
      'recorte_alinhador_botao': recorteAlinhadorBotao,
      'local_mcp_rec_elast_alinh': localMcpRecElastAlinh,
      'local_mcp_rec_alinh_botao': localMcpRecAlinhBotao,
    };
  }
}
