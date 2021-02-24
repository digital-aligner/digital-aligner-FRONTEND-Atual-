class ExtracaoTerceirosMolares {
  int id;
  bool sim;
  bool nao;

  ExtracaoTerceirosMolares({
    this.id,
    this.sim,
    this.nao,
  });

  factory ExtracaoTerceirosMolares.fromJson(Map<String, dynamic> data) {
    return ExtracaoTerceirosMolares(
      id: data['id'],
      sim: data['sim'],
      nao: data['nao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sim': sim,
      'nao': nao,
    };
  }
}
