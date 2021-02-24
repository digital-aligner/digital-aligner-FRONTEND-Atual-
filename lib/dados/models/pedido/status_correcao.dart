class StatusCorrecao {
  int id;
  int status;

  StatusCorrecao({
    this.id,
    this.status,
  });

  factory StatusCorrecao.fromJson(Map<String, dynamic> data) {
    return StatusCorrecao(
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
