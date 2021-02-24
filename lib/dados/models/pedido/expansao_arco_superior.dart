class ExpansaoArcoSuperior {
  int id;
  bool direito;
  bool esquerdo;
  bool movimentoDeCorpo;
  bool inclinacaoTorque;

  ExpansaoArcoSuperior({
    this.id,
    this.direito,
    this.esquerdo,
    this.movimentoDeCorpo,
    this.inclinacaoTorque,
  });

  factory ExpansaoArcoSuperior.fromJson(Map<String, dynamic> data) {
    return ExpansaoArcoSuperior(
      id: data['id'],
      direito: data['direito'],
      esquerdo: data['esquerdo'],
      movimentoDeCorpo: data['movimento_de_corpo'],
      inclinacaoTorque: data['inclinacao_torque'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direito': direito,
      'esquerdo': esquerdo,
      'movimento_de_corpo': movimentoDeCorpo,
      'inclinacao_torque': inclinacaoTorque,
    };
  }
}
