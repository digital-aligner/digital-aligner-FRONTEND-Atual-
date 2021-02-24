class TipoProcedimento {
  int id;
  int tipo;

  TipoProcedimento({
    this.id,
    this.tipo,
  });

  factory TipoProcedimento.fromJson(Map<String, dynamic> data) {
    return TipoProcedimento(
      id: data['id'],
      tipo: data['tipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
    };
  }
}
