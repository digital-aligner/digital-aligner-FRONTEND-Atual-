class RelatorioPdf {
  int id;
  String relatorio1;
  int relatorio1Id;

  RelatorioPdf({
    this.id,
    this.relatorio1,
    this.relatorio1Id,
  });

  factory RelatorioPdf.fromJson(Map<String, dynamic> data) {
    return RelatorioPdf(
      id: data['id'],
      relatorio1: data['relatorio1'],
      relatorio1Id: data['relatorio1_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relatorio1': relatorio1,
      'relatorio1_id': relatorio1Id,
    };
  }
}
