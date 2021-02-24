class ModeloCompactado {
  int id;
  String modeloCompactado;
  int modeloCompactadoId;

  ModeloCompactado({
    this.id,
    this.modeloCompactado,
    this.modeloCompactadoId,
  });

  factory ModeloCompactado.fromJson(Map<String, dynamic> data) {
    return ModeloCompactado(
      id: data['id'],
      modeloCompactado: data['modelo_compactado'],
      modeloCompactadoId: data['modelo_compactado_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelo_compactado': modeloCompactado,
      'modelo_compactado_id': modeloCompactadoId,
    };
  }
}
