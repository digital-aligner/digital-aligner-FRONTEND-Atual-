class ExpansaoArcoSuperior {
  int id;
  bool direito;
  bool esquerdo;
  bool movimentoDeCorpo;
  bool inclinacaoTorque;
  bool movimentoDeCorpoEsq;
  bool inclinacaoTorqueEsq;

  ExpansaoArcoSuperior({
    this.id,
    this.direito,
    this.esquerdo,
    this.movimentoDeCorpo,
    this.inclinacaoTorque,
    this.movimentoDeCorpoEsq,
    this.inclinacaoTorqueEsq,
  });

  factory ExpansaoArcoSuperior.fromJson(Map<String, dynamic> data) {
    return ExpansaoArcoSuperior(
      id: data['id'],
      direito: data['direito'],
      esquerdo: data['esquerdo'],
      movimentoDeCorpo: data['movimento_de_corpo'],
      inclinacaoTorque: data['inclinacao_torque'],
      movimentoDeCorpoEsq: data['movimento_de_corpo_esq'],
      inclinacaoTorqueEsq: data['inclinacao_torque_esq'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direito': direito,
      'esquerdo': esquerdo,
      'movimento_de_corpo': movimentoDeCorpo,
      'inclinacao_torque': inclinacaoTorque,
      'movimento_de_corpo_esq': movimentoDeCorpoEsq,
      'inclinacao_torque_esq': inclinacaoTorqueEsq,
    };
  }
}
