class Paciente {
  int id;
  String nomePaciente;
  String dataNascimento;
  int usersPermissionsUser;

  Paciente({
    this.id,
    this.nomePaciente,
    this.dataNascimento,
    this.usersPermissionsUser,
  });

  factory Paciente.fromJson(Map<String, dynamic> data) {
    return Paciente(
      id: data['id'],
      nomePaciente: data['nome_paciente'],
      dataNascimento: data['data_nascimento'],
      usersPermissionsUser: data['users_permissions_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_paciente': nomePaciente,
      'data_nascimento': dataNascimento,
      'users_permissions_user': usersPermissionsUser,
    };
  }
}
