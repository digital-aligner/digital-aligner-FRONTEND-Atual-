class CadastroEnderecoModel {
  int id;
  String endereco;
  String numero;
  String complemento;
  String bairro;
  String pais;
  String cidade;
  String uf;
  String cep;
  String codigoEndereco;

  CadastroEnderecoModel({
    this.id = 0,
    this.endereco = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.pais = '',
    this.cidade = '',
    this.uf = '',
    this.cep = '',
    this.codigoEndereco = '',
  });

  factory CadastroEnderecoModel.fromJson(Map<String, dynamic> data) {
    return CadastroEnderecoModel(
      id: data['id'],
      endereco: data['endereco'],
      numero: data['numero'],
      complemento: data['complemento'],
      bairro: data['bairro'],
      pais: data['pais'],
      cidade: data['cidade'],
      uf: data['uf'],
      cep: data['cep'],
      codigoEndereco: data['codigo_endereco'],
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
      'codigo_endereco': codigoEndereco,
    };
  }
}
