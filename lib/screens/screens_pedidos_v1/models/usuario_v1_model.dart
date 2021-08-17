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
      username: data['username'],
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
      email: data['email'] ?? '',
      representante: RepresentanteModel.fromJson(
        data['representante'] ??
            {
              'id': -1,
              'username': '',
              'email': '',
              'blocked': false,
              'role': {'id': -1, 'name': ''},
              'nome': '',
              'sobrenome': '',
              'cro_uf': '',
              'cro_num': '',
              'data_nasc': '',
              'telefone': '',
              'celular': '',
              'aprovacao_usuario': {'id': -1, 'status': ''},
            },
      ),
      onboardingNum: data['onboarding_num'] ?? 0,
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
