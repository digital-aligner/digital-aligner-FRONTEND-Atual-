class RelatorioPPT {
  int id;
  String relatorio1;
  int relatorio1Id;

  RelatorioPPT({
    this.id,
    this.relatorio1,
    this.relatorio1Id,
  });

  factory RelatorioPPT.fromJson(Map<String, dynamic> data) {
    return RelatorioPPT(
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
