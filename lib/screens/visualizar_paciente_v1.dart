import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyAppBar.dart';
import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/historico_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/relatorio_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:easy_web_view2/easy_web_view2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../rotas_url.dart';

class VisualizarPacienteV1 extends StatefulWidget {
  static const routeName = '/visualizar-paciente-v1';
  const VisualizarPacienteV1({Key? key}) : super(key: key);

  @override
  _VisualizarPacienteV1State createState() => _VisualizarPacienteV1State();
}

class _VisualizarPacienteV1State extends State<VisualizarPacienteV1> {
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;
  bool firstRun = true;
  bool isFetchHistorico = true;
  String _solicitarAlteracao = '';
  int _selectedTilePos = -1;
  final ScrollController _scrollController = ScrollController();
  ValueKey key1 = ValueKey('1');
  ValueKey key2 = ValueKey('2');

  //route arguments
  ScreenArguments _args = ScreenArguments();

  List<HistoricoPacV1> _historicoList = [];

  //FOR VIEWING EACH MODEL TYPE
  PedidoV1Model _pedidoView = PedidoV1Model();
  PedidoV1Model _pedidoRefinamentoView = PedidoV1Model();
  RelatorioV1Model _relatorioView = RelatorioV1Model();
  String _alteracaoView = '';

  // view alteração
  final GlobalKey<FormState> _relatorioFormKey = GlobalKey<FormState>();

  //currently selected view: 0 = none, 1=pedidoView, 2=refinamentoView, 3=relatorioView, 4 = viewAlteracao
  int _selectedView = 0;

  //List<PlatformFile> _filesData = <PlatformFile>[];
  //List<FileModel> _serverFiles = [];

