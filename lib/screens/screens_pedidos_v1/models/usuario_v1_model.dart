class UsuarioV1Model {
  int id;
  String username;
  String nome;
  String sobrenome;

  UsuarioV1Model({
    this.id = 0,
    this.username = '',
    this.nome = '',
    this.sobrenome = '',
  });

  factory UsuarioV1Model.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return UsuarioV1Model();
    return UsuarioV1Model(
      id: data['id'] ?? 0,
      username: data['username'],
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nome': nome,
      'sobrenome': sobrenome,
    };
  }
}
