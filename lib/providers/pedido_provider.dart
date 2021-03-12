import 'package:digital_aligner_app/dados/models/pedido/Tipo_procedimento.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/apinhamento.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_dist_desgastes_interproximais.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_dist_dos_dentes_posteriores.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_dist_lado_direito.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_dist_lado_esquerdo.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_expansao_transversal.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/ai_inclin_proj_vest_dos_incisivo.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_inferior/arco_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/arco_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_dist_desgastes_interproximais.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_dist_dos_dentes_posteriores.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_dist_lado_direito.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_dist_lado_esquerdo.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_expansao_transversal.dart';
import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_inclin_proj_vest_dos_incisivo.dart';
import 'package:digital_aligner_app/dados/models/pedido/contracao_arco_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/dentes/arcada_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/dentes/arcada_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/endereco_usuario.dart';
import 'package:digital_aligner_app/dados/models/pedido/expansao_arco_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/extracao_terceiros_molares.dart';
import 'package:digital_aligner_app/dados/models/pedido/linha_media_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/linha_media_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/modelo_compactado.dart';
import 'package:digital_aligner_app/dados/models/pedido/modelo_inferior.dart';
import 'package:digital_aligner_app/dados/models/pedido/modelo_nemo.dart';
import 'package:digital_aligner_app/dados/models/pedido/modelo_superior.dart';
import 'package:digital_aligner_app/dados/models/pedido/mordida_aberta_anterior.dart';
import 'package:digital_aligner_app/dados/models/pedido/mordida_cruzada_posterior.dart';
import 'package:digital_aligner_app/dados/models/pedido/opcionais_mordida_cruz_post.dart';
import 'package:digital_aligner_app/dados/models/pedido/paciente.dart';
import 'package:digital_aligner_app/dados/models/pedido/radiografias.dart';
import 'package:digital_aligner_app/dados/models/pedido/sagital_opcionais.dart';
import 'package:digital_aligner_app/dados/models/pedido/sobremordida_profunda.dart';
import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';
import 'package:digital_aligner_app/dados/models/pedido/vertical_sobremordida_opcionais.dart';
import 'package:digital_aligner_app/widgets/file_uploads/compactado_model.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_inferior.dart';
import 'package:digital_aligner_app/widgets/file_uploads/modelo_superior.dart';
import 'package:digital_aligner_app/widgets/file_uploads/nemo_model.dart';
import 'package:digital_aligner_app/widgets/file_uploads/radiografia_model.dart';

import '../dados/models/pedido/relacao_canino.dart';
import '../widgets/file_uploads/photo_model.dart';

import '../dados/models/pedido/fotografias.dart';

import '../dados/models/pedido/relacao_molar.dart';

import '../dados/models/pedido/pedido.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';
import 'package:flutter/widgets.dart';

class PedidoProvider with ChangeNotifier {
  //---- GERENCIAR PEDIDO END ------

  Pedido _pedido;
  Fotografias _fotografias = Fotografias();
  Radiografias _radiografias = Radiografias();
  ModeloSuperior _modeloSuperior = ModeloSuperior();
  ModeloInferior _modeloInferior = ModeloInferior();
  ModeloCompactado _modeloCompactado = ModeloCompactado();
  ModeloNemo _modeloNemo = ModeloNemo();

  Paciente _paciente;

  int _usersPermissionsUser = 0;
  //only for editing pedido
  int _pedidoId;

  void setUserId(int value) {
    _usersPermissionsUser = value;
  }

  void setPedidoId(int value) {
    _pedidoId = value;
  }

  //Obs: can send null to server. Don't need to inicial value.
  int _cadistaResponsavel;

  void setCadistaResponsavelId(int value) {
    _cadistaResponsavel = value;
  }

  String _token;

  Map<String, dynamic> _fotografiasMap = Map<String, dynamic>();
  Map<String, dynamic> _radiografiasMap = Map<String, dynamic>();
  Map<String, dynamic> _modeloSuperiorMap = Map<String, dynamic>();
  Map<String, dynamic> _modeloInferiorMap = Map<String, dynamic>();
  Map<String, dynamic> _modeloCompactadoMap = Map<String, dynamic>();
  Map<String, dynamic> _modeloNemoMap = Map<String, dynamic>();

  //For async update on photo widget
  Map<String, dynamic> getTheMap() {
    return _fotografiasMap;
  }

  void setToken(String t) {
    _token = t;
  }

  void _fieldsToObj(int pedidoId) {
    // 1 dados iniciais - map radio to bool value
    // 1 tratar ambos, 2 apenas superior, 3 apenas inf
    bool _ftoTratarAmbos;
    bool _ftoApenasSuperior;
    bool _ftoApenasInferior;
    if (_tratarRadio == 1) {
      _ftoTratarAmbos = true;
    } else if (_tratarRadio == 2) {
      _ftoApenasSuperior = true;
    } else if (_tratarRadio == 3) {
      _ftoApenasInferior = true;
    } else {
      _ftoApenasInferior = null;
    }

    // --------------------------
    //PedidoId will only be passed when using atualizarCadastro
    _pedido = Pedido(
      id: pedidoId,
      tratarAmbosArcos: _ftoTratarAmbos,
      tratarArcoSuperior: _ftoApenasSuperior,
      tratarArcoInferior: _ftoApenasInferior,
      queixaDoPaciente: _diPrincipalQueixa,
      relacaoMolar: RelacaoMolar(
        id: null,
        ladoDireito: StatusCorrecao(
          id: _rmLd,
        ),
        ladoEsquerdo: StatusCorrecao(
          id: _rmLe,
        ),
        superiorDireito: TipoProcedimento(
          id: _rmSd,
        ),
        superiorEsquerdo: TipoProcedimento(
          id: _rmSe,
        ),
        inferiorDireito: TipoProcedimento(
          id: _rmId,
        ),
        inferiorEsquerdo: TipoProcedimento(
          id: _rmIe,
        ),
        outro: _rmOutro,
      ),
      relacaoCanino: RelacaoCanino(
        id: null,
        ladoDireito: StatusCorrecao(
          id: _rcLd,
        ),
        ladoEsquerdo: StatusCorrecao(
          id: _rcLe,
        ),
        superiorDireito: TipoProcedimento(
          id: _rcSd,
        ),
        superiorEsquerdo: TipoProcedimento(
          id: _rcSe,
        ),
        inferiorDireito: TipoProcedimento(
          id: _rcId,
        ),
        inferiorEsquerdo: TipoProcedimento(
          id: _rcIe,
        ),
        outro: _rcOutro,
      ),
      sagitalOpcionais: SagitalOpcionais(
        id: null,
        desgastesInterproximais: _sgOpAceitoDesgastes,
        recorteElasticoAlinhador: _sgOpRecorteElastico,
        recorteAlinhadorBotao: _sgOpRecorteAlinhador,
        alivioAlinhadorBracoForca: _sgOpAlivioAlinhador,
        localRecElastAlinh: _localRecElastAlinh,
        localRecAlinhBotao: _localRecAlinhBotao,
        localAlivioAlinhador: _localAlivioAlinhador,
      ),
      sobremordidaProfunda: SobremordidaProfunda(
        id: null,
        statusCorrecao: StatusCorrecao(
          id: _verticalSMP,
        ),
        intrusaoDentesAnterioresSup: _idaSupMm,
        intrusaoDentesAnterioresInf: _idaInfMm,
        extrusaoDentesPosterioresSup: _edpSupMm,
        extrusaoDentesPosterioresInf: _edpInfMm,
      ),
      verticalSobremordidaOpcionais: VerticalSobremordidaOpcionais(
        id: null,
        batentesMordida: _spBatentesMordida,
        lingualIncisivosSuperiores: _spLingualIncisivo,
        lingualCaninoACaninoSuperior: _spLingualCanino,
        outros: _spOutros,
      ),
      mordidaAbertaAnterior: MordidaAbertaAnterior(
        id: null,
        statusCorrecao: StatusCorrecao(
          id: _verticalMaa,
        ),
        extrusaoDentesAnterioresSup: _maaEdaSupMm,
        extrusaoDentesAnterioresInf: _maaEdaInfMm,
        intrusaoDentesPosterioresSup: _maaIdpSupMm,
        intrusaoDentesPosterioresInf: _maaIdpInfMm,
      ),
      mordidaCruzadaPosterior: MordidaCruzadaPosterior(
        statusCorrecao: StatusCorrecao(
          id: _mordidaCruzPostRadio,
        ),
        expansaoArcoSuperior: ExpansaoArcoSuperior(
          id: null,
          direito: _easDireito,
          esquerdo: _easEsquerdo,
          movimentoDeCorpo: _easMovimentoCorpo,
          inclinacaoTorque: _easInclinacaoTorque,
        ),
        contracaoArcoInferior: ContracaoArcoInferior(
          id: null,
          direito: _caiDireito,
          esquerdo: _caiEsquerdo,
          movimentoDeCorpo: _caiMovimentoCorpo,
          inclinacaoTorque: _caiInclinacaoTorque,
        ),
        opcionaisMordidaCruzPost: OpcionaisMordidaCruzPost(
          id: null,
          recorteElasticoAlinhador: _mcpRecorteElastico,
          recorteAlinhadorBotao: _mcpRecorteAlinhador,
        ),
      ),
      linhaMediaSuperior: LinhaMediaSuperior(
        id: null,
        moverDireita: _lmSupDireitaMm,
        moverEsquerda: _lmSupEsquerdaMm,
        statusCorrecao: StatusCorrecao(
          id: _linhaMediaSup,
        ),
      ),
      linhaMediaInferior: LinhaMediaInferior(
        id: null,
        moverDireita: _lmInfDireitaMm,
        moverEsquerda: _lmInfEsquerdaMm,
        statusCorrecao: StatusCorrecao(
          id: _linhaMediaInf,
        ),
      ),
      apinhamento: Apinhamento(
        statusCorrecao: StatusCorrecao(
          id: _tratarApinRadio,
        ),
        id: null,
        ausenciaApinhamento: _ausenciaApinhamento,
        arcoSuperior: ArcoSuperior(
          id: null,
          asInclinProjVestDosIncisivo: AsInclinProjVestDosIncisivo(
            id: null,
            ate8graus2mm: _incProjArcoSupApinAte8graus2mm,
            qtoNecessarioEvitarDip: _incProjArcoSupApinQtoNecessario,
            outros: _incProjArcoSupApinOutros,
          ),
          asExpansaoTransversal: AsExpansaoTransversal(
            id: null,
            ate2_5mmPorLado: _expArcoSupApinAte2_5mmPorLado,
            qtoNecessarioEvitarDip: _expArcoSupApinQtoNecessario,
          ),
          asDistDosDentesPosteriores: AsDistDosDentesPosteriores(
            id: null,
            asDistDesgastesInterproximais: AsDistDesgastesInterproximais(
              id: null,
              ate3mm: _distDPASADesInterAte3mm,
              ate5mm: _distDPASADesInterAte5mm,
              qtoNecessarioEvitarDip: _distDPASADesInterQtoNecessario,
              outros: _distDPASADesInterOutros,
            ),
            asDistLadoDireito: AsDistLadoDireito(
              id: null,
              ate1_5mm: _distDPASADirAte1_5mm,
              ate3mm: _distDPASADirAte3mm,
              outros: _distDPASADirOutros,
              qtoNecessarioEvitarDip: _distDPASADirQtoNecessario,
            ),
            asDistLadoEsquerdo: AsDistLadoEsquerdo(
              id: null,
              ate1_5mm: _distDPASAEsqAte1_5mm,
              ate3mm: _distDPASAEsqAte3mm,
              outros: _distDPASAEsqOutros,
              qtoNecessarioEvitarDip: _distDPASAEsqQtoNecessario,
            ),
          ),
        ),
        arcoInferior: ArcoInferior(
          id: null,
          aiInclinProjVestDosIncisivo: AiInclinProjVestDosIncisivo(
            id: null,
            ate8graus2mm: _incProjArcoInfApinAte8graus2mm,
            qtoNecessarioEvitarDip: _incProjArcoInfApinQtoNecessario,
            outros: _incProjArcoInfApinOutros,
          ),
          aiExpansaoTransversal: AiExpansaoTransversal(
            id: null,
            ate2_5mmPorLado: _expArcoInfApinAte2_5mmPorLado,
            qtoNecessarioEvitarDip: _expArcoInfApinQtoNecessario,
          ),
          aiDistDosDentesPosteriores: AiDistDosDentesPosteriores(
            id: null,
            aiDistDesgastesInterproximais: AiDistDesgastesInterproximais(
              id: null,
              ate3mm: _distDPAIADesInterAte3mm,
              ate5mm: _distDPAIADesInterAte5mm,
              qtoNecessarioEvitarDip: _distDPAIADesInterQtoNecessario,
              outros: _distDPAIADesInterOutros,
            ),
            aiDistLadoDireito: AiDistLadoDireito(
              id: null,
              ate1_5mm: _distDPAIADirAte1_5mm,
              ate3mm: _distDPAIADirAte3mm,
              outros: _distDPAIADirOutros,
              qtoNecessarioEvitarDip: _distDPAIADirQtoNecessario,
            ),
            aiDistLadoEsquerdo: AiDistLadoEsquerdo(
              id: null,
              ate1_5mm: _distDPAIAEsqAte1_5mm,
              ate3mm: _distDPAIAEsqAte3mm,
              outros: _distDPAIAEsqOutros,
              qtoNecessarioEvitarDip: _distDPAIAEsqQtoNecessario,
            ),
          ),
        ),
      ),
      extracaoTerceirosMolares: ExtracaoTerceirosMolares(
        id: null,
        sim: _exTerceiroMolaresSim,
        nao: _exTerceiroMolaresNao,
      ),
      extracaoVirtualSup: ArcadaSuperior(
        id: null,
        d18: _evsD18,
        d17: _evsD17,
        d16: _evsD16,
        d15: _evsD15,
        d14: _evsD14,
        d13: _evsD13,
        d12: _evsD12,
        d11: _evsD11,
        d21: _evsD21,
        d22: _evsD22,
        d23: _evsD23,
        d24: _evsD24,
        d25: _evsD25,
        d26: _evsD26,
        d27: _evsD27,
        d28: _evsD28,
      ),
      extracaoVirtualInf: ArcadaInferior(
        id: null,
        d48: _eviD48,
        d47: _eviD47,
        d46: _eviD46,
        d45: _eviD45,
        d44: _eviD44,
        d43: _eviD43,
        d42: _eviD42,
        d41: _eviD41,
        d31: _eviD31,
        d32: _eviD32,
        d33: _eviD33,
        d34: _eviD34,
        d35: _eviD35,
        d36: _eviD36,
        d37: _eviD37,
        d38: _eviD38,
      ),
      naoMovElemSup: ArcadaSuperior(
        id: null,
        d18: _nmsD18,
        d17: _nmsD17,
        d16: _nmsD16,
        d15: _nmsD15,
        d14: _nmsD14,
        d13: _nmsD13,
        d12: _nmsD12,
        d11: _nmsD11,
        d21: _nmsD21,
        d22: _nmsD22,
        d23: _nmsD23,
        d24: _nmsD24,
        d25: _nmsD25,
        d26: _nmsD26,
        d27: _nmsD27,
        d28: _nmsD28,
      ),
      naoMovElemInf: ArcadaInferior(
        id: null,
        d48: _nmiD48,
        d47: _nmiD47,
        d46: _nmiD46,
        d45: _nmiD45,
        d44: _nmiD44,
        d43: _nmiD43,
        d42: _nmiD42,
        d41: _nmiD41,
        d31: _nmiD31,
        d32: _nmiD32,
        d33: _nmiD33,
        d34: _nmiD34,
        d35: _nmiD35,
        d36: _nmiD36,
        d37: _nmiD37,
        d38: _nmiD38,
      ),
      naoColocarAttachSup: ArcadaSuperior(
        id: null,
        d18: _ncasD18,
        d17: _ncasD17,
        d16: _ncasD16,
        d15: _ncasD15,
        d14: _ncasD14,
        d13: _ncasD13,
        d12: _ncasD12,
        d11: _ncasD11,
        d21: _ncasD21,
        d22: _ncasD22,
        d23: _ncasD23,
        d24: _ncasD24,
        d25: _ncasD25,
        d26: _ncasD26,
        d27: _ncasD27,
        d28: _ncasD28,
      ),
      naoColocarAttachInf: ArcadaInferior(
        id: null,
        d48: _ncaiD48,
        d47: _ncaiD47,
        d46: _ncaiD46,
        d45: _ncaiD45,
        d44: _ncaiD44,
        d43: _ncaiD43,
        d42: _ncaiD42,
        d41: _ncaiD41,
        d31: _ncaiD31,
        d32: _ncaiD32,
        d33: _ncaiD33,
        d34: _ncaiD34,
        d35: _ncaiD35,
        d36: _ncaiD36,
        d37: _ncaiD37,
        d38: _ncaiD38,
      ),
      fotografias: _fotografias,
      radiografias: _radiografias,
      modeloSuperior: _modeloSuperior,
      modeloInferior: _modeloInferior,
      modeloCompactado: _modeloCompactado,
      modeloNemo: _modeloNemo,
      statusPedido: _statusId,
      termosDeUso: _termos,
      taxaPlanejamento: true,
      modeloDigital: _modeloDigital,
      modeloGesso: _modeloGesso,
      orientacoesEspecificas: _orientacoesEsp,
      enderecoUsuario: EnderecoUsuario(id: _idEnderecoUsuario),
      usersPermissionsUser: _usersPermissionsUser,
      paciente: _pacienteId,
      linkModelos: _linkModelos,
      cadistaResponsavel: _cadistaResponsavel,
    );
  }

