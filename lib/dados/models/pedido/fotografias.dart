class Fotografias {
  int id;
  String foto1;
  String foto2;
  String foto3;
  String foto4;
  String foto5;
  String foto6;
  String foto7;
  String foto8;
  String foto9;
  String foto10;
  String foto11;
  String foto12;
  String foto13;
  String foto14;
  String foto15;
  String foto16;
  int foto1Id;
  int foto2Id;
  int foto3Id;
  int foto4Id;
  int foto5Id;
  int foto6Id;
  int foto7Id;
  int foto8Id;
  int foto9Id;
  int foto10Id;
  int foto11Id;
  int foto12Id;
  int foto13Id;
  int foto14Id;
  int foto15Id;
  int foto16Id;

  Fotografias({
    this.id,
    this.foto1,
    this.foto2,
    this.foto3,
    this.foto4,
    this.foto5,
    this.foto6,
    this.foto7,
    this.foto8,
    this.foto9,
    this.foto10,
    this.foto11,
    this.foto12,
    this.foto13,
    this.foto14,
    this.foto15,
    this.foto16,
    this.foto1Id,
    this.foto2Id,
    this.foto3Id,
    this.foto4Id,
    this.foto5Id,
    this.foto6Id,
    this.foto7Id,
    this.foto8Id,
    this.foto9Id,
    this.foto10Id,
    this.foto11Id,
    this.foto12Id,
    this.foto13Id,
    this.foto14Id,
    this.foto15Id,
    this.foto16Id,
  });

  factory Fotografias.fromJson(Map<String, dynamic> data) {
    return Fotografias(
      id: data['id'],
      foto1: data['foto1'],
      foto2: data['foto2'],
      foto3: data['foto3'],
      foto4: data['foto4'],
      foto5: data['foto5'],
      foto6: data['foto6'],
      foto7: data['foto7'],
      foto8: data['foto8'],
      foto9: data['foto9'],
      foto10: data['foto10'],
      foto11: data['foto11'],
      foto12: data['foto12'],
      foto13: data['foto13'],
      foto14: data['foto14'],
      foto15: data['foto15'],
      foto16: data['foto16'],
      foto1Id: data['foto1_id'],
      foto2Id: data['foto2_id'],
      foto3Id: data['foto3_id'],
      foto4Id: data['foto4_id'],
      foto5Id: data['foto5_id'],
      foto6Id: data['foto6_id'],
      foto7Id: data['foto7_id'],
      foto8Id: data['foto8_id'],
      foto9Id: data['foto9_id'],
      foto10Id: data['foto10_id'],
      foto11Id: data['foto11_id'],
      foto12Id: data['foto12_id'],
      foto13Id: data['foto13_id'],
      foto14Id: data['foto14_id'],
      foto15Id: data['foto15_id'],
      foto16Id: data['foto16_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foto1': foto1,
      'foto2': foto2,
      'foto3': foto3,
      'foto4': foto4,
      'foto5': foto5,
      'foto6': foto6,
      'foto7': foto7,
      'foto8': foto8,
      'foto9': foto9,
      'foto10': foto10,
      'foto11': foto11,
      'foto12': foto12,
      'foto13': foto13,
      'foto14': foto14,
      'foto15': foto15,
      'foto16': foto16,
      'foto1_id': foto1Id,
      'foto2_id': foto2Id,
      'foto3_id': foto3Id,
      'foto4_id': foto4Id,
      'foto5_id': foto5Id,
      'foto6_id': foto6Id,
      'foto7_id': foto7Id,
      'foto8_id': foto8Id,
      'foto9_id': foto9Id,
      'foto10_id': foto10Id,
      'foto11_id': foto11Id,
      'foto12_id': foto12Id,
      'foto13_id': foto13Id,
      'foto14_id': foto14Id,
      'foto15_id': foto15Id,
      'foto16_id': foto16Id,
    };
  }
}
