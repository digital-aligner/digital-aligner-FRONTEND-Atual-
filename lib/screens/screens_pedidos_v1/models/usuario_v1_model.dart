import 'package:digital_aligner_app/dados/models/cadastro/representante_model.dart';

class UsuarioV1Model {
  int id;
  String username;
  String nome;
  String sobrenome;
  String email;
  RepresentanteModel? representante;
  int onboardingNum;

  UsuarioV1Model({
    this.id = 0,
    this.username = '',
    this.nome = '',
    this.sobrenome = '',
    this.email = '',
    this.representante,
    this.onboardingNum = 0,
  });

  factory UsuarioV1Model.fromJson(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return UsuarioV1Model();
    return UsuarioV1Model(
      id: data['id'] ?? 0,
      username: data['username'] ?? '',
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
      email: data['email'] ?? '',
      onboardingNum: data['onboarding_num'] ?? 0,
      representante: data['representante'] != null
          ? RepresentanteModel.fromJson(data['representante'])
          : RepresentanteModel.fromJson(Map()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
    };
  }
}
