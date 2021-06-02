import 'dart:convert';

import 'package:digital_aligner_app/dados/models/relatorio/Relatorio_pdf.dart';
import 'package:digital_aligner_app/dados/models/relatorio/Relatorio_ppt.dart';
import 'package:digital_aligner_app/dados/models/relatorio/relatorio.dart';
import 'package:digital_aligner_app/widgets/file_uploads/relatorio_pdf_model.dart';
import 'package:digital_aligner_app/widgets/file_uploads/relatorio_ppt_model.dart';
//import 'package:digital_aligner_app/widgets/file_uploads/relatorio_ppt_model.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../rotas_url.dart';

class RelatorioProvider with ChangeNotifier {
  //New relatorioPdfUpload object with id and image url from server
  List<RelatorioPdfModel> _relatorioPdfUploadsList = <RelatorioPdfModel>[];

  List<RelatorioPdfModel> getRelatorioList() {
    return _relatorioPdfUploadsList;
  }

  void clearRelatorioList() {
    _relatorioPdfUploadsList = <RelatorioPdfModel>[];
  }
  //MANAGE PPT,PDF SEND STATE

  static const int _fstNotSending = 0;
  static const int _fstRelPdf = 1;
  static const int _fstRelPpt = 2;

  //The main sending variable (if != 0, sending a file)
  int _fstSending = 0;

  void setFstSendState({int fstSendValue}) {
    switch (fstSendValue) {
      case _fstNotSending:
        _fstSending = _fstNotSending;
        notifyListeners();
        break;
      case _fstRelPdf:
        _fstSending = _fstRelPdf;
        notifyListeners();
        break;
      case _fstRelPpt:
        _fstSending = _fstRelPpt;
        notifyListeners();
        break;
      default:
        _fstSending = _fstNotSending;
        notifyListeners();
        break;
    }
  }

  int getFstSendingState() {
    return _fstSending;
  }

  int getFstNotSendingState() {
    return _fstNotSending;
  }

  int getFstRelPdf() {
    return _fstRelPdf;
  }

  int getFstRelPpt() {
    return _fstRelPpt;
  }

  //Currently selected relatorio obj
  Relatorio _selectedRelatorio = Relatorio(
    relatorioPdf: RelatorioPdf(),
    relatorioPPT: RelatorioPPT(),
  );

  //Token for requests
  String _token;

  Relatorio getSelectedRelatorio() {
    return _selectedRelatorio;
  }

  void clearSelectedRelatorio() {
    _fstSending = 0;
    _selectedRelatorio = Relatorio(
      relatorioPdf: RelatorioPdf(),
      relatorioPPT: RelatorioPPT(),
    );
  }

  void clearToken() {
    _token = null;
  }

  void setToken(var t) {
    _token = t;
  }

  void setPptToSend(var data) {
    _selectedRelatorio.relatorioPPT.relatorio1 = data['url'];
    _selectedRelatorio.relatorioPPT.relatorio1Id = data['id'];
  }

  void updatePptToSend(RelatorioPPTModel data) {
    _selectedRelatorio.relatorioPPT.relatorio1 = data.imageUrl;
    _selectedRelatorio.relatorioPPT.relatorio1Id = data.id;
  }

  void setPdfListForSend() {
    //clear list to remove any unwanted links/ids
    _selectedRelatorio.relatorioPdf = RelatorioPdf();

    if (_relatorioPdfUploadsList == null ||
        _relatorioPdfUploadsList.length <= 0) {
      return;
    }

    for (int i = 0; i < _relatorioPdfUploadsList.length; i++) {
      if (i == 0) {
        _selectedRelatorio.relatorioPdf.relatorio1 =
            _relatorioPdfUploadsList[0].imageUrl;
        _selectedRelatorio.relatorioPdf.relatorio1Id =
            _relatorioPdfUploadsList[0].id;
      } else if (i == 1) {
        _selectedRelatorio.relatorioPdf.relatorio2 =
            _relatorioPdfUploadsList[1].imageUrl;
        _selectedRelatorio.relatorioPdf.relatorio2Id =
            _relatorioPdfUploadsList[1].id;
      } else if (i == 2) {
        _selectedRelatorio.relatorioPdf.relatorio3 =
            _relatorioPdfUploadsList[2].imageUrl;
        _selectedRelatorio.relatorioPdf.relatorio3Id =
            _relatorioPdfUploadsList[2].id;
      } else if (i == 3) {
        _selectedRelatorio.relatorioPdf.relatorio4 =
            _relatorioPdfUploadsList[3].imageUrl;
        _selectedRelatorio.relatorioPdf.relatorio4Id =
            _relatorioPdfUploadsList[3].id;
      } else if (i == 4) {
        _selectedRelatorio.relatorioPdf.relatorio5 =
            _relatorioPdfUploadsList[4].imageUrl;
        _selectedRelatorio.relatorioPdf.relatorio5Id =
            _relatorioPdfUploadsList[4].id;
      }
    }
  }

