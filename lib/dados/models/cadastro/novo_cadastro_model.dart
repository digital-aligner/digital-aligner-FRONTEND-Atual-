class NovoCadastroModel {
  String bairro;
  String celular;
  String cep;
  String cidade;
  String complemento;
  String cro_num;
  String cro_uf;
  String data_nasc;
  String email;
  String endereco;
  String nome;
  String numero;
  String sobrenome;
  String telefone;
  String uf;
  String pais;
  String username;
  String password;

  NovoCadastroModel({
    this.bairro = '',
    this.celular = '',
    this.cep = '',
    this.cidade = '',
    this.complemento = '',
    this.cro_num = '',
    this.cro_uf = '',
    this.data_nasc = '',
    this.email = '',
    this.endereco = '',
    this.nome = '',
    this.numero = '',
    this.sobrenome = '',
    this.telefone = '',
    this.uf = '',
    this.pais = '',
    this.username = '',
    this.password = '',
  });

  factory NovoCadastroModel.fromJson(Map<String, dynamic> data) {
    return NovoCadastroModel(
      bairro: data['bairro'],
      celular: data['celular'],
      cep: data['cep'],
      cidade: data['cidade'],
      complemento: data['complemento'],
      cro_num: data['cro_num'],
      cro_uf: data['cro_uf'],
      data_nasc: data['data_nasc'],
      email: data['email'],
      endereco: data['endereco'],
      nome: data['nome'],
      numero: data['numero'],
      sobrenome: data['sobrenome'],
      telefone: data['telefone'],
      uf: data['uf'],
      pais: data['pais'],
      username: data['username'],
      password: data['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bairro': bairro,
      'celular': celular,
      'cep': cep,
      'cidade': cidade,
      'complemento': complemento,
      'cro_num': cro_num,
      'cro_uf': cro_uf,
      'data_nasc': data_nasc,
      'email': email,
      'endereco': endereco,
      'nome': nome,
      'numero': numero,
      'sobrenome': sobrenome,
      'telefone': telefone,
      'uf': uf,
      'pais': pais,
      'username': username,
      'password': password,
    };
  }
}
