import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';

class PacienteV1Model {
  int id;
  String nomePaciente;
  String dataNascimento;
  //UsuarioV1Model? usuario;

  PacienteV1Model({
    this.id = 0,
    this.nomePaciente = '',
    this.dataNascimento = '',
    //this.usuario,
  });

  factory PacienteV1Model.fromJson(Map<String, dynamic> data) {
    return PacienteV1Model(
      id: data['id'] ?? 0,
      nomePaciente: data['nome_paciente'] ?? '',
      dataNascimento: data['data_nascimento'] ?? '',
      //usuario: UsuarioV1Model.fromJson(data['usuario'] ?? Map()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_paciente': nomePaciente,
      'data_nascimento': dataNascimento,
      //'usuario': usuario?.toJson() ?? '',
    };
  }
}
