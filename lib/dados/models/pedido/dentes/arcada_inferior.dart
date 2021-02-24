class ArcadaInferior {
  int id;
  bool d48;
  bool d47;
  bool d46;
  bool d45;
  bool d44;
  bool d43;
  bool d42;
  bool d41;
  bool d31;
  bool d32;
  bool d33;
  bool d34;
  bool d35;
  bool d36;
  bool d37;
  bool d38;

  ArcadaInferior({
    this.id,
    this.d48,
    this.d47,
    this.d46,
    this.d45,
    this.d44,
    this.d43,
    this.d42,
    this.d41,
    this.d31,
    this.d32,
    this.d33,
    this.d34,
    this.d35,
    this.d36,
    this.d37,
    this.d38,
  });

  factory ArcadaInferior.fromJson(Map<String, dynamic> data) {
    return ArcadaInferior(
      id: data['id'],
      d48: data['d48'],
      d47: data['d47'],
      d46: data['d46'],
      d45: data['d45'],
      d44: data['d44'],
      d43: data['d43'],
      d42: data['d42'],
      d41: data['d41'],
      d31: data['d31'],
      d32: data['d32'],
      d33: data['d33'],
      d34: data['d34'],
      d35: data['d35'],
      d36: data['d36'],
      d37: data['d37'],
      d38: data['d38'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'd48': d48,
      'd47': d47,
      'd46': d46,
      'd45': d45,
      'd44': d44,
      'd43': d43,
      'd42': d42,
      'd41': d41,
      'd31': d31,
      'd32': d32,
      'd33': d33,
      'd34': d34,
      'd35': d35,
      'd36': d36,
      'd37': d37,
      'd38': d38,
    };
  }
}