  /*

  void setPptList(List<RelatorioPPTModel> list) {
    if (list == null) {
      _selectedRelatorio.relatorioPPT = RelatorioPPT();
      return;
    }
    _selectedRelatorio.relatorioPPT.relatorio1 = list[0].imageUrl;
    _selectedRelatorio.relatorioPPT.relatorio1Id = list[0].id;
  }
*/
  Future<void> fetchRelatorioBaseData(int pedidoId, int pacienteId) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(RotasUrl.rotaDadosBaseRelatorio +
            '?pedidoId=' +
            pedidoId.toString() +
            '&pacienteId=' +
            pacienteId.toString()),
        headers: requestHeaders,
      );
      var _data = json.decode(response.body);

      _selectedRelatorio.codigoPedido = _data['codigo_pedido'];
      _selectedRelatorio.nome = _data['nome'];
      _selectedRelatorio.sobrenome = _data['sobrenome'];
      _selectedRelatorio.email = _data['email'];
      _selectedRelatorio.cpf = _data['cpf'];
      _selectedRelatorio.nomePaciente = _data['nome_paciente'];
      _selectedRelatorio.idPedido = _data['id_pedido'];
      _selectedRelatorio.idPaciente = _data['id_paciente'];
    } catch (error) {
      print('Ops, error occurred! Status code: ' + error.toString());
      return error;
    }
  }

  //For editing relatorio screen
  Future<void> fetchMyRelatorio(int pedidoId) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(
        Uri.parse(
            RotasUrl.rotaMeuRelatorio + '?pedidoId=' + pedidoId.toString()),
        headers: requestHeaders,
      );
      var _data = json.decode(response.body);
      _selectedRelatorio.codigoPedido = _data[0]['pedido']['codigo_pedido'];
      _selectedRelatorio.nome =
          _data[0]['pedido']['users_permissions_user']['nome'];
      _selectedRelatorio.sobrenome =
          _data[0]['pedido']['users_permissions_user']['sobrenome'];
      _selectedRelatorio.email =
          _data[0]['pedido']['users_permissions_user']['email'];
      _selectedRelatorio.cpf =
          _data[0]['pedido']['users_permissions_user']['username'];
      _selectedRelatorio.nomePaciente = _data[0]['paciente']['nome_paciente'];
      _selectedRelatorio.idPedido = _data[0]['pedido']['id'];
      _selectedRelatorio.idPaciente = _data[0]['paciente']['id'];

      _selectedRelatorio.visualizador3d = _data[0]['visualizador_3d'];
      _selectedRelatorio.visualizador3dOpcao2 =
          _data[0]['visualizador_3d_opcao_2'];

      _selectedRelatorio.relatorioPdf.id = _data[0]['relatorio_pdf']['id'];
      _selectedRelatorio.relatorioPPT.id = _data[0]['relatorio_ppt']['id'];

      _selectedRelatorio.id = _data[0]['id'];

      _selectedRelatorio.relatorioPdf.relatorio1 =
          _data[0]['relatorio_pdf']['relatorio1'];
      _selectedRelatorio.relatorioPdf.relatorio1Id =
          _data[0]['relatorio_pdf']['relatorio1_id'];
      _selectedRelatorio.relatorioPdf.relatorio2 =
          _data[0]['relatorio_pdf']['relatorio2'];
      _selectedRelatorio.relatorioPdf.relatorio2Id =
          _data[0]['relatorio_pdf']['relatorio2_id'];
      _selectedRelatorio.relatorioPdf.relatorio3 =
          _data[0]['relatorio_pdf']['relatorio3'];
      _selectedRelatorio.relatorioPdf.relatorio3Id =
          _data[0]['relatorio_pdf']['relatorio3_id'];
      _selectedRelatorio.relatorioPdf.relatorio4 =
          _data[0]['relatorio_pdf']['relatorio4'];
      _selectedRelatorio.relatorioPdf.relatorio4Id =
          _data[0]['relatorio_pdf']['relatorio4_id'];
      _selectedRelatorio.relatorioPdf.relatorio5 =
          _data[0]['relatorio_pdf']['relatorio5'];
      _selectedRelatorio.relatorioPdf.relatorio5Id =
          _data[0]['relatorio_pdf']['relatorio5_id'];
    } catch (error) {
      print('Error! ' + error.toString());
      return error;
    }
  }

  Future<Map<dynamic, dynamic>> enviarRelatorio() async {
    setPdfListForSend();

    var _response = await http.post(Uri.parse(RotasUrl.rotaCriarRelatorio),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: json.encode(_selectedRelatorio.toJson()));

    Map<dynamic, dynamic> _data = json.decode(_response.body);
    return _data;
  }

  Future<Map<dynamic, dynamic>> atualizarRelatorio() async {
    setPdfListForSend();
    var _response = await http.put(Uri.parse(RotasUrl.rotaAtualizarRelatorio),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: json.encode(_selectedRelatorio.toJson()));

    print(_response.body);

    Map<dynamic, dynamic> _data = json.decode(_response.body);
    return _data;
  }
}
