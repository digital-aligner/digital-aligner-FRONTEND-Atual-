class AprovacaoUsuarioModel {
  int id;
  String status;

  AprovacaoUsuarioModel({this.id = 0, this.status = ''});

  factory AprovacaoUsuarioModel.fromJson(Map<String, dynamic> data) {
    return AprovacaoUsuarioModel(
      id: data['id'] ?? 0,
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
