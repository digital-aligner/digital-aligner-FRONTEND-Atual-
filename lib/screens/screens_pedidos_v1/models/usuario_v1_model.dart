class UsuarioV1Model {
  int id;
  String nome;
  String sobrenome;

  UsuarioV1Model({
    this.id = 0,
    this.nome = '',
    this.sobrenome = '',
  });

  factory UsuarioV1Model.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return UsuarioV1Model();
    return UsuarioV1Model(
      id: data['id'] ?? 0,
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
    };
  }
}
