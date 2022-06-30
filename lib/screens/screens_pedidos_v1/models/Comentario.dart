class Comentario {
  int? idPedido;
  String? conteudo;
  DateTime? data;
  int? idAutor;

  Comentario({
    this.idPedido,
    this.conteudo,
    this.data,
    this.idAutor,
  });

  static Comentario fromJson(Map<String, dynamic> json) {
    return new Comentario(
        idPedido: json['idPedido'],
        conteudo: json['conteudo'],
        data: json['data'],
        idAutor: json['idAutor']);
  }

  Map toMap() {
    return {
      "idPedido": this.idPedido,
      "conteudo": this.conteudo,
      "data": this.data,
      "idAutor": this.idAutor
    };
  }
}
