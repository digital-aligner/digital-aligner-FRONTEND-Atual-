class RelatorioPdf {
  int id;
  String relatorio1;
  String relatorio2;
  String relatorio3;
  String relatorio4;
  String relatorio5;
  int relatorio1Id;
  int relatorio2Id;
  int relatorio3Id;
  int relatorio4Id;
  int relatorio5Id;

  RelatorioPdf({
    this.id,
    this.relatorio1,
    this.relatorio2,
    this.relatorio3,
    this.relatorio4,
    this.relatorio5,
    this.relatorio1Id,
    this.relatorio2Id,
    this.relatorio3Id,
    this.relatorio4Id,
    this.relatorio5Id,
  });

  factory RelatorioPdf.fromJson(Map<String, dynamic> data) {
    return RelatorioPdf(
      id: data['id'],
      relatorio1: data['relatorio1'],
      relatorio2: data['relatorio2'],
      relatorio3: data['relatorio3'],
      relatorio4: data['relatorio4'],
      relatorio5: data['relatorio5'],
      relatorio1Id: data['relatorio1_id'],
      relatorio2Id: data['relatorio2_id'],
      relatorio3Id: data['relatorio3_id'],
      relatorio4Id: data['relatorio4_id'],
      relatorio5Id: data['relatorio5_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relatorio1': relatorio1,
      'relatorio2': relatorio2,
      'relatorio3': relatorio3,
      'relatorio4': relatorio4,
      'relatorio5': relatorio5,
      'relatorio1_id': relatorio1Id,
      'relatorio2_id': relatorio2Id,
      'relatorio3_id': relatorio3Id,
      'relatorio4_id': relatorio4Id,
      'relatorio5_id': relatorio5Id,
    };
  }
}
