class ModeloSuperior {
  int id;
  String modeloSuperior;
  int modeloSuperiorId;

  ModeloSuperior({
    this.id,
    this.modeloSuperior,
    this.modeloSuperiorId,
  });

  factory ModeloSuperior.fromJson(Map<String, dynamic> data) {
    return ModeloSuperior(
      id: data['id'],
      modeloSuperior: data['modelo_superior'],
      modeloSuperiorId: data['modelo_superior_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelo_superior': modeloSuperior,
      'modelo_superior_id': modeloSuperiorId,
    };
  }
}
