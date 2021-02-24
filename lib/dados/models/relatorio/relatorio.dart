import 'package:digital_aligner_app/dados/models/relatorio/Relatorio_pdf.dart';
import 'package:digital_aligner_app/dados/models/relatorio/Relatorio_ppt.dart';

class Relatorio {
  int id;
  String visualizador3d;
  String visualizador3dOpcao2;
  RelatorioPdf relatorioPdf;
  RelatorioPPT relatorioPPT;
  //Data only viewing
  String codigoPedido;
  String nome;
  String sobrenome;
  String email;
  String cpf;
  String nomePaciente;
  int idPedido;
  int idPaciente;

  Relatorio({
    this.id,
    this.visualizador3d,
    this.visualizador3dOpcao2,
    this.relatorioPdf,
    this.relatorioPPT,
    this.codigoPedido,
    this.nome,
    this.sobrenome,
    this.email,
    this.cpf,
    this.nomePaciente,
    this.idPedido,
    this.idPaciente,
  });

  factory Relatorio.fromJson(Map<String, dynamic> data) {
    return Relatorio(
      id: data['id'],
      visualizador3d: data['visualizador_3d'],
      visualizador3dOpcao2: data['visualizador_3d_opcao_2'],
      relatorioPdf: RelatorioPdf.fromJson(data['relatorio_pdf']),
      relatorioPPT: RelatorioPPT.fromJson(data['relatorio_ppt']),
      codigoPedido: data['codigo_pedido'],
      nome: data['nome'],
      sobrenome: data['sobrenome'],
      email: data['email'],
      cpf: data['cpf'],
      nomePaciente: data['nome_paciente'],
      idPedido: data['id_pedido'],
      idPaciente: data['id_paciente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visualizador_3d': visualizador3d,
      'visualizador_3d_opcao_2': visualizador3dOpcao2,
      'relatorio_pdf': relatorioPdf.toJson(),
      'relatorio_ppt': relatorioPPT.toJson(),
      'codigo_pedido': codigoPedido,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
      'cpf': cpf,
      'nome_paciente': nomePaciente,
      'id_pedido': idPedido,
      'id_paciente': idPaciente,
    };
  }
}
