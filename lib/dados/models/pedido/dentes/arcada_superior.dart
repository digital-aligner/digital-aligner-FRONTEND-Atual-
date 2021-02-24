class ArcadaSuperior {
  int id;
  bool d18;
  bool d17;
  bool d16;
  bool d15;
  bool d14;
  bool d13;
  bool d12;
  bool d11;
  bool d21;
  bool d22;
  bool d23;
  bool d24;
  bool d25;
  bool d26;
  bool d27;
  bool d28;

  ArcadaSuperior({
    this.id,
    this.d18,
    this.d17,
    this.d16,
    this.d15,
    this.d14,
    this.d13,
    this.d12,
    this.d11,
    this.d21,
    this.d22,
    this.d23,
    this.d24,
    this.d25,
    this.d26,
    this.d27,
    this.d28,
  });

  factory ArcadaSuperior.fromJson(Map<String, dynamic> data) {
    return ArcadaSuperior(
      id: data['id'],
      d18: data['d18'],
      d17: data['d17'],
      d16: data['d16'],
      d15: data['d15'],
      d14: data['d14'],
      d13: data['d13'],
      d12: data['d12'],
      d11: data['d11'],
      d21: data['d21'],
      d22: data['d22'],
      d23: data['d23'],
      d24: data['d24'],
      d25: data['d25'],
      d26: data['d26'],
      d27: data['d27'],
      d28: data['d28'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'd18': d18,
      'd17': d17,
      'd16': d16,
      'd15': d15,
      'd14': d14,
      'd13': d13,
      'd12': d12,
      'd11': d11,
      'd21': d21,
      'd22': d22,
      'd23': d23,
      'd24': d24,
      'd25': d25,
      'd26': d26,
      'd27': d27,
      'd28': d28,
    };
  }
}
