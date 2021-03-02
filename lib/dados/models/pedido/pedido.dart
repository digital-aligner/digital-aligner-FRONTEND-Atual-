import 'package:digital_aligner_app/dados/models/pedido/dentes/arcada_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/endereco_usuario.dart';
import 'package:digital_aligner_app/dados/models/pedido/extracao_terceiros_molares.dart';
import 'package:digital_aligner_app/dados/models/pedido/linha_media_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/linha_media_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/modelo_nemo.dart';
import 'package:digital_aligner_app/dados/models/pedido/mordida_aberta_anterior.dart';
import 'package:digital_aligner_app/dados/models/pedido/mordida_cruzada_posterior.dart';
import 'package:digital_aligner_app/dados/models/pedido/radiografias.dart';
import 'package:digital_aligner_app/dados/models/pedido/sobremordida_profunda.dart';
import 'package:digital_aligner_app/dados/models/pedido/vertical_sobremordida_opcionais.dart';

import './modelo_compactado.dart';
import './relacao_canino.dart';
import './sagital_opcionais.dart';

import './relacao_molar.dart';
import './fotografias.dart';
import 'apinhamento/apinhamento.dart';
import 'dentes/arcada_inferior.dart';
import 'modelo_inferior.dart';
import 'modelo_superior.dart';

class Pedido {
  int id;
  bool tratarAmbosArcos;
  bool tratarArcoSuperior;
  bool tratarArcoInferior;
  String queixaDoPaciente;
  RelacaoMolar relacaoMolar;
  RelacaoCanino relacaoCanino;
  SagitalOpcionais sagitalOpcionais;
  SobremordidaProfunda sobremordidaProfunda;
  VerticalSobremordidaOpcionais verticalSobremordidaOpcionais;
  Fotografias fotografias;
  Radiografias radiografias;
  ModeloSuperior modeloSuperior;
  ModeloInferior modeloInferior;
  ModeloCompactado modeloCompactado;
  ModeloNemo modeloNemo;
  MordidaAbertaAnterior mordidaAbertaAnterior;
  MordidaCruzadaPosterior mordidaCruzadaPosterior;
  LinhaMediaSuperior linhaMediaSuperior;
  LinhaMediaInferior linhaMediaInferior;
  Apinhamento apinhamento;
  ArcadaSuperior extracaoVirtualSup;
  ArcadaInferior extracaoVirtualInf;
  ArcadaSuperior naoMovElemSup;
  ArcadaInferior naoMovElemInf;
  ArcadaSuperior naoColocarAttachSup;
  ArcadaInferior naoColocarAttachInf;
  ExtracaoTerceirosMolares extracaoTerceirosMolares;
  int statusPedido;
  bool termosDeUso;
  bool taxaPlanejamento;
  bool modeloDigital;
  bool modeloGesso;
  String orientacoesEspecificas;
  int usersPermissionsUser;
  //Verify if being used
  String enderecoSelecionado;
  EnderecoUsuario enderecoUsuario;
  int paciente;
  String linkModelos;
  int cadistaResponsavel;

  Pedido({
    this.id,
    this.tratarAmbosArcos,
    this.tratarArcoSuperior,
    this.tratarArcoInferior,
    this.queixaDoPaciente,
    this.relacaoMolar,
    this.relacaoCanino,
    this.sagitalOpcionais,
    this.sobremordidaProfunda,
    this.verticalSobremordidaOpcionais,
    this.mordidaAbertaAnterior,
    this.mordidaCruzadaPosterior,
    this.linhaMediaSuperior,
    this.linhaMediaInferior,
    this.apinhamento,
    this.extracaoTerceirosMolares,
    this.extracaoVirtualSup,
    this.extracaoVirtualInf,
    this.naoMovElemSup,
    this.naoMovElemInf,
    this.naoColocarAttachSup,
    this.naoColocarAttachInf,
    this.fotografias,
    this.radiografias,
    this.modeloSuperior,
    this.modeloInferior,
    this.modeloCompactado,
    this.modeloNemo,
    this.statusPedido,
    this.termosDeUso,
    this.taxaPlanejamento,
    this.modeloDigital,
    this.modeloGesso,
    this.orientacoesEspecificas,
    this.usersPermissionsUser,
    this.enderecoUsuario,
    this.paciente,
    this.linkModelos,
    this.cadistaResponsavel,
  });