  String _linkModelos;

  void setLinkModelos(String value) {
    _linkModelos = value;
  }

  String getLinkModelos() {
    return _linkModelos;
  }

  //For novo pedido in painel
  int _pacienteId;

  void setPacienteId(int value) {
    _pacienteId = value;
  }

  Map<String, dynamic> _objToJsonRequest() {
    _paciente = Paciente(
      id: _pacienteId,
      nomePaciente: _nomeDoPaciente,
      dataNascimento: _dataNascimento,
      usersPermissionsUser: _usersPermissionsUser,
    );

    Map<String, dynamic> _jsonRequest = {
      'pedido': _pedido.toJson(),
      'paciente': _paciente.toJson(),
    };

    return _jsonRequest;
  }

  Future<dynamic> enviarPaciente() async {
    _fieldsToObj(null);
    Map<String, dynamic> _jsonRequest = _objToJsonRequest();
    print(_jsonRequest);

    var _response = await http.post(RotasUrl.rotaNovoPaciente,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(_jsonRequest));

    List<dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Future<dynamic> enviarNovoPedido() async {
    _fieldsToObj(null);
    Map<String, dynamic> _jsonRequest = _objToJsonRequest();
    print(_jsonRequest);

    var _response = await http.post(RotasUrl.rotaNovoPedido,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(_jsonRequest));

    List<dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Future<dynamic> enviarNovoRefinamento() async {
    _fieldsToObj(null);
    Map<String, dynamic> _jsonRequest = _objToJsonRequest();
    print(_jsonRequest);

    var _response = await http.post(RotasUrl.rotaNovoRefinamento,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(_jsonRequest));

    List<dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Future<dynamic> atualizarPedido(int pedidoId) async {
    _fieldsToObj(pedidoId);
    Map<String, dynamic> _jsonRequest = _objToJsonRequest();
    print(_jsonRequest);

    var _response = await http.put(RotasUrl.rotaNovoPaciente,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(_jsonRequest));

    List<dynamic> _data = json.decode(_response.body);
    return _data;
  }

  void setPhotosList(List<PhotoModel> list) {
    _fotografiasMap = Fotografias().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _fotografias = Fotografias();
      return;
    }
    //Map photoslist to Fotografias object
    for (var i = 1; i <= list.length; i++) {
      String _photoVarName = 'foto' + i.toString();
      String _photoVarNameId = 'foto${i.toString()}_id';

      //foto1 through foto16 (store url)
      _fotografiasMap[_photoVarName] = list[i - 1].imageUrl;
      //fotoId1 through fotoId16 (store id)
      _fotografiasMap[_photoVarNameId] = list[i - 1].id;
    }
    // Convert new map to Fotografias object
    _fotografias = Fotografias.fromJson(_fotografiasMap);
  }

  void setRadiografiasList(List<RadiografiaModel> list) {
    _radiografiasMap = Radiografias().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _radiografias = Radiografias();
      return;
    }
    //Map radiografiaslist to radiografias object
    for (var i = 1; i <= list.length; i++) {
      String _photoVarName = 'foto' + i.toString();
      String _photoVarNameId = 'foto${i.toString()}_id';

      //foto1 through foto4 (store url)
      _radiografiasMap[_photoVarName] = list[i - 1].imageUrl;
      //fotoId1 through fotoId4 (store id)
      _radiografiasMap[_photoVarNameId] = list[i - 1].id;
    }
    // Convert new map to radiografias object
    _radiografias = Radiografias.fromJson(_radiografiasMap);
  }

  void setModeloSuperiorList(List<ModeloSuperiorModel> list) {
    _modeloSuperiorMap = ModeloSuperior().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _modeloSuperior = ModeloSuperior();
      return;
    }
    //Map modelosuplist to modelosup object
    for (var i = 1; i <= list.length; i++) {
      String _modeloSupName = 'modelo_superior';
      String _modeloSupId = 'modelo_superior_id';

      //modelosup1 through 1 (store url)
      _modeloSuperiorMap[_modeloSupName] = list[i - 1].imageUrl;
      //modelosup1 through modelosupId1 (store id)
      _modeloSuperiorMap[_modeloSupId] = list[i - 1].id;
    }
    // Convert new map to modelosup object
    _modeloSuperior = ModeloSuperior.fromJson(_modeloSuperiorMap);
  }

  void setModeloInferiorList(List<ModeloInferiorModel> list) {
    _modeloInferiorMap = ModeloInferior().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _modeloInferior = ModeloInferior();
      return;
    }
    //Map modeloinflist to modeloinf object
    for (var i = 1; i <= list.length; i++) {
      String _modeloInfName = 'modelo_inferior';
      String _modeloInfId = 'modelo_inferior_id';

      //modeloinf1 through 1 (store url)
      _modeloInferiorMap[_modeloInfName] = list[i - 1].imageUrl;
      //modeloinf1 through modeloinfId1 (store id)
      _modeloInferiorMap[_modeloInfId] = list[i - 1].id;
    }
    // Convert new map to modelosup object
    _modeloInferior = ModeloInferior.fromJson(_modeloInferiorMap);
  }

  void setModeloCompactadoList(List<CompactadoModel> list) {
    _modeloCompactadoMap = ModeloCompactado().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _modeloCompactado = ModeloCompactado();
      return;
    }
    //Map modelocompactList to modelocompact object
    for (var i = 1; i <= list.length; i++) {
      String _modeloCompName = 'modelo_compactado';
      String _modeloCompId = 'modelo_compactado_id';

      //modeloComp1 through 1 (store url)
      _modeloCompactadoMap[_modeloCompName] = list[i - 1].imageUrl;
      //modeloComp1 through modeloCompId1 (store id)
      _modeloCompactadoMap[_modeloCompId] = list[i - 1].id;
    }
    // Convert new map to modeloComp object
    _modeloCompactado = ModeloCompactado.fromJson(_modeloCompactadoMap);
  }

  void setModeloNemoList(List<NemoModel> list) {
    _modeloNemoMap = ModeloNemo().toJson();
    //If list recieved is null, remove any items left in provider
    if (list == null) {
      _modeloNemo = ModeloNemo();
      return;
    }
    //Map modelocompactList to modelocompact object
    for (var i = 1; i <= list.length; i++) {
      String _modeloNemoName = 'modelo_nemo';
      String _modeloNemoId = 'modelo_nemo_id';

      //modeloNemo1 through 1 (store url)
      _modeloNemoMap[_modeloNemoName] = list[i - 1].imageUrl;
      //modeloNemo1 through modeloNemo1Id1 (store id)
      _modeloNemoMap[_modeloNemoId] = list[i - 1].id;
    }
    // Convert new map to modeloComp object
    _modeloNemo = ModeloNemo.fromJson(_modeloNemoMap);
  }

  // 1 - DADOS INICIAIS ---------------------------
  String _nomeDoPaciente;
  String _dataNascimento;
  String _diPrincipalQueixa;
  int _tratarRadio = 0;

  void setTratarRadio(int value, String radName) {
    switch (radName) {
      case '_tratarRadio':
        _tratarRadio = value;
        notifyListeners();
        print(_tratarRadio);
        break;
      default:
        return null;
    }
  }

  int getTratarRadioValue(String radName) {
    switch (radName) {
      case '_tratarRadio':
        return _tratarRadio;
      default:
        return null;
    }
  }

  void setNomePaciente(String nome) {
    _nomeDoPaciente = nome;
  }

  String getNomePaciente() {
    return _nomeDoPaciente;
  }

  void setDataNasc(DateTime data) {
    _dataNascimento = data.toString();
  }

  DateTime getDataNasc() {
    return _dataNascimento != null ? DateTime.parse(_dataNascimento) : null;
  }

  void setDiPrincipalQueixa(String value) {
    _diPrincipalQueixa = value;
  }

  String getDiPrincipalQueixa() {
    return _diPrincipalQueixa;
  }

  // 2 - SAGITAL ---------------------------

  // Relação Molar
  bool _rmLdState = false;
  bool _rmLeState = false;
  String _rmOutro;
  int _rmLd = 0;
  int _rmLe = 0;
  int _rmSd = 0;
  int _rmId = 0;
  int _rmSe = 0;
  int _rmIe = 0;

  void setRmOutro(String value) {
    _rmOutro = value;
  }

  String getRmOutro() {
    return _rmOutro;
  }

  bool getRmLdState() {
    return _rmLdState;
  }

  bool getRmLeState() {
    return _rmLeState;
  }

  void manageRmLadoDireito() {
    if (_rmLd == 1) {
      _rmLdState = false;
      _rmSd = 0;
      _rmId = 0;
    } else {
      _rmLdState = true;
    }

    notifyListeners();
  }

  void manageRmLadoEsquerdo() {
    if (_rmLe == 1) {
      _rmLeState = false;
      _rmSe = 0;
      _rmIe = 0;
    } else {
      _rmLeState = true;
    }

    notifyListeners();
  }

  void setRmRadio(int value, String radName) {
    switch (radName) {
      case '_rmLd':
        _rmLd = value;
        notifyListeners();
        print(_rmLd);
        break;
      case '_rmLe':
        _rmLe = value;
        notifyListeners();
        print(_rmLe);
        break;
      case '_rmSd':
        _rmSd = value;
        notifyListeners();
        print(_rmSd);
        break;
      case '_rmId':
        _rmId = value;
        notifyListeners();
        print(_rmId);
        break;
      case '_rmSe':
        _rmSe = value;
        notifyListeners();
        print(_rmSe);
        break;
      case '_rmIe':
        _rmIe = value;
        notifyListeners();
        print(_rmIe);
        break;
      default:
        return null;
    }
  }

  int getRmRadioValue(String radName) {
    switch (radName) {
      case '_rmLd':
        return _rmLd;
      case '_rmLe':
        return _rmLe;
      case '_rmSd':
        return _rmSd;
      case '_rmId':
        return _rmId;
      case '_rmSe':
        return _rmSe;
      case '_rmIe':
        return _rmIe;
      default:
        return null;
    }
  }

  // Relação Canino
  bool _rcLdState = false;
  bool _rcLeState = false;
  String _rcOutro;
  int _rcLd = 0;
  int _rcLe = 0;
  int _rcSd = 0;
  int _rcId = 0;
  int _rcSe = 0;
  int _rcIe = 0;

  void setRcOutro(String value) {
    _rcOutro = value;
  }

  String getRcOutro() {
    return _rcOutro;
  }

  bool getRcLdState() {
    return _rcLdState;
  }

  bool getRcLeState() {
    return _rcLeState;
  }

  void manageRcLadoDireito() {
    if (_rcLd == 1) {
      _rcLdState = false;
      _rcSd = 0;
      _rcId = 0;
    } else {
      _rcLdState = true;
    }

    notifyListeners();
  }

  void manageRcLadoEsquerdo() {
    if (_rcLe == 1) {
      _rcLeState = false;
      _rcSe = 0;
      _rcIe = 0;
    } else {
      _rcLeState = true;
    }

    notifyListeners();
  }

  void setRcRadio(int value, String radName) {
    switch (radName) {
      case '_rcLd':
        _rcLd = value;
        notifyListeners();
        print(_rcLd);
        break;
      case '_rcLe':
        _rcLe = value;
        notifyListeners();
        print(_rcLe);
        break;
      case '_rcSd':
        _rcSd = value;
        notifyListeners();
        print(_rcSd);
        break;
      case '_rcId':
        _rcId = value;
        notifyListeners();
        print(_rcId);
        break;
      case '_rcSe':
        _rcSe = value;
        notifyListeners();
        print(_rcSe);
        break;
      case '_rcIe':
        _rcIe = value;
        notifyListeners();
        print(_rcIe);
        break;
      default:
        return null;
    }
  }

  int getRcRadioValue(String radName) {
    switch (radName) {
      case '_rcLd':
        return _rcLd;
      case '_rcLe':
        return _rcLe;
      case '_rcSd':
        return _rcSd;
      case '_rcId':
        return _rcId;
      case '_rcSe':
        return _rcSe;
      case '_rcIe':
        return _rcIe;
      default:
        return null;
    }
  }

  // Opcionais
  bool _sgOpAceitoDesgastes = false;
  bool _sgOpRecorteElastico = false;
  bool _sgOpRecorteAlinhador = false;
  bool _sgOpAlivioAlinhador = false;

  String _localRecElastAlinh = '';
  String _localRecAlinhBotao = '';
  String _localAlivioAlinhador = '';

  String getLocalRecElastAlinh() {
    return _localRecElastAlinh;
  }

  String getLocalRecAlinhBotao() {
    return _localRecAlinhBotao;
  }

  String getLocalAlivioAlinhador() {
    return _localAlivioAlinhador;
  }

  void setLocalRecElastAlinh(String value) {
    _localRecElastAlinh = value;
  }

  void setLocalRecAlinhBotao(String value) {
    _localRecAlinhBotao = value;
  }

  void setLocalAlivioAlinhador(String value) {
    _localAlivioAlinhador = value;
  }

  bool getSgOpAceitoDesgastes() {
    return _sgOpAceitoDesgastes;
  }

  void setSgOpAceitoDesgastes(bool value) {
    _sgOpAceitoDesgastes = value;

    notifyListeners();
  }

  bool getSgOpRecorteElastico() {
    return _sgOpRecorteElastico;
  }

  void setSgOpRecorteElastico(bool value) {
    _sgOpRecorteElastico = value;

    notifyListeners();
  }

  bool getSgOpRecorteAlinhador() {
    return _sgOpRecorteAlinhador;
  }

  void setSgOpRecorteAlinhador(bool value) {
    _sgOpRecorteAlinhador = value;

    notifyListeners();
  }

  bool getSgOpAlivioAlinhador() {
    return _sgOpAlivioAlinhador;
  }

  void setSgOpAlivioAlinhador(bool value) {
    _sgOpAlivioAlinhador = value;

    notifyListeners();
  }

// 3 - VERTICAL ---------------------------

