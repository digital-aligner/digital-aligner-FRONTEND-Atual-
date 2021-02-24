class Radiografias {
  int id;
  String foto1;
  String foto2;
  String foto3;
  String foto4;
  int foto1Id;
  int foto2Id;
  int foto3Id;
  int foto4Id;

  Radiografias({
    this.id,
    this.foto1,
    this.foto2,
    this.foto3,
    this.foto4,
    this.foto1Id,
    this.foto2Id,
    this.foto3Id,
    this.foto4Id,
  });

  factory Radiografias.fromJson(Map<String, dynamic> data) {
    return Radiografias(
      id: data['id'],
      foto1: data['foto1'],
      foto2: data['foto2'],
      foto3: data['foto3'],
      foto4: data['foto4'],
      foto1Id: data['foto1_id'],
      foto2Id: data['foto2_id'],
      foto3Id: data['foto3_id'],
      foto4Id: data['foto4_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto1': foto1,
      'foto2': foto2,
      'foto3': foto3,
      'foto4': foto4,
      'foto1_id': foto1Id,
      'foto2_id': foto2Id,
      'foto3_id': foto3Id,
      'foto4_id': foto4Id,
    };
  }
}