  factory Pedido.fromJson(Map<String, dynamic> data) {
    return Pedido(
      id: data['id'],
      tratarAmbosArcos: data['tratar_ambos_arcos'],
      tratarArcoSuperior: data['tratar_arco_superior'],
      tratarArcoInferior: data['tratar_arco_inferior'],
      queixaDoPaciente: data['queixa_do_paciente'],
      relacaoMolar: RelacaoMolar.fromJson(data['relacao_molar']),
      relacaoCanino: RelacaoCanino.fromJson(data['relacao_canino']),
      sagitalOpcionais: SagitalOpcionais.fromJson(
        data['sagital_opcionais'],
      ),
      sobremordidaProfunda: SobremordidaProfunda.fromJson(
        data['sobremordida_profunda'],
      ),
      verticalSobremordidaOpcionais: VerticalSobremordidaOpcionais.fromJson(
        data['vertical_sobremordida_opcionais'],
      ),
      mordidaAbertaAnterior: MordidaAbertaAnterior.fromJson(
        data['mordida_aberta_anterior'],
      ),
      mordidaCruzadaPosterior: MordidaCruzadaPosterior.fromJson(
        data['mordida_cruzada_posterior'],
      ),
      linhaMediaSuperior: LinhaMediaSuperior.fromJson(
        data['linha_media_superior'],
      ),
      linhaMediaInferior: LinhaMediaInferior.fromJson(
        data['linha_media_inferior'],
      ),
      apinhamento: Apinhamento.fromJson(data['apinhamento']),
      extracaoTerceirosMolares: ExtracaoTerceirosMolares.fromJson(
        data['extracao_terceiros_molares'],
      ),
      extracaoVirtualSup: ArcadaSuperior.fromJson(data['extracao_virtual_sup']),
      extracaoVirtualInf: ArcadaInferior.fromJson(data['extracao_virtual_inf']),
      naoMovElemSup: ArcadaSuperior.fromJson(data['nao_mov_elem_sup']),
      naoMovElemInf: ArcadaInferior.fromJson(data['nao_mov_elem_inf']),
      naoColocarAttachSup:
          ArcadaSuperior.fromJson(data['nao_colocar_attach_sup']),
      naoColocarAttachInf:
          ArcadaInferior.fromJson(data['nao_colocar_attach_inf']),
      fotografias: Fotografias.fromJson(data['fotografias']),
      radiografias: Radiografias.fromJson(data['radiografias']),
      modeloSuperior: ModeloSuperior.fromJson(data['modelo_superior']),
      modeloInferior: ModeloInferior.fromJson(data['modelo_inferior']),
      modeloCompactado: ModeloCompactado.fromJson(data['modelo_compactado']),
      modeloNemo: ModeloNemo.fromJson(data['modelo_nemo']),
      statusPedido: data['status_pedido'],
      termosDeUso: data['termos_de_uso'],
      taxaPlanejamento: data['taxa_planejamento'],
      modeloDigital: data['modelo_digital'],
      modeloGesso: data['modelo_gesso'],
      orientacoesEspecificas: data['orientacoes_especificas'],
      usersPermissionsUser: data['users_permissions_user'],
      enderecoUsuario: EnderecoUsuario.fromJson(data['endereco_usuario']),
      paciente: data['paciente'],
      linkModelos: data['link_modelos'],
      cadistaResponsavel: data['cadista_responsavel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tratar_ambos_arcos': tratarAmbosArcos,
      'tratar_arco_superior': tratarArcoSuperior,
      'tratar_arco_inferior': tratarArcoInferior,
      'queixa_do_paciente': queixaDoPaciente,
      'relacao_molar': relacaoMolar.toJson(),
      'relacao_canino': relacaoCanino.toJson(),
      'sagital_opcionais': sagitalOpcionais.toJson(),
      'sobremordida_profunda': sobremordidaProfunda.toJson(),
      'vertical_sobremordida_opcionais': verticalSobremordidaOpcionais.toJson(),
      'mordida_aberta_anterior': mordidaAbertaAnterior.toJson(),
      'mordida_cruzada_posterior': mordidaCruzadaPosterior.toJson(),
      'linha_media_superior': linhaMediaSuperior.toJson(),
      'linha_media_inferior': linhaMediaInferior.toJson(),
      'apinhamento': apinhamento.toJson(),
      'extracao_terceiros_molares': extracaoTerceirosMolares.toJson(),
      'extracao_virtual_sup': extracaoVirtualSup.toJson(),
      'extracao_virtual_inf': extracaoVirtualInf.toJson(),
      'nao_mov_elem_sup': naoMovElemSup.toJson(),
      'nao_mov_elem_inf': naoMovElemInf.toJson(),
      'nao_colocar_attach_sup': naoColocarAttachSup.toJson(),
      'nao_colocar_attach_inf': naoColocarAttachInf.toJson(),
      'fotografias': fotografias.toJson(),
      'radiografias': radiografias.toJson(),
      'modelo_superior': modeloSuperior.toJson(),
      'modelo_inferior': modeloInferior.toJson(),
      'modelo_compactado': modeloCompactado.toJson(),
      'modelo_nemo': modeloNemo.toJson(),
      'status_pedido': statusPedido,
      'termos_de_uso': termosDeUso,
      'taxa_planejamento': taxaPlanejamento,
      'modelo_digital': modeloDigital,
      'modelo_gesso': modeloGesso,
      'orientacoes_especificas': orientacoesEspecificas,
      'users_permissions_user': usersPermissionsUser,
      'endereco_usuario': enderecoUsuario.toJson(),
      'paciente': paciente,
      'link_modelos': linkModelos,
      'cadista_responsavel': cadistaResponsavel,
    };
  }
}