//sobremordida profunda
  bool _sobremordidaState = false;
  bool _idaSupState = false;
  bool _idaInfState = false;
  bool _edpSupState = false;
  bool _edpInfState = false;

  int _verticalSMP = 0;

  int _idaSup = 0;
  int _idaInf = 0;
  int _edpSup = 0;
  int _edpInf = 0;

  // number values in mm
  String _idaSupMm = '';
  String _idaInfMm = '';
  String _edpSupMm = '';
  String _edpInfMm = '';

  // Opcionais sobremordida profunda
  bool _spBatentesMordida = false;
  bool _spLingualIncisivo = false;
  bool _spLingualCanino = false;
  String _spOutros;

  String getSpOutros() {
    return _spOutros;
  }

  void setSpOutros(String value) {
    _spOutros = value;
  }

  void manageOpcSbrMordProfState() {
    if (_spBatentesMordida == false) {
      _spLingualIncisivo = false;
      _spLingualCanino = false;
      _spOutros = '';
      notifyListeners();
    }
  }

  getSpBatentesMordida() {
    return _spBatentesMordida;
  }

  getSpLingualIncisivo() {
    return _spLingualIncisivo;
  }

  getSpLingualCanino() {
    return _spLingualCanino;
  }

  void setSpBatentesMordida(bool value) {
    _spBatentesMordida = value;
    notifyListeners();
  }

  void setSpLingualIncisivo(bool value) {
    _spLingualIncisivo = value;
    notifyListeners();
  }

  void setSpLingualCanino(bool value) {
    _spLingualCanino = value;
    notifyListeners();
  }

  void setIdaSup(String value) {
    _idaSupMm = value;
  }

  void setIdaInf(String value) {
    _idaInfMm = value;
  }

  void setEdpSup(String value) {
    _edpSupMm = value;
  }

  void setEdpInf(String value) {
    _edpInfMm = value;
  }

  String getIdaSup() {
    return _idaSupMm;
  }

  String getIdaInf() {
    return _idaInfMm;
  }

  String getEdpSup() {
    return _edpSupMm;
  }

  String getEdpInf() {
    return _edpInfMm;
  }

  bool getIdaSupState() {
    return _idaSupState;
  }

  bool getIdaInfState() {
    return _idaInfState;
  }

  bool getEdpSupState() {
    return _edpSupState;
  }

  bool getEdpInfState() {
    return _edpInfState;
  }

  bool getSobremordidaState() {
    return _sobremordidaState;
  }

  void setSbmpRadio(int value, String radName) {
    switch (radName) {
      case '_idaSup':
        if (value == null) {
          _idaSup = 0;
          _idaSupMm = '';
          _idaSupState = false;
          notifyListeners();
          print(_idaSup);
        } else {
          _idaSup = value;
          _idaSupState = true;
          notifyListeners();
          print(_idaSup);
        }
        break;
      case '_idaInf':
        if (value == null) {
          _idaInf = 0;
          _idaInfMm = '';
          _idaInfState = false;
          notifyListeners();
          print(_idaInf);
        } else {
          _idaInf = value;
          _idaInfState = true;
          notifyListeners();
          print(_idaInf);
        }
        break;
      case '_edpSup':
        if (value == null) {
          _edpSup = 0;
          _edpSupMm = '';
          _edpSupState = false;
          notifyListeners();
          print(_edpSup);
        } else {
          _edpSup = value;
          _edpSupState = true;
          notifyListeners();
          print(_edpSup);
        }
        break;
      case '_edpInf':
        if (value == null) {
          _edpInf = 0;
          _edpInfMm = '';
          _edpInfState = false;
          notifyListeners();
          print(_edpInf);
        } else {
          _edpInf = value;
          _edpInfState = true;
          notifyListeners();
          print(_edpInf);
        }
        break;
      default:
        return null;
    }
  }

  int getSbmpRadioValue(String radName) {
    switch (radName) {
      case '_idaSup':
        return _idaSup;
      case '_idaInf':
        return _idaInf;
      case '_edpSup':
        return _edpSup;
      case '_edpInf':
        return _edpInf;
      default:
        return null;
    }
  }

  int getVerticalSbmpRadio() {
    return _verticalSMP;
  }

  void setVerticalSbmpRadio(int value) {
    _verticalSMP = value;
    notifyListeners();
  }

  void manageFormSbmp() {
    if (_verticalSMP == 1) {
      _sobremordidaState = false;
      _idaSupState = false;
      _idaInfState = false;
      _edpSupState = false;
      _edpInfState = false;
      _idaSup = 0;
      _idaInf = 0;
      _edpSup = 0;
      _edpInf = 0;

      _idaSupMm = '';
      _idaInfMm = '';
      _edpSupMm = '';
      _edpInfMm = '';
    } else {
      _sobremordidaState = true;
    }

    notifyListeners();
  }

  //Mordida aberta anterior
  bool _mordidaAbertaAntState = false;
  bool _maaIdpSupState = false;
  bool _maaIdpInfState = false;
  bool _maaEdaSupState = false;
  bool _maaEdaInfState = false;

  int _verticalMaa = 0;

  int _maaIdpSup = 0;
  int _maaIdpInf = 0;
  int _maaEdaSup = 0;
  int _maaEdaInf = 0;

  // number values in mm
  String _maaIdpSupMm = '';
  String _maaIdpInfMm = '';
  String _maaEdaSupMm = '';
  String _maaEdaInfMm = '';

  void setMaaIdpSup(String value) {
    _maaIdpSupMm = value;
  }

  void setMaaIdpInf(String value) {
    _maaIdpInfMm = value;
  }

  void setMaaEdaSup(String value) {
    _maaEdaSupMm = value;
  }

  void setMaaEdaInf(String value) {
    _maaEdaInfMm = value;
  }

  String getMaaIdpSup() {
    return _maaIdpSupMm;
  }

  String getMaaIdpInf() {
    return _maaIdpInfMm;
  }

  String getMaaEdaSup() {
    return _maaEdaSupMm;
  }

  String getMaaEdaInf() {
    return _maaEdaInfMm;
  }

  bool getMaaIdpSupState() {
    return _maaIdpSupState;
  }

  bool getMaaIdpInfState() {
    return _maaIdpInfState;
  }

  bool getMaaEdaSupState() {
    return _maaEdaSupState;
  }

  bool getMaaEdaInfState() {
    return _maaEdaInfState;
  }

  bool getMordidaAbertaAntState() {
    return _mordidaAbertaAntState;
  }

  void setMaaRadio(int value, String radName) {
    switch (radName) {
      case '_maaIdpSup':
        if (value == null) {
          _maaIdpSup = 0;
          _maaIdpSupMm = '';
          _maaIdpSupState = false;
          notifyListeners();
          print(_maaIdpSup);
        } else {
          _maaIdpSup = value;
          _maaIdpSupState = true;
          notifyListeners();
          print(_maaIdpSup);
        }
        break;
      case '_maaIdpInf':
        if (value == null) {
          _maaIdpInf = 0;
          _maaIdpInfMm = '';
          _maaIdpInfState = false;
          notifyListeners();
          print(_maaIdpInf);
        } else {
          _maaIdpInf = value;
          _maaIdpInfState = true;
          notifyListeners();
          print(_maaIdpInf);
        }
        break;
      case '_maaEdaSup':
        if (value == null) {
          _maaEdaSup = 0;
          _maaEdaSupMm = '';
          _maaEdaSupState = false;
          notifyListeners();
          print(_maaEdaSup);
        } else {
          _maaEdaSup = value;
          _maaEdaSupState = true;
          notifyListeners();
          print(_maaEdaSup);
        }
        break;
      case '_maaEdaInf':
        if (value == null) {
          _maaEdaInf = 0;
          _maaEdaInfMm = '';
          _maaEdaInfState = false;
          notifyListeners();
          print(_maaEdaInf);
        } else {
          _maaEdaInf = value;
          _maaEdaInfState = true;
          notifyListeners();
          print(_maaEdaInf);
        }
        break;
      default:
        return null;
    }
  }

  int getMaaRadioValue(String radName) {
    switch (radName) {
      case '_maaIdpSup':
        return _maaIdpSup;
      case '_maaIdpInf':
        return _maaIdpInf;
      case '_maaEdaSup':
        return _maaEdaSup;
      case '_maaEdaInf':
        return _maaEdaInf;
      default:
        return null;
    }
  }

  int getVerticalMaaRadio() {
    return _verticalMaa;
  }

  void setVerticalMaaRadio(int value) {
    _verticalMaa = value;
    notifyListeners();
  }

  void manageFormMaa() {
    if (_verticalMaa == 1) {
      _mordidaAbertaAntState = false;
      _maaIdpSupState = false;
      _maaIdpInfState = false;
      _maaEdaSupState = false;
      _maaEdaInfState = false;
      _maaIdpSup = 0;
      _maaIdpInf = 0;
      _maaEdaSup = 0;
      _maaEdaInf = 0;

      _maaIdpSupMm = '';
      _maaIdpInfMm = '';
      _maaEdaSupMm = '';
      _maaEdaInfMm = '';
    } else {
      _mordidaAbertaAntState = true;
    }

    notifyListeners();
  }

// 4 - TRANSVERSAL ---------------------------

//Mordida Cruzada posterior
  bool _mordidaCruzPost = false;
  int _mordidaCruzPostRadio = 0;

  bool getMordidaCruzPost() {
    return _mordidaCruzPost;
  }

  void setMordidaCruzPostRadio(int value) {
    _mordidaCruzPostRadio = value;
    notifyListeners();
  }

  int getMordidaCruzPostRadio() {
    return _mordidaCruzPostRadio;
  }

  void manageFormMcp() {
    if (_mordidaCruzPostRadio == 1) {
      _mordidaCruzPost = false;
      _easDireito = false;
      _easEsquerdo = false;
      _easMovimentoCorpo = false;
      _easInclinacaoTorque = false;

      _caiDireito = false;
      _caiEsquerdo = false;
      _caiMovimentoCorpo = false;
      _caiInclinacaoTorque = false;
    } else {
      _mordidaCruzPost = true;
    }

    notifyListeners();
  }

  // expransão arco superior
  bool _easDireito = false;
  bool _easEsquerdo = false;
  bool _easMovimentoCorpo = false;
  bool _easInclinacaoTorque = false;

  bool getEasInclinacaoTorque() {
    return _easInclinacaoTorque;
  }

  void setEasInclinacaoTorque(bool value) {
    _easInclinacaoTorque = value;
    notifyListeners();
  }

  bool getEasMovimentoCorpo() {
    return _easMovimentoCorpo;
  }

  void setEasMovimentoCorpo(bool value) {
    _easMovimentoCorpo = value;
    notifyListeners();
  }

  bool getEasEsquerdo() {
    return _easEsquerdo;
  }

  void setEasEsquerdo(bool value) {
    _easEsquerdo = value;
    notifyListeners();
  }

  bool getEasDireito() {
    return _easDireito;
  }

  void setEasDireito(bool value) {
    _easDireito = value;
    notifyListeners();
  }

  //contração arco inferior

  bool _caiDireito = false;
  bool _caiEsquerdo = false;
  bool _caiMovimentoCorpo = false;
  bool _caiInclinacaoTorque = false;

  bool getCaiInclinacaoTorque() {
    return _caiInclinacaoTorque;
  }

  void setCaiInclinacaoTorque(bool value) {
    _caiInclinacaoTorque = value;
    notifyListeners();
  }

  bool getCaiMovimentoCorpo() {
    return _caiMovimentoCorpo;
  }

  void setCaiMovimentoCorpo(bool value) {
    _caiMovimentoCorpo = value;
    notifyListeners();
  }

  bool getCaiEsquerdo() {
    return _caiEsquerdo;
  }

  void setCaiEsquerdo(bool value) {
    _caiEsquerdo = value;
    notifyListeners();
  }

  bool getCaiDireito() {
    return _caiDireito;
  }

  void setCaiDireito(bool value) {
    _caiDireito = value;
    notifyListeners();
  }

  //(transversal) Mordida cruzada posterior opcionais

  bool _mcpRecorteElastico = false;
  bool _mcpRecorteAlinhador = false;

  String _localMcpRecElastAlinh = '';
  String _localMcpRecAlinhBotao = '';

  String getLocalMcpRecElastAlinh() {
    return _localMcpRecElastAlinh;
  }

  String getLocalMcpRecAlinhBotao() {
    return _localMcpRecAlinhBotao;
  }

  void setLocalMcpRecElastAlinh(String value) {
    _localMcpRecElastAlinh = value;
  }

  void setLocalMcpRecAlinhBotao(String value) {
    _localMcpRecAlinhBotao = value;
  }

  bool getMcpRecorteElastico() {
    return _mcpRecorteElastico;
  }

  void setMcpRecorteElastico(bool value) {
    _mcpRecorteElastico = value;
    notifyListeners();
  }

  bool getMcpRecorteAlinhador() {
    return _mcpRecorteAlinhador;
  }

  void setMcpRecorteAlinhador(bool value) {
    _mcpRecorteAlinhador = value;
    notifyListeners();
  }

  //Linha média
  //superior
  // Corrigir or Manter
  bool _linhaMediaSupState = false;
  int _linhaMediaSup = 0;

  bool _lmSupDireitaState = false;
  bool _lmSupEsquerdaState = false;
  int _lmSupDireita = 0;
  int _lmSupEsquerda = 0;

  //New value for changes to functionality 25/02/21
  int _lmSupNovo = 0;

  // number values in mm
  String _lmSupDireitaMm = '';
  String _lmSupEsquerdaMm = '';

  void setLmSupDireita(int value) {
    _lmSupDireita = value;
  }

  void setLmSupEsquerda(int value) {
    _lmSupEsquerda = value;
  }

  int getLmSupDireita() {
    return _lmSupDireita;
  }

  int getLmSupEsquerda() {
    return _lmSupEsquerda;
  }

  void setLmSupDireitaMm(String value) {
    _lmSupDireitaMm = value;
  }

  void setLmSupEsquerdaMm(String value) {
    _lmSupEsquerdaMm = value;
  }

  String getLmSupDireitaMm() {
    return _lmSupDireitaMm;
  }

  String getLmSupEsquerdaMm() {
    return _lmSupEsquerdaMm;
  }

  bool getLmSupDireitaState() {
    return _lmSupDireitaState;
  }

  bool getLmSupEsquerdaState() {
    return _lmSupEsquerdaState;
  }

  bool getLinhaMediaSupState() {
    return _linhaMediaSupState;
  }

  void setLmSupRadio(int value, String radName) {
    switch (radName) {
      case '_lmSupDireita':
        //For updated functionality 25/02/21
        //_lmSupDireita = value;
        _lmSupNovo = value;
        _lmSupDireitaState = true;
        //block the other side
        _lmSupEsquerdaState = false;
        // remove its value
        _lmSupEsquerdaMm = '';

        notifyListeners();
        print(_lmSupDireita);
        break;
      case '_lmSupEsquerda':
        //For updated functionality 25/02/21
        //_lmSupEsquerda = value;
        _lmSupNovo = value;
        _lmSupEsquerdaState = true;
        //block the other side
        _lmSupDireitaState = false;
        //remove its value
        _lmSupDireitaMm = '';
        notifyListeners();
        print(_lmSupEsquerda);
        break;
      default:
        return null;
    }
  }

  int getLmSupRadioValue(String radName) {
    if (radName == null) {
      return _lmSupNovo;
    }
    return null;
    /*
    switch (radName) {
      case '_lmSupDireita':
        return _lmSupDireita;
      case '_lmSupEsquerda':
        return _lmSupEsquerda;
      default:
        return null;
    }*/
  }

  int getLinhaMediaSupRadio() {
    return _linhaMediaSup;
  }

  //For the manter/corrigir radio
  void setLinhaMediaSupRadio(int value) {
    _linhaMediaSup = value;
    notifyListeners();
  }

  void manageFormLmSup() {
    if (_linhaMediaSup == 1) {
      _linhaMediaSupState = false;
      _lmSupDireitaState = false;
      _lmSupEsquerdaState = false;
      //_lmSupDireita = 0;
      //_lmSupEsquerda = 0;
      _lmSupNovo = 0;
      _lmSupDireitaMm = '';
      _lmSupEsquerdaMm = '';
    } else {
      _linhaMediaSupState = true;
    }

    notifyListeners();
  }

//------------ inferior ------------------------------------------

// Corrigir or Manter
  bool _linhaMediaInfState = false;
  int _linhaMediaInf = 0;

  bool _lmInfDireitaState = false;
  bool _lmInfEsquerdaState = false;
  int _lmInfDireita = 0;
  int _lmInfEsquerda = 0;

  //New value for changes to functionality 25/02/21
  int _lmInfNovo = 0;

