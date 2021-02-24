class HistoricoPaciente {
  int id;
  String status;
  int paciente;
  int usersPermissionsUser;

  HistoricoPaciente({
    this.id,
    this.status,
    this.paciente,
    this.usersPermissionsUser,
  });

  factory HistoricoPaciente.fromJson(Map<String, dynamic> data) {
    return HistoricoPaciente(
      id: data['id'],
      status: data['status'],
      paciente: data['paciente'],
      usersPermissionsUser: data['users_permissions_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'paciente': paciente,
      'users_permissions_user': usersPermissionsUser,
    };
  }
}
