class ModeloNemo {
  int id;
  String modeloNemo;
  int modeloNemoId;

  ModeloNemo({
    this.id,
    this.modeloNemo,
    this.modeloNemoId,
  });

  factory ModeloNemo.fromJson(Map<String, dynamic> data) {
    return ModeloNemo(
      id: data['id'],
      modeloNemo: data['modelo_nemo'],
      modeloNemoId: data['modelo_nemo_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelo_nemo': modeloNemo,
      'modelo_nemo_id': modeloNemoId,
    };
  }
}