// number values in mm
  String _lmInfDireitaMm = '';
  String _lmInfEsquerdaMm = '';

  void setLmInfDireita(int value) {
    _lmInfDireita = value;
  }

  void setLmInfEsquerda(int value) {
    _lmInfEsquerda = value;
  }

  int getLmInfDireita() {
    return _lmInfDireita;
  }

  int getLmInfEsquerda() {
    return _lmInfEsquerda;
  }

  void setLmInfDireitaMm(String value) {
    _lmInfDireitaMm = value;
  }

  void setLmInfEsquerdaMm(String value) {
    _lmInfEsquerdaMm = value;
  }

  String getLmInfDireitaMm() {
    return _lmInfDireitaMm;
  }

  String getLmInfEsquerdaMm() {
    return _lmInfEsquerdaMm;
  }

  bool getLmInfDireitaState() {
    return _lmInfDireitaState;
  }

  bool getLmInfEsquerdaState() {
    return _lmInfEsquerdaState;
  }

  bool getLinhaMediaInfState() {
    return _linhaMediaInfState;
  }

  void setLmInfRadio(int value, String radName) {
    switch (radName) {
      case '_lmInfDireita':
        //For updated functionality 25/02/21
        //_lmInfDireita = value;
        _lmInfNovo = value;
        _lmInfDireitaState = true;

        //block the other side
        _lmInfEsquerdaState = false;
        // remove its value
        _lmInfEsquerdaMm = '';

        notifyListeners();
        print(_lmInfDireita);
        break;
      case '_lmInfEsquerda':
        //For updated functionality 25/02/21
        _lmInfNovo = value;
        //_lmInfEsquerda = value;
        _lmInfEsquerdaState = true;

        //block the other side
        _lmInfDireitaState = false;
        //remove its value
        _lmInfDireitaMm = '';

        notifyListeners();
        print(_lmInfEsquerda);
        break;
      default:
        return null;
    }
  }

  int getLmInfRadioValue(String radName) {
    if (radName == null) {
      return _lmInfNovo;
    }
    return null;
    /*
    switch (radName) {
      case '_lmInfDireita':
        return _lmInfDireita;
      case '_lmInfEsquerda':
        return _lmInfEsquerda;
      default:
        return null;
    }*/
  }

  int getLinhaMediaInfRadio() {
    return _linhaMediaInf;
  }

  //For the manter/corrigir radio
  void setLinhaMediaInfRadio(int value) {
    _linhaMediaInf = value;
    notifyListeners();
  }

  void manageFormLmInf() {
    if (_linhaMediaInf == 1) {
      _linhaMediaInfState = false;
      _lmInfDireitaState = false;
      _lmInfEsquerdaState = false;
      //_lmInfDireita = 0;
      //_lmInfEsquerda = 0;
      // update functionality 25/02/21
      _lmInfNovo = 0;
      _lmInfDireitaMm = '';
      _lmInfEsquerdaMm = '';
    } else {
      _linhaMediaInfState = true;
    }
    notifyListeners();
  }

  // *PROBLEMAS INDIVIDUAIS*

  void clearApinFields() {
    // Parent radio state
    _corrigirApinSelecionado = false;

    // -------- ARCO SUPERIOR ---------
    // Arco sup -Expansão (transversal)
    clearExpArcoInfFields(clearParentCheckbox: true);
    // Arco sup -Proj/inclin.
    clearIncProjArcoInfFields(clearParentCheckbox: true);
    // Arco sup -dist. dentes post (and child fields)
    clearDistalizacaoInfFields(clearParentCheckbox: true);

    // ------- PROBLEMAS INDIVIDUAIS ---------

    // Arco sup -Expansão (transversal)
    clearExpArcoSupFields(clearParentCheckbox: true);
    // Arco sup -Proj/inclin.
    clearIncProjArcoSupFields(clearParentCheckbox: true);
    // Arco sup -dist. dentes post (and child fields)
    clearDistalizacaoSupFields(clearParentCheckbox: true);

    //don't need to notifylisteners
  }

  bool _ausenciaApinhamento = false;
  int _tratarApinRadio = 0;
  bool _corrigirApinSelecionado = false;

  void setCorrigirApinSelecionado() {
    _corrigirApinSelecionado = true;
    //No need to notify
  }

  bool getCorrigirApinSelecionado() {
    return _corrigirApinSelecionado;
  }

  void setTratarApinRadio(int value, String radName) {
    //Ausencia de apin selected
    if (value == 3) {
      _ausenciaApinhamento = true;
    } else {
      _ausenciaApinhamento = false;
    }

    switch (radName) {
      case '_tratarApinRadio':
        _tratarApinRadio = value;
        notifyListeners();
        print(_tratarApinRadio);
        break;
      default:
        return null;
    }
  }

  int getTratarApinRadioValue(String radName) {
    switch (radName) {
      case '_tratarApinRadio':
        return _tratarApinRadio;
      default:
        return null;
    }
  }

  // ----------- ARCO SUPERIOR --------------

  // ---------- Expansão (transversal) -------------
  //Expansão selected
  bool _expArcoSupApin = false;
  // Fields (expansão)
  int _expArcoSupApinRadio = 0;
  // radio values to bool
  bool _expArcoSupApinAte2_5mmPorLado = false;
  bool _expArcoSupApinQtoNecessario = false;

  void setExpArcoSupApinRadio(int value) {
    _expArcoSupApinRadio = value;
    if (value == 1) {
      _expArcoSupApinAte2_5mmPorLado = true;
      _expArcoSupApinQtoNecessario = false;
    } else {
      _expArcoSupApinAte2_5mmPorLado = false;
      _expArcoSupApinQtoNecessario = true;
    }
    notifyListeners();
  }

  int getExpArcoSupApinRadio() {
    return _expArcoSupApinRadio;
  }

  void setExpArcoSupApin(bool value) {
    _expArcoSupApin = value;
    notifyListeners();
  }

  bool getExpArcoSupApin() {
    return _expArcoSupApin;
  }

  void clearExpArcoSupFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _expArcoSupApin, which also disables is child fields.
      _expArcoSupApin = false;
    }
    // expansão transversal bool values
    _expArcoSupApinAte2_5mmPorLado = false;
    _expArcoSupApinQtoNecessario = false;
    _expArcoSupApinRadio = 0;
    notifyListeners();
  }

  // ---------- Inclinação/projeção -----------
  //Inclinação/projeção selected
  bool _incProjArcoSupApin = false;
  // Fields
  int _incProjArcoSupApinRadio = 0;
  String _incProjArcoSupApinOutros = '';
  // radio field to bools
  bool _incProjArcoSupApinAte8graus2mm = false;
  bool _incProjArcoSupApinQtoNecessario = false;

  void setIncProjArcoSupApinOutros(String value) {
    _incProjArcoSupApinOutros = value;
    //No need to notify listener
  }

  String getIncProjArcoSupApinOutros() {
    return _incProjArcoSupApinOutros;
  }

  void setIncProjArcoSupApinRadio(int value) {
    _incProjArcoSupApinRadio = value;
    if (value == 1) {
      _incProjArcoSupApinAte8graus2mm = true;
      _incProjArcoSupApinQtoNecessario = false;
    } else if (value == 2) {
      _incProjArcoSupApinAte8graus2mm = false;
      _incProjArcoSupApinQtoNecessario = true;
    } else {
      _incProjArcoSupApinAte8graus2mm = false;
      _incProjArcoSupApinQtoNecessario = false;
    }
    notifyListeners();
  }

  int getIncProjArcoSupApinRadio() {
    return _incProjArcoSupApinRadio;
  }

  void setIncProjArcoSupApin(bool value) {
    _incProjArcoSupApin = value;
    notifyListeners();
  }

  bool getIncProjArcoSupApin() {
    return _incProjArcoSupApin;
  }

  void clearIncProjArcoSupFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _incProjArcoSupApin, which also disables is child fields.
      _incProjArcoSupApin = false;
    }
    _incProjArcoSupApinAte8graus2mm = false;
    _incProjArcoSupApinQtoNecessario = false;
    _incProjArcoSupApinRadio = 0;
    _incProjArcoSupApinOutros = '';
    notifyListeners();
  }

  //---------- Distalização dos dentes posteriores -----------

  //Distalização.. selected
  bool _distDentesPostArcoSupApin = false;

  bool getDistDPASupState() {
    return _distDentesPostArcoSupApin;
  }

  void setDistDPASupState(bool value) {
    _distDentesPostArcoSupApin = value;
    notifyListeners();
  }

  void clearDistalizacaoSupFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDentesPostArcoSupApin, which also disables is child fields.
      _distDentesPostArcoSupApin = false;
      notifyListeners();
    }

    clearDistDPASAEsqFields(clearParentCheckbox: true);
    clearDistDPASADirFields(clearParentCheckbox: true);
    clearDistDPASADesInter(clearParentCheckbox: true);
  }

  //------- LADO ESQUERDO -------

  // fields - Lado esquerdo, direito, desgastes interproximais
  bool _distDPASAEsq = false;

  //Lado esquerdo radio options
  int _distDPASAEsqRadio = 0;

  // radio to bool values

  bool _distDPASAEsqAte1_5mm = false;
  bool _distDPASAEsqAte3mm = false;
  bool _distDPASAEsqQtoNecessario = false;

  //Value for field in radio
  String _distDPASAEsqOutros = '';

  String getDistDPASAEsqOutros() {
    return _distDPASAEsqOutros;
  }

  void setDistDPASAEsqOutros(String value) {
    _distDPASAEsqOutros = value;
    //No need to notify listener
  }

  int getDistDPASAEsqRadio() {
    return _distDPASAEsqRadio;
  }

  void setDistDPASAEsqRadio(int value) {
    _distDPASAEsqRadio = value;
    if (value == 1) {
      _distDPASAEsqAte1_5mm = true;
      _distDPASAEsqAte3mm = false;
      _distDPASAEsqQtoNecessario = false;
    } else if (value == 2) {
      _distDPASAEsqAte1_5mm = false;
      _distDPASAEsqAte3mm = true;
      _distDPASAEsqQtoNecessario = false;
    } else if (value == 3) {
      _distDPASAEsqAte1_5mm = false;
      _distDPASAEsqAte3mm = false;
      _distDPASAEsqQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPASAEsqAte1_5mm = false;
      _distDPASAEsqAte3mm = false;
      _distDPASAEsqQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPASAEsq() {
    return _distDPASAEsq;
  }

  void setDistDPASAEsq(bool value) {
    _distDPASAEsq = value;
    notifyListeners();
  }

  void clearDistDPASAEsqFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPASAEsq, which also disables is child fields.
      _distDPASAEsq = false;
    }
    //bool to radio - lado esquerdo (arco sup dentes post)
    _distDPASAEsqAte1_5mm = false;
    _distDPASAEsqAte3mm = false;
    _distDPASAEsqQtoNecessario = false;

    _distDPASAEsqRadio = 0;
    _distDPASAEsqOutros = '';
    notifyListeners();
  }

//------- LADO DIREITO -------

// fields - Lado direito
  bool _distDPASADir = false;

//Lado Direito radio options
  int _distDPASADirRadio = 0;

// radio to bool values

  bool _distDPASADirAte1_5mm = false;
  bool _distDPASADirAte3mm = false;
  bool _distDPASADirQtoNecessario = false;

//Value for field in radio
  String _distDPASADirOutros = '';

  String getDistDPASADirOutros() {
    return _distDPASADirOutros;
  }

  void setDistDPASADirOutros(String value) {
    _distDPASADirOutros = value;
    //No need to notify listener
  }

  int getDistDPASADirRadio() {
    return _distDPASADirRadio;
  }

  void setDistDPASADirRadio(int value) {
    _distDPASADirRadio = value;

    if (value == 1) {
      _distDPASADirAte1_5mm = true;
      _distDPASADirAte3mm = false;
      _distDPASADirQtoNecessario = false;
    } else if (value == 2) {
      _distDPASADirAte1_5mm = false;
      _distDPASADirAte3mm = true;
      _distDPASADirQtoNecessario = false;
    } else if (value == 3) {
      _distDPASADirAte1_5mm = false;
      _distDPASADirAte3mm = false;
      _distDPASADirQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPASADirAte1_5mm = false;
      _distDPASADirAte3mm = false;
      _distDPASADirQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPASADir() {
    return _distDPASADir;
  }

  void setDistDPASADir(bool value) {
    _distDPASADir = value;
    notifyListeners();
  }

  void clearDistDPASADirFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPASADir, which also disables is child fields.
      _distDPASADir = false;
    }
    //bool to radio - lado direito (arco sup dentes post)
    _distDPASADirAte1_5mm = false;
    _distDPASADirAte3mm = false;
    _distDPASADirQtoNecessario = false;

    _distDPASADirRadio = 0;
    _distDPASADirOutros = '';
    notifyListeners();
  }

  //------- DESGASTES INTERPROXIMAIS -------

  // fields - Desgastes interproximais
  bool _distDPASADesInter = false;

  //radio options
  int _distDPASADesInterRadio = 0;

  //radio options to bool
  bool _distDPASADesInterAte3mm = false;
  bool _distDPASADesInterAte5mm = false;
  bool _distDPASADesInterQtoNecessario = false;

  //Value for field in radio
  String _distDPASADesInterOutros = '';

  String getDistDPASADesInterOutros() {
    return _distDPASADesInterOutros;
  }

  void setDistDPASADesInterOutros(String value) {
    _distDPASADesInterOutros = value;
    //No need to notify listener
  }

  int getDistDPASADesInterRadio() {
    return _distDPASADesInterRadio;
  }

  void setDistDPASADesInterRadio(int value) {
    _distDPASADesInterRadio = value;
    if (value == 1) {
      _distDPASADesInterAte3mm = true;
      _distDPASADesInterAte5mm = false;
      _distDPASADesInterQtoNecessario = false;
    } else if (value == 2) {
      _distDPASADesInterAte3mm = false;
      _distDPASADesInterAte5mm = true;
      _distDPASADesInterQtoNecessario = false;
    } else if (value == 3) {
      _distDPASADesInterAte3mm = false;
      _distDPASADesInterAte5mm = false;
      _distDPASADesInterQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPASADesInterAte3mm = false;
      _distDPASADesInterAte5mm = false;
      _distDPASADesInterQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPASADesInter() {
    return _distDPASADesInter;
  }

  void setDistDPASADesInter(bool value) {
    _distDPASADesInter = value;
    notifyListeners();
  }

  void clearDistDPASADesInter({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPASADesInter, which also disables is child fields.
      _distDPASADesInter = false;
    }
    //desgastes inter sup
    _distDPASADesInterAte3mm = false;
    _distDPASADesInterAte5mm = false;
    _distDPASADesInterQtoNecessario = false;
    _distDPASADesInterRadio = 0;
    _distDPASADesInterOutros = '';
    notifyListeners();
  }

// ----------- ARCO INFERIOR --------------

// ---------- Expansão (transversal) -------------
  //Expansão selected
  bool _expArcoInfApin = false;
  // Fields (expansão)
  int _expArcoInfApinRadio = 0;
  // fields to bool values
  bool _expArcoInfApinAte2_5mmPorLado = false;
  bool _expArcoInfApinQtoNecessario = false;

  void setExpArcoInfApinRadio(int value) {
    _expArcoInfApinRadio = value;
    if (value == 1) {
      _expArcoInfApinAte2_5mmPorLado = true;
      _expArcoInfApinQtoNecessario = false;
    } else {
      _expArcoInfApinAte2_5mmPorLado = false;
      _expArcoInfApinQtoNecessario = true;
    }
    notifyListeners();
  }

  int getExpArcoInfApinRadio() {
    return _expArcoInfApinRadio;
  }

  void setExpArcoInfApin(bool value) {
    _expArcoInfApin = value;
    notifyListeners();
  }

  bool getExpArcoInfApin() {
    return _expArcoInfApin;
  }

  void clearExpArcoInfFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _expArcoInfApin, which also disables is child fields.
      _expArcoInfApin = false;
    }
    _expArcoInfApinAte2_5mmPorLado = false;
    _expArcoInfApinQtoNecessario = false;
    _expArcoInfApinRadio = 0;
    notifyListeners();
  }

// ---------- Inclinação/projeção -----------
  //Inclinação/projeção selected
  bool _incProjArcoInfApin = false;
  // Fields
  int _incProjArcoInfApinRadio = 0;
  String _incProjArcoInfApinOutros = '';
  // Radio fields to bool values
  bool _incProjArcoInfApinAte8graus2mm = false;
  bool _incProjArcoInfApinQtoNecessario = false;

  void setIncProjArcoInfApinOutros(String value) {
    _incProjArcoInfApinOutros = value;
    //No need to notify listener
  }

  String getIncProjArcoInfApinOutros() {
    return _incProjArcoInfApinOutros;
  }

  void setIncProjArcoInfApinRadio(int value) {
    _incProjArcoInfApinRadio = value;
    if (value == 1) {
      _incProjArcoInfApinAte8graus2mm = true;
      _incProjArcoInfApinQtoNecessario = false;
    } else if (value == 2) {
      _incProjArcoInfApinAte8graus2mm = true;
      _incProjArcoInfApinQtoNecessario = false;
    } else {
      _incProjArcoInfApinAte8graus2mm = false;
      _incProjArcoInfApinQtoNecessario = false;
    }
    notifyListeners();
  }

  int getIncProjArcoInfApinRadio() {
    return _incProjArcoInfApinRadio;
  }

  void setIncProjArcoInfApin(bool value) {
    _incProjArcoInfApin = value;
    notifyListeners();
  }

  bool getIncProjArcoInfApin() {
    return _incProjArcoInfApin;
  }

  void clearIncProjArcoInfFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _incProjArcoInfApin, which also disables is child fields.
      _incProjArcoInfApin = false;
    }
    _incProjArcoInfApinAte8graus2mm = false;
    _incProjArcoInfApinQtoNecessario = false;
    _incProjArcoInfApinRadio = 0;
    _incProjArcoInfApinOutros = '';
    notifyListeners();
  }

//---------- Distalização dos dentes posteriores -----------

//Distalização.. selected
  bool _distDentesPostArcoInfApin = false;

  bool getDistDPAInfState() {
    return _distDentesPostArcoInfApin;
  }

  void setDistDPAInfState(bool value) {
    _distDentesPostArcoInfApin = value;
    notifyListeners();
  }

  void clearDistalizacaoInfFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDentesPostArcoInfApin, which also disables is child fields.
      _distDentesPostArcoInfApin = false;
      notifyListeners();
    }

    clearDistDPAIAEsqFields(clearParentCheckbox: true);
    clearDistDPAIADirFields(clearParentCheckbox: true);
    clearDistDPAIADesInter(clearParentCheckbox: true);
  }

//------- LADO ESQUERDO -------

// fields - Lado esquerdo, direito, desgastes interproximais
  bool _distDPAIAEsq = false;

//Lado esquerdo radio options
  int _distDPAIAEsqRadio = 0;

//Value for field in radio
  String _distDPAIAEsqOutros = '';
//Radio values to bool
  bool _distDPAIAEsqAte1_5mm = false;
  bool _distDPAIAEsqAte3mm = false;
  bool _distDPAIAEsqQtoNecessario = false;

  String getDistDPAIAEsqOutros() {
    return _distDPAIAEsqOutros;
  }

  void setDistDPAIAEsqOutros(String value) {
    _distDPAIAEsqOutros = value;
    //No need to notify listener
  }

  int getDistDPAIAEsqRadio() {
    return _distDPAIAEsqRadio;
  }

  void setDistDPAIAEsqRadio(int value) {
    _distDPAIAEsqRadio = value;
    if (value == 1) {
      _distDPAIAEsqAte1_5mm = true;
      _distDPAIAEsqAte3mm = false;
      _distDPAIAEsqQtoNecessario = false;
    } else if (value == 2) {
      _distDPAIAEsqAte1_5mm = false;
      _distDPAIAEsqAte3mm = true;
      _distDPAIAEsqQtoNecessario = false;
    } else if (value == 3) {
      _distDPAIAEsqAte1_5mm = false;
      _distDPAIAEsqAte3mm = false;
      _distDPAIAEsqQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPAIAEsqAte1_5mm = false;
      _distDPAIAEsqAte3mm = false;
      _distDPAIAEsqQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPAIAEsq() {
    return _distDPAIAEsq;
  }

  void setDistDPAIAEsq(bool value) {
    _distDPAIAEsq = value;
    notifyListeners();
  }

  void clearDistDPAIAEsqFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPAIAEsq, which also disables is child fields.
      _distDPAIAEsq = false;
    }

    //Bool values clear
    _distDPAIAEsqAte1_5mm = false;
    _distDPAIAEsqAte3mm = false;
    _distDPAIAEsqQtoNecessario = false;

    _distDPAIAEsqRadio = 0;
    _distDPAIAEsqOutros = '';
    notifyListeners();
  }

//------- LADO DIREITO -------

// fields - Lado direito
  bool _distDPAIADir = false;

//Lado Direito radio options
  int _distDPAIADirRadio = 0;

