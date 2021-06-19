class StatusPedidoV1Model {
  int id;
  String status;

  StatusPedidoV1Model({this.id = 0, this.status = ''});

  factory StatusPedidoV1Model.fromJson(Map<String, dynamic> data) {
    return StatusPedidoV1Model(
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
