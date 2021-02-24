class EnderecoUsuario {
  int id;
  String endereco;
  String numero;
  String complemento;
  String bairro;
  String pais;
  String cidade;
  String uf;
  String cep;
  bool isEnderecoPrincipal;

  EnderecoUsuario({
    this.id,
    this.endereco,
    this.numero,
    this.complemento,
    this.bairro,
    this.pais,
    this.cidade,
    this.uf,
    this.cep,
    this.isEnderecoPrincipal,
  });

  factory EnderecoUsuario.fromJson(Map<String, dynamic> data) {
    return EnderecoUsuario(
      id: data['id'],
      endereco: data['endereco'],
      numero: data['numero'],
      complemento: data['complemento'],
      bairro: data['bairro'],
      pais: data['pais'],
      cidade: data['cidade'],
      uf: data['uf'],
      cep: data['cep'],
      isEnderecoPrincipal: data['is_endereco_principal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endereco': endereco,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'pais': pais,
      'cidade': cidade,
      'uf': uf,
      'cep': cep,
      'is_endereco_principal': isEnderecoPrincipal,
    };
  }
}