//Value for field in radio
  String _distDPAIADirOutros;

  // radio to bool values
  bool _distDPAIADirAte1_5mm = false;
  bool _distDPAIADirAte3mm = false;
  bool _distDPAIADirQtoNecessario = false;

  String getDistDPAIADirOutros() {
    return _distDPAIADirOutros;
  }

  void setDistDPAIADirOutros(String value) {
    _distDPAIADirOutros = value;
    //No need to notify listener
  }

  int getDistDPAIADirRadio() {
    return _distDPAIADirRadio;
  }

  void setDistDPAIADirRadio(int value) {
    _distDPAIADirRadio = value;
    if (value == 1) {
      _distDPAIADirAte1_5mm = true;
      _distDPAIADirAte3mm = false;
      _distDPAIADirQtoNecessario = false;
    } else if (value == 2) {
      _distDPAIADirAte1_5mm = false;
      _distDPAIADirAte3mm = true;
      _distDPAIADirQtoNecessario = false;
    } else if (value == 3) {
      _distDPAIADirAte1_5mm = false;
      _distDPAIADirAte3mm = false;
      _distDPAIADirQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPAIADirAte1_5mm = false;
      _distDPAIADirAte3mm = false;
      _distDPAIADirQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPAIADir() {
    return _distDPAIADir;
  }

  void setDistDPAIADir(bool value) {
    _distDPAIADir = value;
    notifyListeners();
  }

  void clearDistDPAIADirFields({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPAIADir, which also disables is child fields.
      _distDPAIADir = false;
    }

    _distDPAIADirAte1_5mm = false;
    _distDPAIADirAte3mm = false;
    _distDPAIADirQtoNecessario = false;

    _distDPAIADirRadio = 0;
    _distDPAIADirOutros = '';
    notifyListeners();
  }

  //------- DESGASTES INTERPROXIMAIS -------

  // fields - Desgastes interproximais
  bool _distDPAIADesInter = false;

  //radio options
  int _distDPAIADesInterRadio = 0;

  //radio options to bool
  bool _distDPAIADesInterAte3mm = false;
  bool _distDPAIADesInterAte5mm = false;
  bool _distDPAIADesInterQtoNecessario = false;

  //Value for field in radio
  String _distDPAIADesInterOutros = '';

  String getDistDPAIADesInterOutros() {
    return _distDPAIADesInterOutros;
  }

  void setDistDPAIADesInterOutros(String value) {
    _distDPAIADesInterOutros = value;
    //No need to notify listener
  }

  int getDistDPAIADesInterRadio() {
    return _distDPAIADesInterRadio;
  }

  void setDistDPAIADesInterRadio(int value) {
    _distDPAIADesInterRadio = value;
    if (value == 1) {
      _distDPAIADesInterAte3mm = true;
      _distDPAIADesInterAte5mm = false;
      _distDPAIADesInterQtoNecessario = false;
    } else if (value == 2) {
      _distDPAIADesInterAte3mm = false;
      _distDPAIADesInterAte5mm = true;
      _distDPAIADesInterQtoNecessario = false;
    } else if (value == 3) {
      _distDPAIADesInterAte3mm = false;
      _distDPAIADesInterAte5mm = false;
      _distDPAIADesInterQtoNecessario = true;
    } else {
      //Outros, which is a text value
      _distDPAIADesInterAte3mm = false;
      _distDPAIADesInterAte5mm = false;
      _distDPAIADesInterQtoNecessario = false;
    }
    notifyListeners();
  }

  bool getDistDPAIADesInter() {
    return _distDPAIADesInter;
  }

  void setDistDPAIADesInter(bool value) {
    _distDPAIADesInter = value;
    notifyListeners();
  }

  void clearDistDPAIADesInter({bool clearParentCheckbox}) {
    if (clearParentCheckbox) {
      //clears _distDPAIADesInter, which also disables is child fields.
      _distDPAIADesInter = false;
    }
    //Radio values to bool
    _distDPAIADesInterAte3mm = false;
    _distDPAIADesInterAte5mm = false;
    _distDPAIADesInterQtoNecessario = false;

    _distDPAIADesInterRadio = 0;
    _distDPAIADesInterOutros = '';
    notifyListeners();
  }

  // ------- CONSIDERAÇÕES IMPORTANTES -------

  // Extração dos terceiros molares
  int _exTerceiroMolares = 0;
  bool _exTerceiroMolaresSim = false;
  bool _exTerceiroMolaresNao = false;

  int getExTerceiroMolares() {
    print(_exTerceiroMolares);
    return _exTerceiroMolares;
  }

  void setExTerceiroMolares(int value) {
    _exTerceiroMolares = value;
    if (value == 1) {
      _exTerceiroMolaresSim = true;
      _exTerceiroMolaresNao = false;
    } else {
      _exTerceiroMolaresSim = false;
      _exTerceiroMolaresNao = true;
    }

    notifyListeners();
  }

  bool getDentalMethod(String type, int value) {
    if (type == 'extracao virtual') {
      if (type == 'extracao virtual' && value == 18) {
        return _evsD18;
      }
      if (type == 'extracao virtual' && value == 17) {
        return _evsD17;
      }
      if (type == 'extracao virtual' && value == 16) {
        return _evsD16;
      }
      if (type == 'extracao virtual' && value == 15) {
        return _evsD15;
      }
      if (type == 'extracao virtual' && value == 14) {
        return _evsD14;
      }
      if (type == 'extracao virtual' && value == 13) {
        return _evsD13;
      }
      if (type == 'extracao virtual' && value == 12) {
        return _evsD12;
      }
      if (type == 'extracao virtual' && value == 11) {
        return _evsD11;
      }

      if (type == 'extracao virtual' && value == 21) {
        return _evsD21;
      }
      if (type == 'extracao virtual' && value == 22) {
        return _evsD22;
      }
      if (type == 'extracao virtual' && value == 23) {
        return _evsD23;
      }
      if (type == 'extracao virtual' && value == 24) {
        return _evsD24;
      }
      if (type == 'extracao virtual' && value == 25) {
        return _evsD25;
      }
      if (type == 'extracao virtual' && value == 26) {
        return _evsD26;
      }
      if (type == 'extracao virtual' && value == 27) {
        return _evsD27;
      }
      if (type == 'extracao virtual' && value == 28) {
        return _evsD28;
      }

      if (type == 'extracao virtual' && value == 48) {
        return _eviD48;
      }
      if (type == 'extracao virtual' && value == 47) {
        return _eviD47;
      }
      if (type == 'extracao virtual' && value == 46) {
        return _eviD46;
      }
      if (type == 'extracao virtual' && value == 45) {
        return _eviD45;
      }
      if (type == 'extracao virtual' && value == 44) {
        return _eviD44;
      }
      if (type == 'extracao virtual' && value == 43) {
        return _eviD43;
      }
      if (type == 'extracao virtual' && value == 42) {
        return _eviD42;
      }
      if (type == 'extracao virtual' && value == 41) {
        return _eviD41;
      }

      if (type == 'extracao virtual' && value == 31) {
        return _eviD31;
      }
      if (type == 'extracao virtual' && value == 32) {
        return _eviD32;
      }
      if (type == 'extracao virtual' && value == 33) {
        return _eviD33;
      }
      if (type == 'extracao virtual' && value == 34) {
        return _eviD34;
      }
      if (type == 'extracao virtual' && value == 35) {
        return _eviD35;
      }
      if (type == 'extracao virtual' && value == 36) {
        return _eviD36;
      }
      if (type == 'extracao virtual' && value == 37) {
        return _eviD37;
      }
      if (type == 'extracao virtual' && value == 38) {
        return _eviD38;
      }
    }

    if (type == 'nao movimentar') {
      if (type == 'nao movimentar' && value == 18) {
        return _nmsD18;
      }
      if (type == 'nao movimentar' && value == 17) {
        return _nmsD17;
      }
      if (type == 'nao movimentar' && value == 16) {
        return _nmsD16;
      }
      if (type == 'nao movimentar' && value == 15) {
        return _nmsD15;
      }
      if (type == 'nao movimentar' && value == 14) {
        return _nmsD14;
      }
      if (type == 'nao movimentar' && value == 13) {
        return _nmsD13;
      }
      if (type == 'nao movimentar' && value == 12) {
        return _nmsD12;
      }
      if (type == 'nao movimentar' && value == 11) {
        return _nmsD11;
      }

      if (type == 'nao movimentar' && value == 21) {
        return _nmsD21;
      }
      if (type == 'nao movimentar' && value == 22) {
        return _nmsD22;
      }
      if (type == 'nao movimentar' && value == 23) {
        return _nmsD23;
      }
      if (type == 'nao movimentar' && value == 24) {
        return _nmsD24;
      }
      if (type == 'nao movimentar' && value == 25) {
        return _nmsD25;
      }
      if (type == 'nao movimentar' && value == 26) {
        return _nmsD26;
      }
      if (type == 'nao movimentar' && value == 27) {
        return _nmsD27;
      }
      if (type == 'nao movimentar' && value == 28) {
        return _nmsD28;
      }

      if (type == 'nao movimentar' && value == 48) {
        return _nmiD48;
      }
      if (type == 'nao movimentar' && value == 47) {
        return _nmiD47;
      }
      if (type == 'nao movimentar' && value == 46) {
        return _nmiD46;
      }
      if (type == 'nao movimentar' && value == 45) {
        return _nmiD45;
      }
      if (type == 'nao movimentar' && value == 44) {
        return _nmiD44;
      }
      if (type == 'nao movimentar' && value == 43) {
        return _nmiD43;
      }
      if (type == 'nao movimentar' && value == 42) {
        return _nmiD42;
      }
      if (type == 'nao movimentar' && value == 41) {
        return _nmiD41;
      }

      if (type == 'nao movimentar' && value == 31) {
        return _nmiD31;
      }
      if (type == 'nao movimentar' && value == 32) {
        return _nmiD32;
      }
      if (type == 'nao movimentar' && value == 33) {
        return _nmiD33;
      }
      if (type == 'nao movimentar' && value == 34) {
        return _nmiD34;
      }
      if (type == 'nao movimentar' && value == 35) {
        return _nmiD35;
      }
      if (type == 'nao movimentar' && value == 36) {
        return _nmiD36;
      }
      if (type == 'nao movimentar' && value == 37) {
        return _nmiD37;
      }
      if (type == 'nao movimentar' && value == 38) {
        return _nmiD38;
      }
    }

    if (type == 'nao colocar attach') {
      if (type == 'nao colocar attach' && value == 18) {
        return _ncasD18;
      }
      if (type == 'nao colocar attach' && value == 17) {
        return _ncasD17;
      }
      if (type == 'nao colocar attach' && value == 16) {
        return _ncasD16;
      }
      if (type == 'nao colocar attach' && value == 15) {
        return _ncasD15;
      }
      if (type == 'nao colocar attach' && value == 14) {
        return _ncasD14;
      }
      if (type == 'nao colocar attach' && value == 13) {
        return _ncasD13;
      }
      if (type == 'nao colocar attach' && value == 12) {
        return _ncasD12;
      }
      if (type == 'nao colocar attach' && value == 11) {
        return _ncasD11;
      }

      if (type == 'nao colocar attach' && value == 21) {
        return _ncasD21;
      }
      if (type == 'nao colocar attach' && value == 22) {
        return _ncasD22;
      }
      if (type == 'nao colocar attach' && value == 23) {
        return _ncasD23;
      }
      if (type == 'nao colocar attach' && value == 24) {
        return _ncasD24;
      }
      if (type == 'nao colocar attach' && value == 25) {
        return _ncasD25;
      }
      if (type == 'nao colocar attach' && value == 26) {
        return _ncasD26;
      }
      if (type == 'nao colocar attach' && value == 27) {
        return _ncasD27;
      }
      if (type == 'nao colocar attach' && value == 28) {
        return _ncasD28;
      }

      if (type == 'nao colocar attach' && value == 48) {
        return _ncaiD48;
      }
      if (type == 'nao colocar attach' && value == 47) {
        return _ncaiD47;
      }
      if (type == 'nao colocar attach' && value == 46) {
        return _ncaiD46;
      }
      if (type == 'nao colocar attach' && value == 45) {
        return _ncaiD45;
      }
      if (type == 'nao colocar attach' && value == 44) {
        return _ncaiD44;
      }
      if (type == 'nao colocar attach' && value == 43) {
        return _ncaiD43;
      }
      if (type == 'nao colocar attach' && value == 42) {
        return _ncaiD42;
      }
      if (type == 'nao colocar attach' && value == 41) {
        return _ncaiD41;
      }

      if (type == 'nao colocar attach' && value == 31) {
        return _ncaiD31;
      }
      if (type == 'nao colocar attach' && value == 32) {
        return _ncaiD32;
      }
      if (type == 'nao colocar attach' && value == 33) {
        return _ncaiD33;
      }
      if (type == 'nao colocar attach' && value == 34) {
        return _ncaiD34;
      }
      if (type == 'nao colocar attach' && value == 35) {
        return _ncaiD35;
      }
      if (type == 'nao colocar attach' && value == 36) {
        return _ncaiD36;
      }
      if (type == 'nao colocar attach' && value == 37) {
        return _ncaiD37;
      }
      if (type == 'nao colocar attach' && value == 38) {
        return _ncaiD38;
      }
    }
    return null;
  }

  void setDentalMethod({String type, int value, checkboxValue}) {
    if (type == 'extracao virtual') {
      if (type == 'extracao virtual' && value == 18) {
        _evsD18 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 17) {
        _evsD17 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 16) {
        _evsD16 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 15) {
        _evsD15 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 14) {
        _evsD14 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 13) {
        _evsD13 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 12) {
        _evsD12 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 11) {
        _evsD11 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 21) {
        _evsD21 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 22) {
        _evsD22 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 23) {
        _evsD23 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 24) {
        _evsD24 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 25) {
        _evsD25 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 26) {
        _evsD26 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 27) {
        _evsD27 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 28) {
        _evsD28 = checkboxValue;
      }

      if (type == 'extracao virtual' && value == 48) {
        _eviD48 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 47) {
        _eviD47 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 46) {
        _eviD46 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 45) {
        _eviD45 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 44) {
        _eviD44 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 43) {
        _eviD43 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 42) {
        _eviD42 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 41) {
        _eviD41 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 31) {
        _eviD31 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 32) {
        _eviD32 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 33) {
        _eviD33 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 34) {
        _eviD34 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 35) {
        _eviD35 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 36) {
        _eviD36 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 37) {
        _eviD37 = checkboxValue;
      }
      if (type == 'extracao virtual' && value == 38) {
        _eviD38 = checkboxValue;
      }
    }
    if (type == 'nao movimentar') {
      if (type == 'nao movimentar' && value == 18) {
        _nmsD18 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 17) {
        _nmsD17 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 16) {
        _nmsD16 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 15) {
        _nmsD15 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 14) {
        _nmsD14 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 13) {
        _nmsD13 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 12) {
        _nmsD12 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 11) {
        _nmsD11 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 21) {
        _nmsD21 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 22) {
        _nmsD22 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 23) {
        _nmsD23 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 24) {
        _nmsD24 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 25) {
        _nmsD25 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 26) {
        _nmsD26 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 27) {
        _nmsD27 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 28) {
        _nmsD28 = checkboxValue;
      }

      if (type == 'nao movimentar' && value == 48) {
        _nmiD48 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 47) {
        _nmiD47 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 46) {
        _nmiD46 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 45) {
        _nmiD45 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 44) {
        _nmiD44 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 43) {
        _nmiD43 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 42) {
        _nmiD42 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 41) {
        _nmiD41 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 31) {
        _nmiD31 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 32) {
        _nmiD32 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 33) {
        _nmiD33 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 34) {
        _nmiD34 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 35) {
        _nmiD35 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 36) {
        _nmiD36 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 37) {
        _nmiD37 = checkboxValue;
      }
      if (type == 'nao movimentar' && value == 38) {
        _nmiD38 = checkboxValue;
      }
    }
    if (type == 'nao colocar attach') {
      if (type == 'nao colocar attach' && value == 18) {
        _ncasD18 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 17) {
        _ncasD17 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 16) {
        _ncasD16 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 15) {
        _ncasD15 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 14) {
        _ncasD14 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 13) {
        _ncasD13 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 12) {
        _ncasD12 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 11) {
        _ncasD11 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 21) {
        _ncasD21 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 22) {
        _ncasD22 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 23) {
        _ncasD23 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 24) {
        _ncasD24 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 25) {
        _ncasD25 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 26) {
        _ncasD26 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 27) {
        _ncasD27 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 28) {
        _ncasD28 = checkboxValue;
      }

      if (type == 'nao colocar attach' && value == 48) {
        _ncaiD48 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 47) {
        _ncaiD47 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 46) {
        _ncaiD46 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 45) {
        _ncaiD45 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 44) {
        _ncaiD44 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 43) {
        _ncaiD43 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 42) {
        _ncaiD42 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 41) {
        _ncaiD41 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 31) {
        _ncaiD31 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 32) {
        _ncaiD32 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 33) {
        _ncaiD33 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 34) {
        _ncaiD34 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 35) {
        _ncaiD35 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 36) {
        _ncaiD36 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 37) {
        _ncaiD37 = checkboxValue;
      }
      if (type == 'nao colocar attach' && value == 38) {
        _ncaiD38 = checkboxValue;
      }
    }

    notifyListeners();
  }

  //Extração virtual dos seguintes dentes
  //Superior
  bool _evsD18 = false;
  bool _evsD17 = false;
  bool _evsD16 = false;
  bool _evsD15 = false;
  bool _evsD14 = false;
  bool _evsD13 = false;
  bool _evsD12 = false;
  bool _evsD11 = false;
  bool _evsD21 = false;
  bool _evsD22 = false;
  bool _evsD23 = false;
  bool _evsD24 = false;
  bool _evsD25 = false;
  bool _evsD26 = false;
  bool _evsD27 = false;
  bool _evsD28 = false;

  //Inferior
  bool _eviD48 = false;
  bool _eviD47 = false;
  bool _eviD46 = false;
  bool _eviD45 = false;
  bool _eviD44 = false;
  bool _eviD43 = false;
  bool _eviD42 = false;
  bool _eviD41 = false;
  bool _eviD31 = false;
  bool _eviD32 = false;
  bool _eviD33 = false;
  bool _eviD34 = false;
  bool _eviD35 = false;
  bool _eviD36 = false;
  bool _eviD37 = false;
  bool _eviD38 = false;

  //Não movimentar seguintes elementos

  //Superior
  bool _nmsD18 = false;
  bool _nmsD17 = false;
  bool _nmsD16 = false;
  bool _nmsD15 = false;
  bool _nmsD14 = false;
  bool _nmsD13 = false;
  bool _nmsD12 = false;
  bool _nmsD11 = false;
  bool _nmsD21 = false;
  bool _nmsD22 = false;
  bool _nmsD23 = false;
  bool _nmsD24 = false;
  bool _nmsD25 = false;
  bool _nmsD26 = false;
  bool _nmsD27 = false;
  bool _nmsD28 = false;

  //Inferior
  bool _nmiD48 = false;
  bool _nmiD47 = false;
  bool _nmiD46 = false;
  bool _nmiD45 = false;
  bool _nmiD44 = false;
  bool _nmiD43 = false;
  bool _nmiD42 = false;
  bool _nmiD41 = false;
  bool _nmiD31 = false;
  bool _nmiD32 = false;
  bool _nmiD33 = false;
  bool _nmiD34 = false;
  bool _nmiD35 = false;
  bool _nmiD36 = false;
  bool _nmiD37 = false;
  bool _nmiD38 = false;

  //Não colocar attachmentes nos seguintes elementos

  //Superior
  bool _ncasD18 = false;
  bool _ncasD17 = false;
  bool _ncasD16 = false;
  bool _ncasD15 = false;
  bool _ncasD14 = false;
  bool _ncasD13 = false;
  bool _ncasD12 = false;
  bool _ncasD11 = false;
  bool _ncasD21 = false;
  bool _ncasD22 = false;
  bool _ncasD23 = false;
  bool _ncasD24 = false;
  bool _ncasD25 = false;
  bool _ncasD26 = false;
  bool _ncasD27 = false;
  bool _ncasD28 = false;

  //Inferior
  bool _ncaiD48 = false;
  bool _ncaiD47 = false;
  bool _ncaiD46 = false;
  bool _ncaiD45 = false;
  bool _ncaiD44 = false;
  bool _ncaiD43 = false;
  bool _ncaiD42 = false;
  bool _ncaiD41 = false;
  bool _ncaiD31 = false;
  bool _ncaiD32 = false;
  bool _ncaiD33 = false;
  bool _ncaiD34 = false;
  bool _ncaiD35 = false;
  bool _ncaiD36 = false;
  bool _ncaiD37 = false;
  bool _ncaiD38 = false;

  // --------- FORMATOS MODELOS -------------
  //Digital ou Gesso

  int _formatoModelos = 0;
  bool _modeloDigital = false;
  bool _modeloGesso = false;

  int getFormatoModelos() {
    return _formatoModelos;
  }

  void setFormatoModelos(int value) {
    _formatoModelos = value;
    if (value == 1) {
      _modeloDigital = true;
      _modeloGesso = false;
    } else {
      _modeloDigital = false;
      _modeloGesso = true;
    }
    notifyListeners();
  }

  // ---------- ENDEREÇO ENTREGA --------------
  //This section is on novo pedido or novo paciente
  int _idEnderecoUsuario;

  int getIdEnderecoUsuario() {
    return _idEnderecoUsuario;
  }

  void setIdEnderecoUsuario(int value) {
    _idEnderecoUsuario = value;
  }

  //Termos
  bool _termos = false;

  void setTermos(bool value) {
    _termos = value;
    notifyListeners();
  }

  bool getTermos() {
    return _termos;
  }

  // Taxa planejamento
  bool _taxaPlanejamento = true;

  void setTaxaPlanejamento(bool value) {
    _taxaPlanejamento = value;
    notifyListeners();
  }

  bool getTaxaPlanejamento() {
    return _taxaPlanejamento;
  }

  // ---------- STATUS PEDIDO --------------
  //Unaltered response map
  List<dynamic> _statusPedido;
  //String list for ui
  List<String> _stringDataList;
  // Always begins with true (will run only once)
  bool _didFetchStatusPedido = false;
  /*
  // Selected status is always "id 2: aguardando relatório" for new Pedidos.
  String _currentStatus = 'Em Analíse';
  int _statusId;
  */
  //New status is empty value
  String _currentStatus = '';
  int _statusId = 0;

  bool isStatusListEmpty() {
    if (_statusPedido != null) {
      return false;
    } else {
      return true;
    }
  }

  bool didFetchStatus() {
    return _didFetchStatusPedido;
  }

  void setDidFetchStatus(bool value) {
    _didFetchStatusPedido = value;
    notifyListeners();
  }

  Future<dynamic> fetchStatusPedido(String _token) async {
    if (_didFetchStatusPedido == false) {
      var _response = await http.get(
        RotasUrl.rotaStatusPedido,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      _statusPedido = json.decode(_response.body);
      _didFetchStatusPedido = true;
      _stringDataList = getStatusPedidoList();
      print('status - Data not in list, fetching and returning');
      return _stringDataList;
    } else {
      print('status - Data already in list');
      return _stringDataList;
    }

    //Getting status aguardando relatório
    //notifyListeners();
  }

  String getCurrentStatus() {
    return _currentStatus;
  }

  void setCurrentStatus(String value) {
    _currentStatus = value;
    for (int i = 0; i < _statusPedido.length; i++) {
      if (_statusPedido[i]['status'] == value) {
        _statusId = _statusPedido[i]['id'];
      }
    }

    notifyListeners();
  }

  List<String> getStatusPedidoList() {
    List<String> _s = [];
    for (int i = 0; i < _statusPedido.length; i++) {
      if (_statusPedido[i]['id'] == 1) {
        _statusId = _statusPedido[i]['id'];
        _currentStatus = _statusPedido[i]['status'];
      }
      _s.add(_statusPedido[i]['status']);
    }
    return _s;
  }

  // ORIENTAÇÕES ESPECIFICAS
  String _orientacoesEsp = '';

  void setOrientacoesEsp(String value) {
    _orientacoesEsp = value;
    //notifyListeners();
  }

  String getOrientacoesEsp() {
    return _orientacoesEsp;
  }

  bool _blockUi = true;

  void setBlockUi(bool value) {
    _blockUi = value;
    notifyListeners();
  }

  bool getBlockUiState() {
    return _blockUi;
  }

  // SETTING FIELDS (FOR UPDATE SCREEN)
  void setPedido(Map ped) {
    //Set cadista
    //Obs: If the user hasn't selected a cadista previously, will be null.
    //Needs to be verified.
    if (ped['cadista_responsavel'] != null) {
      _cadistaResponsavel = ped['cadista_responsavel']['id'];
    }

    //Link modelos (atualização)
    _linkModelos = ped['link_modelos'];

    //Set paciente id (for updating history in backend)
    _pacienteId = ped['paciente']['id'];

    // 1 - DADOS INICIAIS ---------------------------
    _nomeDoPaciente = ped['paciente']['nome_paciente'];
    _dataNascimento = ped['paciente']['data_nascimento'];
    _diPrincipalQueixa = ped['queixa_do_paciente'];

    if (ped['tratar_ambos_arcos'] == true) {
      _tratarRadio = 1;
    } else if (ped['tratar_arco_superior'] == true) {
      _tratarRadio = 2;
    } else if (ped['tratar_arco_inferior'] == true) {
      _tratarRadio = 3;
    } else {
      _tratarRadio = 0;
    }

    // 2 - SAGITAL ---------------------------
    // Relação Molar
    if (ped['relacao_molar']['lado_direito']['id'] == 1) {
      _rmLd = 1;
      _rmLdState = false;
    } else if (ped['relacao_molar']['lado_direito']['id'] == 2) {
      _rmLdState = true;
      _rmLd = 2;
      _rmSd = ped['relacao_molar']['superior_direito']['id'];
      _rmId = ped['relacao_molar']['inferior_direito']['id'];
    }

    if (ped['relacao_molar']['lado_esquerdo']['id'] == 1) {
      _rmLe = 1;
      _rmLeState = false;
    } else if (ped['relacao_molar']['lado_esquerdo']['id'] == 2) {
      _rmLeState = true;
      _rmLe = 2;
      _rmSe = ped['relacao_molar']['superior_esquerdo']['id'];
      _rmIe = ped['relacao_molar']['inferior_esquerdo']['id'];
    }
    _rmOutro = ped['relacao_molar']['outro'];

    // Relação Canino

    if (ped['relacao_canino']['lado_direito']['id'] == 1) {
      _rcLd = 1;
      _rcLdState = false;
    } else if (ped['relacao_canino']['lado_direito']['id'] == 2) {
      _rcLdState = true;
      _rcLd = 2;
      _rcSd = ped['relacao_canino']['superior_direito']['id'];
      _rcId = ped['relacao_canino']['inferior_direito']['id'];
    }

    if (ped['relacao_canino']['lado_esquerdo']['id'] == 1) {
      _rcLe = 1;
      _rcLeState = false;
    } else if (ped['relacao_canino']['lado_esquerdo']['id'] == 2) {
      _rcLeState = true;
      _rcLe = 2;
      _rcSe = ped['relacao_canino']['superior_esquerdo']['id'];
      _rcIe = ped['relacao_canino']['inferior_esquerdo']['id'];
    }
    _rcOutro = ped['relacao_canino']['outro'];

    // Opcionais
    _sgOpAceitoDesgastes = ped['sagital_opcionais']['desgastes_interproximais'];
    _sgOpRecorteElastico =
        ped['sagital_opcionais']['recorte_elastico_alinhador'];
    _sgOpRecorteAlinhador = ped['sagital_opcionais']['recorte_alinhador_botao'];
    _sgOpAlivioAlinhador =
        ped['sagital_opcionais']['alivio_alinhador_braco_forca'];

    _localRecElastAlinh = ped['sagital_opcionais']['local_rec_elast_alinh'];

    _localRecAlinhBotao = ped['sagital_opcionais']['local_rec_alinh_botao'];
    _localAlivioAlinhador = ped['sagital_opcionais']['local_alivio_alinhador'];

    // 3 - VERTICAL ---------------------------

    //sobremordida profunda

    if (ped['sobremordida_profunda']['status_correcao']['id'] == 1) {
      _verticalSMP = 1;
      _sobremordidaState = false;
      _idaSupState = false;
      _idaInfState = false;
      _edpSupState = false;
      _edpInfState = false;
    } else {
      if (ped['sobremordida_profunda']['status_correcao']['id'] == 2) {
        _verticalSMP = 2;
        _sobremordidaState = true;
      }
      if (ped['sobremordida_profunda']['intrusao_dentes_anteriores_sup']
          .isNotEmpty) {
        _verticalSMP = 2;
        _sobremordidaState = true;
        _idaSupState = true;
        _idaSup = 1;
        _idaSupMm =
            ped['sobremordida_profunda']['intrusao_dentes_anteriores_sup'];
      }
      if (ped['sobremordida_profunda']['intrusao_dentes_anteriores_inf']
          .isNotEmpty) {
        _verticalSMP = 2;
        _sobremordidaState = true;
        _idaInfState = true;
        _idaInf = 1;
        _idaInfMm =
            ped['sobremordida_profunda']['intrusao_dentes_anteriores_inf'];
      }
      if (ped['sobremordida_profunda']['extrusao_dentes_posteriores_sup']
          .isNotEmpty) {
        _verticalSMP = 2;
        _sobremordidaState = true;
        _edpSupState = true;
        _edpSup = 1;
        _edpSupMm =
            ped['sobremordida_profunda']['extrusao_dentes_posteriores_sup'];
      }
      if (ped['sobremordida_profunda']['extrusao_dentes_posteriores_inf']
          .isNotEmpty) {
        _verticalSMP = 2;
        _sobremordidaState = true;
        _edpInfState = true;
        _edpInf = 1;
        _edpInfMm =
            ped['sobremordida_profunda']['extrusao_dentes_posteriores_inf'];
      }
    }

    // Opcionais sobremordida profunda

    _spBatentesMordida =
        ped['vertical_sobremordida_opcionais']['batentes_mordida'];
    _spLingualIncisivo =
        ped['vertical_sobremordida_opcionais']['lingual_incisivos_superiores'];
    _spLingualCanino = ped['vertical_sobremordida_opcionais']
        ['lingual_canino_a_canino_superior'];
    _spOutros = ped['vertical_sobremordida_opcionais']['outros'];

    //Mordida aberta anterior

    if (ped['mordida_aberta_anterior']['status_correcao']['id'] == 1) {
      _verticalMaa = 1;
      _mordidaAbertaAntState = false;
      _maaIdpSupState = false;
      _maaIdpInfState = false;
      _maaEdaSupState = false;
      _maaEdaInfState = false;
    } else {
      if (ped['mordida_aberta_anterior']['status_correcao']['id'] == 2) {
        _verticalMaa = 2;
        _mordidaAbertaAntState = true;
      }
      if (ped['mordida_aberta_anterior']['extrusao_dentes_anteriores_sup']
          .isNotEmpty) {
        _verticalMaa = 2;
        _mordidaAbertaAntState = true;
        _maaEdaSupState = true;
        _maaEdaSup = 1;
        _maaEdaSupMm =
            ped['mordida_aberta_anterior']['extrusao_dentes_anteriores_sup'];
      }
      if (ped['mordida_aberta_anterior']['extrusao_dentes_anteriores_inf']
          .isNotEmpty) {
        _verticalMaa = 2;
        _mordidaAbertaAntState = true;
        _maaEdaInfState = true;
        _maaEdaInf = 1;
        _maaEdaInfMm =
            ped['mordida_aberta_anterior']['extrusao_dentes_anteriores_inf'];
      }
      if (ped['mordida_aberta_anterior']['intrusao_dentes_posteriores_sup']
          .isNotEmpty) {
        _verticalMaa = 2;
        _mordidaAbertaAntState = true;
        _maaIdpSupState = true;
        _maaIdpSup = 1;
        _maaIdpSupMm =
            ped['mordida_aberta_anterior']['intrusao_dentes_posteriores_sup'];
      }
      if (ped['mordida_aberta_anterior']['intrusao_dentes_posteriores_inf']
          .isNotEmpty) {
        _verticalMaa = 2;
        _mordidaAbertaAntState = true;
        _maaIdpInfState = true;
        _maaIdpInf = 1;
        _maaIdpInfMm =
            ped['mordida_aberta_anterior']['intrusao_dentes_posteriores_inf'];
      }
    }

    // 4 - TRANSVERSAL ---------------------------

    if (ped['mordida_cruzada_posterior']['status_correcao']['id'] == 2) {
      //Mordida Cruzada posterior
      _mordidaCruzPost = true;
      _mordidaCruzPostRadio = 2;

      // expransão arco superior
      _easDireito = ped['expansao_arco_superior']['direito'];
      _easEsquerdo = ped['expansao_arco_superior']['esquerdo'];
      _easMovimentoCorpo = ped['expansao_arco_superior']['movimento_de_corpo'];
      _easInclinacaoTorque = ped['expansao_arco_superior']['inclinacao_torque'];

      //contração arco inferior

      _caiDireito = ped['contracao_arco_inferior']['direito'];
      _caiEsquerdo = ped['contracao_arco_inferior']['esquerdo'];
      _caiMovimentoCorpo = ped['contracao_arco_inferior']['movimento_de_corpo'];
      _caiInclinacaoTorque =
          ped['contracao_arco_inferior']['inclinacao_torque'];

      //Mordida cruzada posterior opcionais

      _mcpRecorteElastico =
          ped['opcionais_mordida_cruz_post']['recorte_elastico_alinhador'];
      _mcpRecorteAlinhador =
          ped['opcionais_mordida_cruz_post']['recorte_alinhador_botao'];
    } else {
      //Mordida Cruzada posterior
      _mordidaCruzPost = false;
      _mordidaCruzPostRadio = 1;
    }

    //Linha média
    //superior

    if (ped['linha_media_superior']['status_correcao']['id'] == 1) {
      // Corrigir or Manter
      _linhaMediaSup = 1;
      _linhaMediaSupState = false;
      _lmSupDireitaState = false;
      _lmSupEsquerdaState = false;
    } else {
      if (ped['linha_media_superior']['status_correcao']['id'] == 2) {
        _linhaMediaSup = 2;
        _linhaMediaSupState = true;
      }
      if (ped['linha_media_superior']['mover_direita'].isNotEmpty) {
        _linhaMediaSup = 2;
        _linhaMediaSupState = true;
        _lmSupDireita = 1;
        _lmSupDireitaState = true;
        _lmSupDireitaMm = ped['linha_media_superior']['mover_direita'];
      }
      if (ped['linha_media_superior']['mover_esquerda'].isNotEmpty) {
        _linhaMediaSupState = true;
        _lmSupEsquerda = 1;
        _lmSupEsquerdaState = true;
        _lmSupEsquerdaMm = ped['linha_media_superior']['mover_esquerda'];
      }
    }

    //------------ inferior ------------------------------------------

    if (ped['linha_media_inferior']['status_correcao']['id'] == 1) {
      // Corrigir or Manter
      _linhaMediaInf = 1;
      _linhaMediaInfState = false;
      _lmInfDireitaState = false;
      _lmInfEsquerdaState = false;
    } else {
      if (ped['linha_media_inferior']['status_correcao']['id'] == 2) {
        _linhaMediaInf = 2;
        _linhaMediaInfState = true;
      }
      if (ped['linha_media_inferior']['mover_direita'].isNotEmpty) {
        _linhaMediaInf = 2;
        _linhaMediaInfState = true;
        _lmInfDireita = 1;
        _lmInfDireitaState = true;
        _lmInfDireitaMm = ped['linha_media_inferior']['mover_direita'];
      }
      if (ped['linha_media_inferior']['mover_esquerda'].isNotEmpty) {
        _linhaMediaInfState = true;
        _lmInfEsquerda = 1;
        _lmInfEsquerdaState = true;
        _lmInfEsquerdaMm = ped['linha_media_inferior']['mover_esquerda'];
      }
    }

    // *PROBLEMAS INDIVIDUAIS*

    if (ped['apinhamento']['ausencia_apinhamento'] == true) {
      _ausenciaApinhamento = ped['apinhamento']['ausencia_apinhamento'];
      //_ausenciaApinhamento = false;
      _tratarApinRadio = 3;
      _corrigirApinSelecionado = false;
    } else if (ped['apinhamento']['status_correcao']['id'] == 1) {
      _tratarApinRadio = 1;
      _corrigirApinSelecionado = false;
    } else {
      _tratarApinRadio = 2;
      _tratarApinRadio = ped['apinhamento']['status_correcao']['id'];
      _corrigirApinSelecionado = true;

      // ----------- ARCO SUPERIOR --------------

      // ---------- Expansão (transversal) -------------
      if (ped['as_expansao_transversal']['ate_2_5mm_por_lado'] ||
          ped['as_expansao_transversal']['qto_necessario_evitar_dip']) {
        //Expansão selected
        _expArcoSupApin = true;
        if (ped['as_expansao_transversal']['ate_2_5mm_por_lado'] == true) {
          // Fields (expansão)
          _expArcoSupApinRadio = 1;
          // radio values to bool
          _expArcoSupApinAte2_5mmPorLado = true;
          _expArcoSupApinQtoNecessario = false;
        }
        if (ped['as_expansao_transversal']['qto_necessario_evitar_dip'] ==
            true) {
          // Fields (expansão)
          _expArcoSupApinRadio = 2;
          // radio values to bool
          _expArcoSupApinAte2_5mmPorLado = false;
          _expArcoSupApinQtoNecessario = true;
        }
      }
      // ---------- Inclinação/projeção -----------
      if (ped['as_inclin_proj_vest_dos_incisivo']['ate_8_graus_2mm'] ||
          ped['as_inclin_proj_vest_dos_incisivo']
                  ['qto_necessario_evitar_dip'] ==
              true ||
          ped['as_inclin_proj_vest_dos_incisivo']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to inclinacao
        //checkbox
        //Inclinação/projeção selected

        _incProjArcoSupApin = true;

        if (ped['as_inclin_proj_vest_dos_incisivo']['ate_8_graus_2mm'] ==
            true) {
          _incProjArcoSupApinRadio = 1;
          _incProjArcoSupApinAte8graus2mm = true;
        } else if (ped['as_inclin_proj_vest_dos_incisivo']
                ['qto_necessario_evitar_dip'] ==
            true) {
          _incProjArcoSupApinRadio = 2;
          _incProjArcoSupApinQtoNecessario = true;
        } else if (ped['as_inclin_proj_vest_dos_incisivo']['outros']
            .isNotEmpty) {
          _incProjArcoSupApinRadio = 3;
          _incProjArcoSupApinOutros =
              ped['as_inclin_proj_vest_dos_incisivo']['outros'];
        }
      }

      //---------- Distalização dos dentes posteriores -----------
      //------- LADO ESQUERDO -------

      if (ped['as_dist_lado_esquerdo']['ate_1_5mm'] ||
          ped['as_dist_lado_esquerdo']['ate_3mm'] ||
          ped['as_dist_lado_esquerdo']['qto_necessario_evitar_dip'] == true ||
          ped['as_dist_lado_esquerdo']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoSupApin = true;
        _distDPASAEsq = true;

        if (ped['as_dist_lado_esquerdo']['ate_1_5mm'] == true) {
          _distDPASAEsqRadio = 1;
          _distDPASAEsqAte1_5mm = true;
        } else if (ped['as_dist_lado_esquerdo']['ate_3mm'] == true) {
          _distDPASAEsqRadio = 2;
          _distDPASAEsqAte3mm = true;
        } else if (ped['as_dist_lado_esquerdo']['qto_necessario_evitar_dip'] ==
            true) {
          _distDPASAEsqRadio = 3;
          _distDPASAEsqQtoNecessario = true;
        } else if (ped['as_dist_lado_esquerdo']['outros'].isNotEmpty) {
          _distDPASAEsqRadio = 4;
          _distDPASAEsqOutros = ped['as_dist_lado_esquerdo']['outros'];
        }
      }

      //------- LADO DIREITO -------
      if (ped['as_dist_lado_direito']['ate_1_5mm'] ||
          ped['as_dist_lado_direito']['ate_3mm'] ||
          ped['as_dist_lado_direito']['qto_necessario_evitar_dip'] == true ||
          ped['as_dist_lado_direito']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoSupApin = true;
        _distDPASADir = true;

        if (ped['as_dist_lado_direito']['ate_1_5mm'] == true) {
          _distDPASADirRadio = 1;
          _distDPASADirAte1_5mm = true;
        } else if (ped['as_dist_lado_direito']['ate_3mm'] == true) {
          _distDPASADirRadio = 2;
          _distDPASADirAte3mm = true;
        } else if (ped['as_dist_lado_direito']['qto_necessario_evitar_dip'] ==
            true) {
          _distDPASADirRadio = 3;
          _distDPASADirQtoNecessario = true;
        } else if (ped['as_dist_lado_direito']['outros'].isNotEmpty) {
          _distDPASADirRadio = 4;
          _distDPASADirOutros = ped['as_dist_lado_direito']['outros'];
        }
      }
      //------- DESGASTES INTERPROXIMAIS -------

      if (ped['as_dist_desgastes_interproximais']['ate_3mm'] ||
          ped['as_dist_desgastes_interproximais']['ate_5mm'] ||
          ped['as_dist_desgastes_interproximais']
                  ['qto_necessario_evitar_dip'] ==
              true ||
          ped['as_dist_desgastes_interproximais']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoSupApin = true;
        _distDPASADesInter = true;

        if (ped['as_dist_desgastes_interproximais']['ate_3mm'] == true) {
          _distDPASADesInterRadio = 1;
          _distDPASADesInterAte3mm = true;
        } else if (ped['as_dist_desgastes_interproximais']['ate_5mm'] == true) {
          _distDPASADesInterRadio = 2;
          _distDPASADesInterAte5mm = true;
        } else if (ped['as_dist_desgastes_interproximais']
                ['qto_necessario_evitar_dip'] ==
            true) {
          _distDPASADesInterRadio = 3;
          _distDPASADesInterQtoNecessario = true;
        } else if (ped['as_dist_desgastes_interproximais']['outros']
            .isNotEmpty) {
          _distDPASADesInterRadio = 4;
          _distDPASADesInterOutros =
              ped['as_dist_desgastes_interproximais']['outros'];
        }
      }

      // ----------- ARCO INFERIOR --------------

      // ---------- Expansão (transversal) -------------
      if (ped['ai_expansao_transversal']['ate_2_5mm_por_lado'] ||
          ped['ai_expansao_transversal']['qto_necessario_evitar_dip']) {
        //Expansão selected
        _expArcoInfApin = true;

        if (ped['ai_expansao_transversal']['ate_2_5mm_por_lado'] == true) {
          // Fields (expansão)
          _expArcoInfApinRadio = 1;

          // radio values to bool
          _expArcoInfApinAte2_5mmPorLado = true;
          _expArcoInfApinQtoNecessario = false;
        }
        if (ped['ai_expansao_transversal']['qto_necessario_evitar_dip'] ==
            true) {
          _expArcoInfApinRadio = 2;

          // radio values to bool
          _expArcoInfApinAte2_5mmPorLado = false;
          _expArcoInfApinQtoNecessario = true;
        }
      }
      // ---------- Inclinação/projeção -----------
      if (ped['ai_inclin_proj_vest_dos_incisivo']['ate_8_graus_2mm'] ||
          ped['ai_inclin_proj_vest_dos_incisivo']
                  ['qto_necessario_evitar_dip'] ==
              true ||
          ped['ai_inclin_proj_vest_dos_incisivo']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to inclinacao
        //checkbox
        //Inclinação/projeção selected

        _incProjArcoInfApin = true;

        if (ped['ai_inclin_proj_vest_dos_incisivo']['ate_8_graus_2mm'] ==
            true) {
          _incProjArcoInfApinRadio = 1;
          _incProjArcoInfApinAte8graus2mm = true;
        } else if (ped['ai_inclin_proj_vest_dos_incisivo']
                ['qto_necessario_evitar_dip'] ==
            true) {
          _incProjArcoInfApinRadio = 2;
          _incProjArcoInfApinQtoNecessario = true;
        } else if (ped['ai_inclin_proj_vest_dos_incisivo']['outros']
            .isNotEmpty) {
          _incProjArcoInfApinRadio = 3;
          _incProjArcoInfApinOutros =
              ped['ai_inclin_proj_vest_dos_incisivo']['outros'];
        }
      }

      //---------- Distalização dos dentes posteriores -----------
      //------- LADO ESQUERDO -------

      if (ped['ai_dist_lado_esquerdo']['ate_1_5mm'] ||
          ped['ai_dist_lado_esquerdo']['ate_3mm'] ||
          ped['ai_dist_lado_esquerdo']['qto_necessario_evitar_dip'] == true ||
          ped['ai_dist_lado_esquerdo']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoInfApin = true;
        _distDPAIAEsq = true;

        if (ped['ai_dist_lado_esquerdo']['ate_1_5mm'] == true) {
          _distDPAIAEsqRadio = 1;
          _distDPAIAEsqAte1_5mm = true;
        } else if (ped['ai_dist_lado_esquerdo']['ate_3mm'] == true) {
          _distDPAIAEsqRadio = 2;
          _distDPAIAEsqAte3mm = true;
        } else if (ped['ai_dist_lado_esquerdo']['qto_necessario_evitar_dip'] ==
            true) {
          _distDPAIAEsqRadio = 3;
          _distDPAIAEsqQtoNecessario = true;
        } else if (ped['ai_dist_lado_esquerdo']['outros'].isNotEmpty) {
          _distDPAIAEsqRadio = 4;
          _distDPAIAEsqOutros = ped['ai_dist_lado_esquerdo']['outros'];
        }
      }

      //------- LADO DIREITO -------
      if (ped['ai_dist_lado_direito']['ate_1_5mm'] ||
          ped['ai_dist_lado_direito']['ate_3mm'] ||
          ped['ai_dist_lado_direito']['qto_necessario_evitar_dip'] == true ||
          ped['ai_dist_lado_direito']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoInfApin = true;
        _distDPAIADir = true;

        if (ped['ai_dist_lado_direito']['ate_1_5mm'] == true) {
          _distDPAIADirRadio = 1;
          _distDPAIADirAte1_5mm = true;
        } else if (ped['ai_dist_lado_direito']['ate_3mm'] == true) {
          _distDPAIADirRadio = 2;
          _distDPAIADirAte3mm = true;
        } else if (ped['ai_dist_lado_direito']['qto_necessario_evitar_dip'] ==
            true) {
          _distDPAIADirRadio = 3;
          _distDPAIADirQtoNecessario = true;
        } else if (ped['ai_dist_lado_direito']['outros'].isNotEmpty) {
          _distDPAIADirRadio = 4;
          _distDPAIADirOutros = ped['ai_dist_lado_direito']['outros'];
        }
      }
      //------- DESGASTES INTERPROXIMAIS -------

      if (ped['ai_dist_desgastes_interproximais']['ate_3mm'] ||
          ped['ai_dist_desgastes_interproximais']['ate_5mm'] ||
          ped['ai_dist_desgastes_interproximais']
                  ['qto_necessario_evitar_dip'] ==
              true ||
          ped['ai_dist_desgastes_interproximais']['outros'].isNotEmpty) {
        //If any radio/resp fields are with data, true to checkbox

        //Distalização.. selected
        _distDentesPostArcoInfApin = true;
        _distDPAIADesInter = true;

        if (ped['ai_dist_desgastes_interproximais']['ate_3mm'] == true) {
          _distDPAIADesInterRadio = 1;
          _distDPAIADesInterAte3mm = true;
        } else if (ped['ai_dist_desgastes_interproximais']['ate_5mm'] == true) {
          _distDPAIADesInterRadio = 2;
          _distDPAIADesInterAte5mm = true;
        } else if (ped['ai_dist_desgastes_interproximais']
                ['qto_necessario_evitar_dip'] ==
            true) {
          _distDPAIADesInterRadio = 3;
          _distDPAIADesInterQtoNecessario = true;
        } else if (ped['ai_dist_desgastes_interproximais']['outros']
            .isNotEmpty) {
          _distDPAIADesInterRadio = 4;
          _distDPAIADesInterOutros =
              ped['ai_dist_desgastes_interproximais']['outros'];
        }
      }
    }

    // ------- CONSIDERAÇÕES IMPORTANTES -------

    // Extração dos terceiros molares
    if (ped['extracao_terceiros_molares']['sim']) {
      _exTerceiroMolares = 1;
      _exTerceiroMolaresSim = ped['extracao_terceiros_molares']['sim'];
    } else if (ped['extracao_terceiros_molares']['nao']) {
      _exTerceiroMolares = 2;
      _exTerceiroMolaresNao = ped['extracao_terceiros_molares']['nao'];
    }

    //Extração virtual dos seguintes dentes
    //Superior
    _evsD18 = ped['extracao_virtual_sup']['d18'];
    _evsD17 = ped['extracao_virtual_sup']['d17'];
    _evsD16 = ped['extracao_virtual_sup']['d16'];
    _evsD15 = ped['extracao_virtual_sup']['d15'];
    _evsD14 = ped['extracao_virtual_sup']['d14'];
    _evsD13 = ped['extracao_virtual_sup']['d13'];
    _evsD12 = ped['extracao_virtual_sup']['d12'];
    _evsD11 = ped['extracao_virtual_sup']['d11'];
    _evsD21 = ped['extracao_virtual_sup']['d21'];
    _evsD22 = ped['extracao_virtual_sup']['d22'];
    _evsD23 = ped['extracao_virtual_sup']['d23'];
    _evsD24 = ped['extracao_virtual_sup']['d24'];
    _evsD25 = ped['extracao_virtual_sup']['d25'];
    _evsD26 = ped['extracao_virtual_sup']['d26'];
    _evsD27 = ped['extracao_virtual_sup']['d27'];
    _evsD28 = ped['extracao_virtual_sup']['d28'];

    //Inferior
    _eviD48 = ped['extracao_virtual_inf']['d48'];
    _eviD47 = ped['extracao_virtual_inf']['d47'];
    _eviD46 = ped['extracao_virtual_inf']['d46'];
    _eviD45 = ped['extracao_virtual_inf']['d45'];
    _eviD44 = ped['extracao_virtual_inf']['d44'];
    _eviD43 = ped['extracao_virtual_inf']['d43'];
    _eviD42 = ped['extracao_virtual_inf']['d42'];
    _eviD41 = ped['extracao_virtual_inf']['d41'];
    _eviD31 = ped['extracao_virtual_inf']['d31'];
    _eviD32 = ped['extracao_virtual_inf']['d32'];
    _eviD33 = ped['extracao_virtual_inf']['d33'];
    _eviD34 = ped['extracao_virtual_inf']['d34'];
    _eviD35 = ped['extracao_virtual_inf']['d35'];
    _eviD36 = ped['extracao_virtual_inf']['d36'];
    _eviD37 = ped['extracao_virtual_inf']['d37'];
    _eviD38 = ped['extracao_virtual_inf']['d38'];

    //Não movimentar seguintes elementos

    //Superior
    _nmsD18 = ped['nao_mov_elem_sup']['d18'];
    _nmsD17 = ped['nao_mov_elem_sup']['d17'];
    _nmsD16 = ped['nao_mov_elem_sup']['d16'];
    _nmsD15 = ped['nao_mov_elem_sup']['d15'];
    _nmsD14 = ped['nao_mov_elem_sup']['d14'];
    _nmsD13 = ped['nao_mov_elem_sup']['d13'];
    _nmsD12 = ped['nao_mov_elem_sup']['d12'];
    _nmsD11 = ped['nao_mov_elem_sup']['d11'];
    _nmsD21 = ped['nao_mov_elem_sup']['d21'];
    _nmsD22 = ped['nao_mov_elem_sup']['d22'];
    _nmsD23 = ped['nao_mov_elem_sup']['d23'];
    _nmsD24 = ped['nao_mov_elem_sup']['d24'];
    _nmsD25 = ped['nao_mov_elem_sup']['d25'];
    _nmsD26 = ped['nao_mov_elem_sup']['d26'];
    _nmsD27 = ped['nao_mov_elem_sup']['d27'];
    _nmsD28 = ped['nao_mov_elem_sup']['d28'];

    //Inferior
    _nmiD48 = ped['nao_mov_elem_inf']['d48'];
    _nmiD47 = ped['nao_mov_elem_inf']['d47'];
    _nmiD46 = ped['nao_mov_elem_inf']['d46'];
    _nmiD45 = ped['nao_mov_elem_inf']['d45'];
    _nmiD44 = ped['nao_mov_elem_inf']['d44'];
    _nmiD43 = ped['nao_mov_elem_inf']['d43'];
    _nmiD42 = ped['nao_mov_elem_inf']['d42'];
    _nmiD41 = ped['nao_mov_elem_inf']['d41'];
    _nmiD31 = ped['nao_mov_elem_inf']['d31'];
    _nmiD32 = ped['nao_mov_elem_inf']['d32'];
    _nmiD33 = ped['nao_mov_elem_inf']['d33'];
    _nmiD34 = ped['nao_mov_elem_inf']['d34'];
    _nmiD35 = ped['nao_mov_elem_inf']['d35'];
    _nmiD36 = ped['nao_mov_elem_inf']['d36'];
    _nmiD37 = ped['nao_mov_elem_inf']['d37'];
    _nmiD38 = ped['nao_mov_elem_inf']['d38'];

    //Não colocar attachmentes nos seguintes elementos

    //Superior
    _ncasD18 = ped['nao_colocar_attach_sup']['d18'];
    _ncasD17 = ped['nao_colocar_attach_sup']['d17'];
    _ncasD16 = ped['nao_colocar_attach_sup']['d16'];
    _ncasD15 = ped['nao_colocar_attach_sup']['d15'];
    _ncasD14 = ped['nao_colocar_attach_sup']['d14'];
    _ncasD13 = ped['nao_colocar_attach_sup']['d13'];
    _ncasD12 = ped['nao_colocar_attach_sup']['d12'];
    _ncasD11 = ped['nao_colocar_attach_sup']['d11'];
    _ncasD21 = ped['nao_colocar_attach_sup']['d21'];
    _ncasD22 = ped['nao_colocar_attach_sup']['d22'];
    _ncasD23 = ped['nao_colocar_attach_sup']['d23'];
    _ncasD24 = ped['nao_colocar_attach_sup']['d24'];
    _ncasD25 = ped['nao_colocar_attach_sup']['d25'];
    _ncasD26 = ped['nao_colocar_attach_sup']['d26'];
    _ncasD27 = ped['nao_colocar_attach_sup']['d27'];
    _ncasD28 = ped['nao_colocar_attach_sup']['d28'];

    //Inferior
    _ncaiD48 = ped['nao_colocar_attach_inf']['d48'];
    _ncaiD47 = ped['nao_colocar_attach_inf']['d47'];
    _ncaiD46 = ped['nao_colocar_attach_inf']['d46'];
    _ncaiD45 = ped['nao_colocar_attach_inf']['d45'];
    _ncaiD44 = ped['nao_colocar_attach_inf']['d44'];
    _ncaiD43 = ped['nao_colocar_attach_inf']['d43'];
    _ncaiD42 = ped['nao_colocar_attach_inf']['d42'];
    _ncaiD41 = ped['nao_colocar_attach_inf']['d41'];
    _ncaiD31 = ped['nao_colocar_attach_inf']['d31'];
    _ncaiD32 = ped['nao_colocar_attach_inf']['d32'];
    _ncaiD33 = ped['nao_colocar_attach_inf']['d33'];
    _ncaiD34 = ped['nao_colocar_attach_inf']['d34'];
    _ncaiD35 = ped['nao_colocar_attach_inf']['d35'];
    _ncaiD36 = ped['nao_colocar_attach_inf']['d36'];
    _ncaiD37 = ped['nao_colocar_attach_inf']['d37'];
    _ncaiD38 = ped['nao_colocar_attach_inf']['d38'];

    // --------- FORMATOS MODELOS -------------
    //Digital ou Gesso

    if (ped['modelo_digital'] == true) {
      _formatoModelos = 1;
      _modeloDigital = true;
    } else if (ped['modelo_gesso'] == true) {
      _formatoModelos = 2;
      _modeloGesso = true;
    }

    // ---------- ENDEREÇO ENTREGA --------------
    _idEnderecoUsuario = ped['endereco_usuario']['id'];

    //Termos
    _termos = ped['termos_de_uso'];

    // Taxa planejamento
    _taxaPlanejamento = ped['taxa_planejamento'];

    // ORIENTAÇÕES ESPECIFICAS
    _orientacoesEsp = ped['orientacoes_especificas'];

    // ---------- STATUS PEDIDO --------------
    //Unaltered response map
    _statusPedido = null;
    //String list for ui
    _stringDataList = null;
    // Always begins with true (will run only once)
    _didFetchStatusPedido = false;

    // Selected status is always "id 1: aguardando relatório" for new Pedidos.
    _currentStatus = ped['status_pedido']['status'];
    _statusId = ped['status_pedido']['id'];
  }

  //CLEAR FULL FORM (STILL CODING)
  void clearAll() {
    _cadistaResponsavel = null;
    _linkModelos = null;
    // 1 - DADOS INICIAIS ---------------------------
    _nomeDoPaciente = null;
    _dataNascimento = null;
    _diPrincipalQueixa = null;
    _tratarRadio = 0;
    // 2 - SAGITAL ---------------------------
    // Relação Molar
    _rmLdState = false;
    _rmLeState = false;
    _rmOutro = null;
    _rmLd = 0;
    _rmLe = 0;
    _rmSd = 0;
    _rmId = 0;
    _rmSe = 0;
    _rmIe = 0;
    // Relação Canino
    _rcLdState = false;
    _rcLeState = false;
    _rcOutro = null;
    _rcLd = 0;
    _rcLe = 0;
    _rcSd = 0;
    _rcId = 0;
    _rcSe = 0;
    _rcIe = 0;

    // Opcionais
    _sgOpAceitoDesgastes = false;
    _sgOpRecorteElastico = false;
    _sgOpRecorteAlinhador = false;
    _sgOpAlivioAlinhador = false;

    _localRecElastAlinh = '';
    _localRecAlinhBotao = '';
    _localAlivioAlinhador = '';

    // 3 - VERTICAL ---------------------------

    //sobremordida profunda
    _sobremordidaState = false;
    _idaSupState = false;
    _idaInfState = false;
    _edpSupState = false;
    _edpInfState = false;

    _verticalSMP = 0;

    _idaSup = 0;
    _idaInf = 0;
    _edpSup = 0;
    _edpInf = 0;

    // number values in mm
    _idaSupMm = '';
    _idaInfMm = '';
    _edpSupMm = '';
    _edpInfMm = '';

    // Opcionais sobremordida profunda
    _spBatentesMordida = false;
    _spLingualIncisivo = false;
    _spLingualCanino = false;
    _spOutros = '';

    //Mordida aberta anterior
    _mordidaAbertaAntState = false;
    _maaIdpSupState = false;
    _maaIdpInfState = false;
    _maaEdaSupState = false;
    _maaEdaInfState = false;

    _verticalMaa = 0;

    _maaIdpSup = 0;
    _maaIdpInf = 0;
    _maaEdaSup = 0;
    _maaEdaInf = 0;

    // number values in mm
    _maaIdpSupMm = '';
    _maaIdpInfMm = '';
    _maaEdaSupMm = '';
    _maaEdaInfMm = '';

    // 4 - TRANSVERSAL ---------------------------

    //Mordida Cruzada posterior
    _mordidaCruzPost = false;
    _mordidaCruzPostRadio = 0;

    // expransão arco superior
    _easDireito = false;
    _easEsquerdo = false;
    _easMovimentoCorpo = false;
    _easInclinacaoTorque = false;

    //contração arco inferior

    _caiDireito = false;
    _caiEsquerdo = false;
    _caiMovimentoCorpo = false;
    _caiInclinacaoTorque = false;

    //Mordida cruzada posterior opcionais

    _mcpRecorteElastico = false;
    _mcpRecorteAlinhador = false;
    _localMcpRecElastAlinh = '';
    _localMcpRecAlinhBotao = '';

    //Linha média
    //superior
    // Corrigir or Manter
    _linhaMediaSupState = false;
    _linhaMediaSup = 0;

    _lmSupDireitaState = false;
    _lmSupEsquerdaState = false;
    _lmSupDireita = 0;
    _lmSupEsquerda = 0;

    // number values in mm
    _lmSupDireitaMm = '';
    _lmSupEsquerdaMm = '';

    //------------ inferior ------------------------------------------

    // Corrigir or Manter
    _linhaMediaInfState = false;
    _linhaMediaInf = 0;

    _lmInfDireitaState = false;
    _lmInfEsquerdaState = false;
    _lmInfDireita = 0;
    _lmInfEsquerda = 0;

    // number values in mm
    _lmInfDireitaMm = '';
    _lmInfEsquerdaMm = '';

    // *PROBLEMAS INDIVIDUAIS*
    _ausenciaApinhamento = false;
    _tratarApinRadio = 0;
    _corrigirApinSelecionado = false;

    // ----------- ARCO SUPERIOR --------------

    // ---------- Expansão (transversal) -------------
    //Expansão selected
    _expArcoSupApin = false;
    // Fields (expansão)
    _expArcoSupApinRadio = 0;
    // radio values to bool
    _expArcoSupApinAte2_5mmPorLado = false;
    _expArcoSupApinQtoNecessario = false;

    // ---------- Inclinação/projeção -----------
    //Inclinação/projeção selected
    _incProjArcoSupApin = false;
    // Fields
    _incProjArcoSupApinRadio = 0;
    _incProjArcoSupApinOutros = '';
    // radio field to bools
    _incProjArcoSupApinAte8graus2mm = false;
    _incProjArcoSupApinQtoNecessario = false;

    //---------- Distalização dos dentes posteriores -----------

    //Distalização.. selected
    _distDentesPostArcoSupApin = false;

    //------- LADO ESQUERDO -------

    // fields - Lado esquerdo, direito, desgastes interproximais
    _distDPASAEsq = false;

    //Lado esquerdo radio options
    _distDPASAEsqRadio = 0;

    // radio to bool values

    _distDPASAEsqAte1_5mm = false;
    _distDPASAEsqAte3mm = false;
    _distDPASAEsqQtoNecessario = false;

    //Value for field in radio
    _distDPASAEsqOutros = '';

    //------- LADO DIREITO -------

    // fields - Lado direito
    _distDPASADir = false;

    //Lado Direito radio options
    _distDPASADirRadio = 0;

    // radio to bool values

    _distDPASADirAte1_5mm = false;
    _distDPASADirAte3mm = false;
    _distDPASADirQtoNecessario = false;

    //Value for field in radio
    _distDPASADirOutros = '';

    //------- DESGASTES INTERPROXIMAIS -------

    // fields - Desgastes interproximais
    _distDPASADesInter = false;

    //radio options
    _distDPASADesInterRadio = 0;

    //radio options to bool
    _distDPASADesInterAte3mm = false;
    _distDPASADesInterAte5mm = false;
    _distDPASADesInterQtoNecessario = false;

    //Value for field in radio
    _distDPASADesInterOutros = '';

    // ----------- ARCO INFERIOR --------------

    // ---------- Expansão (transversal) -------------
    //Expansão selected
    _expArcoInfApin = false;
    // Fields (expansão)
    _expArcoInfApinRadio = 0;
    // fields to bool values
    _expArcoInfApinAte2_5mmPorLado = false;
    _expArcoInfApinQtoNecessario = false;

    // ---------- Inclinação/projeção -----------
    //Inclinação/projeção selected
    _incProjArcoInfApin = false;
    // Fields
    _incProjArcoInfApinRadio = 0;
    _incProjArcoInfApinOutros = '';
    // Radio fields to bool values
    _incProjArcoInfApinAte8graus2mm = false;
    _incProjArcoInfApinQtoNecessario = false;

    //---------- Distalização dos dentes posteriores -----------

    //Distalização.. selected
    _distDentesPostArcoInfApin = false;

    //------- LADO ESQUERDO -------

    // fields - Lado esquerdo, direito, desgastes interproximais
    _distDPAIAEsq = false;

    //Lado esquerdo radio options
    _distDPAIAEsqRadio = 0;

    //Value for field in radio
    _distDPAIAEsqOutros = '';
    //Radio values to bool
    _distDPAIAEsqAte1_5mm = false;
    _distDPAIAEsqAte3mm = false;
    _distDPAIAEsqQtoNecessario = false;

    //------- LADO DIREITO -------

    // fields - Lado direito
    _distDPAIADir = false;

    //Lado Direito radio options
    _distDPAIADirRadio = 0;

    //Value for field in radio
    _distDPAIADirOutros = '';

    // radio to bool values
    _distDPAIADirAte1_5mm = false;
    _distDPAIADirAte3mm = false;
    _distDPAIADirQtoNecessario = false;

    //------- DESGASTES INTERPROXIMAIS -------

    // fields - Desgastes interproximais
    _distDPAIADesInter = false;

    //radio options
    _distDPAIADesInterRadio = 0;

    //radio options to bool
    _distDPAIADesInterAte3mm = false;
    _distDPAIADesInterAte5mm = false;
    _distDPAIADesInterQtoNecessario = false;

    //Value for field in radio
    _distDPAIADesInterOutros = '';

    // ------- CONSIDERAÇÕES IMPORTANTES -------

    // Extração dos terceiros molares
    _exTerceiroMolares = 0;
    _exTerceiroMolaresSim = false;
    _exTerceiroMolaresNao = false;

    //Extração virtual dos seguintes dentes
    //Superior
    _evsD18 = false;
    _evsD17 = false;
    _evsD16 = false;
    _evsD15 = false;
    _evsD14 = false;
    _evsD13 = false;
    _evsD12 = false;
    _evsD11 = false;
    _evsD21 = false;
    _evsD22 = false;
    _evsD23 = false;
    _evsD24 = false;
    _evsD25 = false;
    _evsD26 = false;
    _evsD27 = false;
    _evsD28 = false;

    //Inferior
    _eviD48 = false;
    _eviD47 = false;
    _eviD46 = false;
    _eviD45 = false;
    _eviD44 = false;
    _eviD43 = false;
    _eviD42 = false;
    _eviD41 = false;
    _eviD31 = false;
    _eviD32 = false;
    _eviD33 = false;
    _eviD34 = false;
    _eviD35 = false;
    _eviD36 = false;
    _eviD37 = false;
    _eviD38 = false;

    //Não movimentar seguintes elementos

    //Superior
    _nmsD18 = false;
    _nmsD17 = false;
    _nmsD16 = false;
    _nmsD15 = false;
    _nmsD14 = false;
    _nmsD13 = false;
    _nmsD12 = false;
    _nmsD11 = false;
    _nmsD21 = false;
    _nmsD22 = false;
    _nmsD23 = false;
    _nmsD24 = false;
    _nmsD25 = false;
    _nmsD26 = false;
    _nmsD27 = false;
    _nmsD28 = false;

    //Inferior
    _nmiD48 = false;
    _nmiD47 = false;
    _nmiD46 = false;
    _nmiD45 = false;
    _nmiD44 = false;
    _nmiD43 = false;
    _nmiD42 = false;
    _nmiD41 = false;
    _nmiD31 = false;
    _nmiD32 = false;
    _nmiD33 = false;
    _nmiD34 = false;
    _nmiD35 = false;
    _nmiD36 = false;
    _nmiD37 = false;
    _nmiD38 = false;

    //Não colocar attachmentes nos seguintes elementos

    //Superior
    _ncasD18 = false;
    _ncasD17 = false;
    _ncasD16 = false;
    _ncasD15 = false;
    _ncasD14 = false;
    _ncasD13 = false;
    _ncasD12 = false;
    _ncasD11 = false;
    _ncasD21 = false;
    _ncasD22 = false;
    _ncasD23 = false;
    _ncasD24 = false;
    _ncasD25 = false;
    _ncasD26 = false;
    _ncasD27 = false;
    _ncasD28 = false;

    //Inferior
    _ncaiD48 = false;
    _ncaiD47 = false;
    _ncaiD46 = false;
    _ncaiD45 = false;
    _ncaiD44 = false;
    _ncaiD43 = false;
    _ncaiD42 = false;
    _ncaiD41 = false;
    _ncaiD31 = false;
    _ncaiD32 = false;
    _ncaiD33 = false;
    _ncaiD34 = false;
    _ncaiD35 = false;
    _ncaiD36 = false;
    _ncaiD37 = false;
    _ncaiD38 = false;

    // --------- FORMATOS MODELOS -------------
    //Digital ou Gesso

    _formatoModelos = 0;
    _modeloDigital = false;
    _modeloGesso = false;

    // ---------- ENDEREÇO ENTREGA --------------
    _idEnderecoUsuario = null;

    //Termos
    _termos = false;

    // Taxa planejamento
    _taxaPlanejamento = true;

    // ---------- STATUS PEDIDO --------------
    //Unaltered response map
    _statusPedido = null;
    //String list for ui
    _stringDataList = null;
    // Always begins with true (will run only once)
    _didFetchStatusPedido = false;

    // Selected status is always "id 1: aguardando relatório" for new Pedidos.
    _currentStatus = 'Aguardando Relatório';
    _statusId = null;

    // ORIENTAÇÕES ESPECIFICAS
    _orientacoesEsp = '';
  }
}
