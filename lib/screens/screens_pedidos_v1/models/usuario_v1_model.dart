class UsuarioV1Model {
  int id;

  UsuarioV1Model({
    this.id = 0,
  });

  factory UsuarioV1Model.fromJson(Map<String, dynamic> data) {
    return UsuarioV1Model(
      id: data['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