  Future<List<HistoricoPacV1>> _fetchHistoricoPac() async {
    final response = await http.get(
      Uri.parse(
        RotasUrl.rotaHistoricoPacV1 +
            '?id_pedido=' +
            _pedidoStore!
                .getPedido(
                  position: _args.messageInt,
                )
                .id
                .toString(),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    try {
      List<dynamic> _historicos = json.decode(response.body);
      if (_historicos[0].containsKey('id')) {
        _historicoList = [];
        _historicos.forEach((h) {
          _historicoList.add(HistoricoPacV1.fromJson(h));
        });
        return _historicoList;
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }

/*
  MultipartRequest _buildRequest(PlatformFile currentFile) {
    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer ${_authStore!.token}';

    request.files.add(http.MultipartFile(
      'files',
      currentFile.readStream!,
      currentFile.size,
      filename: currentFile.name,
    ));
    return request;
  }
  
  Future<void> _sendFile(PlatformFile currentFile) async {
    //build request
    MultipartRequest r = _buildRequest(currentFile);

    try {
      //TIMER (for fake ui progress)
      //_fakeTimer();

      //send file
      var response = await r.send();
      var resStream = await response.stream.bytesToString();
      //decode data
      var resData = json.decode(resStream);

      if (resData[0].containsKey('id')) {
        setState(() {
          _serverFiles.add(FileModel.fromJson(resData[0]));
          //progress = 0;
        });

        var _response = await http.put(
          Uri.parse(RotasUrl.rotaPacienteFotoPerfilV1),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${_authStore!.token}',
          },
          body: json.encode({
            'id_pedido': _pedidoStore!.getPedido(position: _args.messageInt).id,
            'foto_perfil_id': _serverFiles[0].id
          }),
        );

        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          return;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg,jpeg,png'],
      allowMultiple: false,
      withReadStream: true,
    );

    if (result != null) {
      if (result.files.length <= 1) {
        _filesData = result.files;
      } else {
        throw ('Selecione até 1 arquivos.');
      }
    } else {
      throw ('Nenhum arquivo escolhido.');
    }
  }
*/
  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _pedidoStore!.getPedido(position: _args.messageInt).nomePaciente,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  /*
  Widget _displayFotoPerfil() {
    if (_pedidoView.fotoPerfil == null ||
        _pedidoView.fotoPerfil!.url!.isEmpty ||
        _serverFiles.isEmpty) {
      return Image.asset('logos/user_avatar.png');
    } else if (_serverFiles.isNotEmpty) {
      return Image.network(
        _serverFiles[0].formats!.thumbnail!.thumbnail!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        _pedidoView.fotoPerfil!.formats!.thumbnail!.thumbnail!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
*/
  Widget _pacienteDados() {
    return Card(
      elevation: 10,
      child: SizedBox(
        width: 300,
        height: 100,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  //await _openFileExplorer();
                  //await _sendFile(_filesData[0]);
                  //setState(() {});
                },
                child: /*_displayFotoPerfil()*/ Image
                    .asset('logos/user_avatar.png'),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('editar paciente'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Solicitar refinamento'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _helperBuilder() {
    if (_selectedView == 0)
      return Container(
        padding: EdgeInsets.only(top: 20),
        height: 370,
        child: Center(child: Text('Selecione um histórico para visualizar')),
      );
    else if (_selectedView == 1) {
      return _viewPedido();
    } else if (_selectedView == 3) {
      return _viewRelatorio();
    } else if (_selectedView == 4) {
      return _viewAlteracao();
    }
    return Container();
  }

  Widget _layout() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Column(
          children: [
            _pacienteDados(),
            _displayHistorico(),
          ],
        ),
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 800,
            child: _helperBuilder(),
          ),
        )
      ],
    );
  }

  String _dateFormat(String date) {
    try {
      var format = DateFormat.yMd('pt');
      var dateTime = DateTime.parse(date);
      return format.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void _mapDataToViews(int position) {
    //check if codigo_status (codigoStatus) is cs_ped
    if (_historicoList[position].status!.codigoStatus == 'cs_ped') {
      setState(() {
        _pedidoView = _historicoList[position].pedido ?? PedidoV1Model();
        _selectedView = 1;
      });
    } else if (_historicoList[position].status!.codigoStatus == 'cs_rel') {
      setState(() {
        _relatorioView =
            _historicoList[position].relatorio ?? RelatorioV1Model();
        _selectedView = 3;
      });
    } else if (_historicoList[position].status!.codigoStatus == 'cs_alt') {
      setState(() {
        _alteracaoView = _historicoList[position].informacao;
        _selectedView = 4;
      });
    }
  }

  Widget _iconForRelatorioApprovado(int pos) {
    if (_historicoList[pos].status!.codigoStatus == 'cs_rel') {
      if (_historicoList[pos].relatorio!.aprovado) {
        return Icon(Icons.check_circle);
      }
    }
    return Icon(Icons.donut_large_rounded);
  }

  Widget _displayHistorico() {
    return Column(
      children: <Widget>[
        isFetchHistorico
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              )
            : Card(
                elevation: 10,
                child: Container(
                  width: 300,
                  height: 300,
                  child: RawScrollbar(
                    radius: Radius.circular(10),
                    thumbColor: Colors.grey,
                    thickness: 15,
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemBuilder: (_, i) {
                        return ListTile(
                          leading: _iconForRelatorioApprovado(i),
                          selected: _selectedTilePos == i ? true : false,
                          title: Text(
                            _dateFormat(_historicoList[i].createdAt) +
                                ' ' +
                                _historicoList[i].status!.status,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTilePos = i;
                            });
                            _mapDataToViews(i);
                          }, // Handle your onTap here.
                        );
                      },
                      separatorBuilder: (_, i) => Divider(
                        height: 10,
                      ),
                      itemCount: _historicoList.length,
                    ),
                  ),
                ),
              )
      ],
    );
  }

  //--------- VIEW PEDIDO WIDGET ------------

  Future<void> _setModelosUrlToStorage() async {
    String modelosData = '';

    try {
      //Save token in device (web or mobile)
      final prefs = await SharedPreferences.getInstance();
      if (_pedidoView.modeloSuperior.length > 0 &&
          _pedidoView.modeloInferior.length == 0) {
        modelosData = json.encode({
          'modelo_superior': _pedidoView.modeloSuperior[0].url,
          'modelo_inferior': ''
        });
      } else if (_pedidoView.modeloSuperior.length == 0 &&
          _pedidoView.modeloInferior.length > 0) {
        modelosData = json.encode({
          'modelo_superior': '',
          'modelo_inferior': _pedidoView.modeloInferior[0].url,
        });
      } else if (_pedidoView.modeloSuperior.length == 0 &&
          _pedidoView.modeloInferior.length == 0) {
        modelosData = json.encode({
          'modelo_superior': '',
          'modelo_inferior': '',
        });
      } else {
        modelosData = json.encode({
          'modelo_superior': _pedidoView.modeloSuperior[0].url,
          'modelo_inferior': _pedidoView.modeloInferior[0].url,
        });
      }

      await prefs.setString('modelos_3d_url', modelosData);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Widget _webViewModeloSuperior() {
    return Column(
      children: [
        EasyWebView(
          key: key1,
          src: 'stl_viewer/modelo_sup_viewer.html',
          isHtml: false, // Use Html syntax
          isMarkdown: false, // Use markdown syntax
          convertToWidgets: false, // Try to convert to flutter widgets
          onLoaded: () => null,
          width: 800,
          height: 500,
        ),
        EasyWebView(
          key: key2,
          src: 'stl_viewer/modelo_inf_viewer.html',
          isHtml: false, // Use Html syntax
          isMarkdown: false, // Use markdown syntax
          convertToWidgets: false, // Try to convert to flutter widgets
          onLoaded: () => null,
          width: 800,
          height: 500,
        ),
      ],
    );
  }

  Widget _viewPedido() {
    //set 3d models url to local storage for webview to access
    _setModelosUrlToStorage();

    //function to map files and get url
    List<Image> mapFilesToUi(List<FileModel> f) {
      List<Image> a = [];

      f.forEach((file) async {
        a.add(
          Image.network(
            file.formats!.thumbnail!.thumbnail!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print(error);
              return Center(
                child: Text('Erro'),
              );
            },
          ),
        );
      });

      return a;
    }

    return ResponsiveGridRow(
      children: [
        //codigo pedido (headline)
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DA' + _pedidoView.id.toString(),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        ResponsiveGridCol(
          lg: 12,
          child: Container(
            //color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Divider(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        //Data nasc.
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Data de Nascimento: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _dateFormat(_pedidoView.dataNascimento),
              ),
            ),
          ),
        ),
        //tratar
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Tratar: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.tratar),
            ),
          ),
        ),
        //queixa principal
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Queixa principal: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.queixaPrincipal),
            ),
          ),
        ),
        //objetivos do tratamento
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Objetivos do tratamento: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.objetivosTratamento),
            ),
          ),
        ),
        //linha media superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Linha média superior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.linhaMediaSuperior),
            ),
          ),
        ),
        //linha media superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Linha média inferior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.linhaMediaInferior),
            ),
          ),
        ),
        //overjet
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Overjet: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.overjet),
            ),
          ),
        ),
        //overbite
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Overbite: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.overbite),
            ),
          ),
        ),
        //Resolução de apinhamento superior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Resolução de apinhamento superior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            color: Colors.black12.withOpacity(0.04),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.resApinSup),
            ),
          ),
        ),
        //Resolução de apinhamento inferior
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Resolução de apinhamento inferior: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.resApinInf),
            ),
          ),
        ),
        //Extração virtual de dentes
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Extração virtual: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.dentesExtVirtual),
            ),
          ),
        ),
        //Não movimentar os seguintes dentes
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Não movimentar: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.dentesNaoMov),
            ),
          ),
        ),
        //Não colocar attachments
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Não colocar attachments: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.dentesSemAttach),
            ),
          ),
        ),
        //Aceito desgastes interproximais (DIP)
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Aceito desgastes interproximais (DIP): '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcAceitoDesg),
            ),
          ),
        ),
        //Recorte para elástico no alinhador
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Recorte para elástico no alinhador: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcRecorteElas),
            ),
          ),
        ),
        //Recorte no alinhador para botão
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Recorte no alinhador para botão: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcRecorteAlin),
            ),
          ),
        ),
        //Alívio no alinhador para braço de força
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Alívio no alinhador para braço de força: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            color: Colors.black12.withOpacity(0.04),
            height: 50,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(_pedidoView.opcAlivioAlin),
            ),
          ),
        ),
        //Fotografias
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Fotografias: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                children: mapFilesToUi(_pedidoView.fotografias),
              ),
            ),
          ),
        ),
        //Radiografias
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(' Radiografias: '),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 6,
          lg: 6,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 10,
                children: mapFilesToUi(_pedidoView.radiografias),
              ),
            ),
          ),
        ),
        ResponsiveGridCol(
          xs: 12,
          lg: 12,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.center,
              child: _webViewModeloSuperior(),
            ),
          ),
        ),
      ],
    );
  }

  // --------- RELATÓRIO ---------------
  Widget _viewRelatorio() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                bool result = await _aprovarRelatorio();
                if (result) {
                  await _fetchHistoricoPac();
                  setState(() {});
                }
              },
              child: const Text('Aprovar'),
            ),
            TextButton(
              onPressed: !_relatorioView.aprovado
                  ? () {
                      solicitarAltPopup();
                    }
                  : null,
              child: const Text('Solicitar alteração'),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 500,
          child: SfPdfViewer.network(
            _relatorioView.relatorio!.url ?? '',
            enableDoubleTapZooming: true,
            enableTextSelection: true,
          ),
        ),
      ],
    );
  }

  bool _checkListForAproved() {
    bool doesExist = false;
    _historicoList.forEach((hist) {
      if (hist.status!.codigoStatus == 'cs_rel') {
        if (hist.relatorio!.aprovado) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                'O pedido já foi aprovado',
                textAlign: TextAlign.center,
              ),
            ),
          );
          doesExist = true;
          return;
        }
      }
    });
    return doesExist;
  }

  Future<bool> _aprovarRelatorio() async {
    bool doesExist = _checkListForAproved();

    if (doesExist) return false;

    //changing aprovação to true
    _relatorioView.aprovado = true;
    _relatorioView.payload = {
      'id_pedido': _pedidoStore!
          .getPedido(
            position: _args.messageInt,
          )
          .id
    };

    // server operation
    try {
      var _response = await http.put(
        Uri.parse(RotasUrl.rotaAprovarRelatoriosV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode(_relatorioView.toJson()),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          print(data);
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('solicitarAlteracao ->' + e.toString());
      return false;
    }
  }

// ---------- ALTERAÇÃO ---------------
  Future<bool> _sendSolicitarAlteracao() async {
    HistoricoPacV1 h = HistoricoPacV1(
      informacao: _solicitarAlteracao,
      status: StatusHistoricoV1(id: 5),
      pedido: PedidoV1Model(
          id: _pedidoStore!.getPedido(position: _args.messageInt).id),
      relatorio: RelatorioV1Model(id: _relatorioView.id),
    );
    try {
      var _response = await http.post(
        Uri.parse(RotasUrl.rotaHistoricoPacV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode(h.toJson()),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('solicitarAlteracao ->' + e.toString());
      return false;
    }
  }

  Widget _viewAlteracao() {
    return Text(_alteracaoView);
  }

  Future<dynamic> solicitarAltPopup() {
    return showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: _relatorioFormKey,
          child: AlertDialog(
            title: const Text('Solicitar alteração'),
            content: Container(
              width: 800,
              height: 500,
              child: TextFormField(
                onChanged: (value) {
                  _solicitarAlteracao = value;
                },
                validator: (String? value) {
                  return value == null || value.isEmpty ? 'Campo vazio' : null;
                },
                maxLines: 30,
                maxLength: 300,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (_relatorioFormKey.currentState!.validate()) {
                    bool result = await _sendSolicitarAlteracao();
                    if (result) {
                      await _fetchHistoricoPac();
                      setState(() {});
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Enviar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Fechar'),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;

    if (firstRun) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
      await _fetchHistoricoPac();
      setState(() {
        isFetchHistorico = false;
        firstRun = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppbar(),
      // *BUG* Verify closing drawer automaticlly when under 1200
      drawer: _screenSize!.width < 1200 ? MyDrawer() : null,
      body: RawScrollbar(
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: _screenSize!.width < 768 ? 3000 : 2800,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _layout(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
