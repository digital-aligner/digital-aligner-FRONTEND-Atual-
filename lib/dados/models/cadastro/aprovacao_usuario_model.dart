class AprovacaoUsuarioModel {
  int id;
  String status;

  AprovacaoUsuarioModel({this.id, this.status});

  factory AprovacaoUsuarioModel.fromJson(Map<String, dynamic> data) {
    return AprovacaoUsuarioModel(
      id: data['id'],
      status: data['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
