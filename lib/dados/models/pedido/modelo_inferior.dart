class ModeloInferior {
  int id;
  String modeloInferior;
  int modeloInferiorId;

  ModeloInferior({
    this.id,
    this.modeloInferior,
    this.modeloInferiorId,
  });

  factory ModeloInferior.fromJson(Map<String, dynamic> data) {
    return ModeloInferior(
      id: data['id'],
      modeloInferior: data['modelo_inferior'],
      modeloInferiorId: data['modelo_inferior_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelo_inferior': modeloInferior,
      'modelo_inferior_id': modeloInferiorId,
    };
  }
}
