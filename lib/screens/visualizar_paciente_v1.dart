import 'dart:convert';

import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/default_colors.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/Comentario.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/historico_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/relatorio_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/pedido_v1_screen.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/screens/visualizar_modelo_inf_v1.dart';
import 'package:digital_aligner_app/screens/visualizar_modelo_sup_v1.dart';
import 'package:digital_aligner_app/screens/visualizar_relatorio_v1.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:easy_web_view2/easy_web_view2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/link.dart';
import '../rotas_url.dart';
import 'login_screen.dart';
import 'package:characters/characters.dart';

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
  bool isAprovando = false;
  String _solicitarAlteracao = '';
  int _selectedTilePos = -1;
  final ScrollController _scrollController = ScrollController();
  ValueKey key1 = ValueKey('1');
  ValueKey key2 = ValueKey('2');
  bool _modeloVisivel = false;
  int _selectedHistoryPos = 0;
  TextEditingController _messageController = TextEditingController();
  int _mediaQueryMd = 768;
  List<Comentario> _commentList = [
    Comentario(
        idPedido: 247,
        conteudo: 'Olá, teste teste',
        data: DateTime.now(),
        idAutor: 38),
    Comentario(
        idPedido: 247,
        conteudo: 'Resposta teste',
        data: DateTime.now(),
        idAutor: 35)
  ];
  int? idUsuario;

  //route arguments
  ScreenArguments _args = ScreenArguments();

  List<HistoricoPacV1> _historicoList = [];

  //FOR VIEWING EACH MODEL TYPE
  PedidoV1Model _pedidoView = PedidoV1Model();
  //PedidoV1Model _pedidoRefinamentoView = PedidoV1Model();
  RelatorioV1Model _relatorioView = RelatorioV1Model();
  String _alteracaoView = '';

  // view alteração
  final GlobalKey<FormState> _relatorioFormKey = GlobalKey<FormState>();

  //currently selected view: 0 = none, 1=pedidoView, 2=refinamentoView, 3=relatorioView, 4 = viewAlteracao
  int _selectedView = 0;

  //List<PlatformFile> _filesData = <PlatformFile>[];
  //List<FileModel> _serverFiles = [];

  Key link1 = Key('1');
  Key link2 = Key('2');

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

  Widget _manageHeaderText() {
    var pedido = _pedidoStore!.getPedido(position: _args.messageInt);
    if (pedido.pedidoRefinamento) {
      GestureDetector(
        onTap: () {
          Clipboard.setData(
            ClipboardData(
              text: pedido.nomePaciente + ' (refinamento)',
            ),
          );
          _copySnackbar();
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            pedido.nomePaciente + ' (refinamento)',
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      );
      return Text(
        pedido.nomePaciente + ' (refinamento)',
        style: Theme.of(context).textTheme.headline1,
      );
    }
    return GestureDetector(
      onTap: () {
        Clipboard.setData(
          ClipboardData(
            text: pedido.nomePaciente,
          ),
        );
        _copySnackbar();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          pedido.nomePaciente,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: _manageHeaderText(),
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

  bool _checkIfRefinamentoIsActive() {
    var pedido = _pedidoStore!.getPedido(position: _args.messageInt);
    if (pedido.novaAtualizacao != null && pedido.novaAtualizacao == true) {
      return false;
    }
    return true;
  }

  bool _checkIfUserIsSame() {
    if (_authStore!.id == _getPedido().usuario!.id) return true;
    return false;
  }

  Widget _pacienteDados() {
    bool refinamento =
        _pedidoStore!.getPedido(position: _args.messageInt).pedidoRefinamento;
    if (!refinamento)
      return Card(
        elevation: 10,
        child: SizedBox(
          width: _screenSize!.width <= _mediaQueryMd ? double.infinity : 300,
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
                    /*TextButton(
                      onPressed: () {},
                      child: Text('editar paciente'),
                    ),*/
                    TextButton(
                      onPressed: _checkIfUserIsSame()
                          ? () {
                              setState(() {
                                _selectedView = 0;
                                _selectedTilePos = -1;
                              });

                              var p = _pedidoStore!.getPedido(
                                position: _args.messageInt,
                              );

                              Navigator.of(context)
                                  .pushNamed(
                                PedidoV1Screen.routeName,
                                arguments: ScreenArguments(
                                  title: 'Pedido de refinamento',
                                  messageMap: {
                                    'pedidoId': p.id,
                                    'isRefinamento': true,
                                    'nomePaciente': p.nomePaciente,
                                    'dataNascimento': p.dataNascimento,
                                  },
                                ),
                              )
                                  .then((value) async {
                                if (value != null) {
                                  if (value == true) {
                                    await _fetchHistoricoPac();
                                    setState(() {});
                                  }
                                }
                              });
                            }
                          : null,
                      child: Text('Solicitar refinamento'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    return Container();
  }

  Widget _viewPedidoMsg() {
    return Column(
      children: [
        Text(
          'Parabéns!',
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(height: 20),
        Text(
          'O seu pedido de número ${_historicoList[_selectedHistoryPos].pedido?.codigoPedido} para o paciente ${_historicoList[_selectedHistoryPos].pedido?.nomePaciente} foi aprovado. Após faturado junto à sua representante comercial, iniciaremos a produção dos alinhadores, previstos para serem enviados em até 15 dias úteis.\n\nAgradecemos a preferência, qualquer dúvida, estamos à disposição.\n\nAtenciosamente,\n\nEquipe da Digital Aligner',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
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
      if (_historicoList[_selectedHistoryPos].status?.id == 3 ||
          _historicoList[_selectedHistoryPos].status?.id == 6)
        return _viewPedidoMsg();
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
            width: _screenSize!.width <= _mediaQueryMd ? double.infinity : 600,
            child: _helperBuilder(),
          ),
        )
      ],
    );
  }

  void _showMsg({required String text}) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _checkIfUserUploadedDocumentation(String msg) {
    if (!_pedidoView.modeloGesso &&
        _pedidoView.modeloCompactado.isEmpty &&
        _pedidoView.linkModelos.isEmpty &&
        _pedidoView.modeloSuperior.isEmpty &&
        _pedidoView.modeloInferior.isEmpty) {
      _showMsg(text: msg);
    }
  }

  void _checkIfPedidoIsGesso(String msg) {
    if (_pedidoView.modeloGesso) {
      _showMsg(text: msg);
    }
  }

  void _checkIfPedidoIsCompactado(String msg) {
    if (_pedidoView.modeloCompactado.isNotEmpty) {
      _showMsg(text: msg);
    }
  }

  void _checkIfPedidoIsStl() {
    if (_pedidoView.modeloSuperior.isNotEmpty &&
        _pedidoView.modeloInferior.isNotEmpty) {
      _showMsg(text: 'OBSERVAÇÃO: Usuário forneceu MODELOS STL');
    } else if (_pedidoView.modeloSuperior.isNotEmpty ||
        _pedidoView.modeloInferior.isNotEmpty) {
      _showMsg(text: 'OBSERVAÇÃO: Usuário forneceu apenas 1 modelo STL');
    }
  }

  void _checkIfPedidoHasLink(String msg) {
    if (_pedidoView.linkModelos.isNotEmpty) {
      _showMsg(text: msg);
    }
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
      _checkIfUserUploadedDocumentation(
          'OBSERVAÇÃO: Usuário não forneceu modelos (link, compactado ou stl) para o pedido ${_pedidoView.codigoPedido}.');
      _checkIfPedidoIsStl();
      _checkIfPedidoIsGesso('OBSERVAÇÃO: Usuário escolheu MODELO EM GESSO');
      _checkIfPedidoIsCompactado(
          'OBSERVAÇÃO: Usuário forneceu MODELO COMPACTADO');
      _checkIfPedidoHasLink(
          'OBSERVAÇÃO: Usuário forneceu LINK DA DOCUMENTAÇÃO');
    }
    if (_historicoList[position].status!.codigoStatus == 'cs_ref') {
      setState(() {
        _pedidoView =
            _historicoList[position].pedidoRefinamento ?? PedidoV1Model();
        //will use the same model for now
        _selectedView = 1;
      });
      _checkIfUserUploadedDocumentation(
          'OBSERVAÇÃO: Usuário não forneceu modelos (link, compactado ou stl) para o refinamento ${_pedidoView.codigoPedido}');
      _checkIfPedidoIsStl();
      _checkIfPedidoIsGesso('OBSERVAÇÃO: Usuário escolheu MODELO EM GESSO');
      _checkIfPedidoIsCompactado(
          'OBSERVAÇÃO: Usuário forneceu MODELO COMPACTADO');
      _checkIfPedidoHasLink(
          'OBSERVAÇÃO: Usuário forneceu LINK DA DOCUMENTAÇÃO');
    } else if (_historicoList[position].status!.codigoStatus == 'cs_rel') {
      setState(() {
        _relatorioView =
            _historicoList[position].relatorio ?? RelatorioV1Model();
        _selectedView = 3;
      });
    } else if (_historicoList[position].status!.codigoStatus == 'cs_alt') {
      setState(() {
        _alteracaoView = 'RL' +
            _historicoList[position].relatorio!.id.toString() +
            ': ' +
            _historicoList[position].informacao;
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
    return Image.asset(
      'logos/marca_cinza.png',
      height: 25,
    );
    //return Icon(Icons.donut_large_rounded);
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
                  width: _screenSize!.width <= _mediaQueryMd
                      ? double.infinity
                      : 300,
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
                          title: _historicoList[i].status!.status ==
                                  'Pedido criado'
                              ? Row(
                                    mainAxisAlignment:MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 4),
                                      child: Text(
                                        _dateFormat(
                                                _historicoList[i].createdAt) +
                                            ' ' +
                                            _historicoList[i].status!.status,
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(top: 2, left: 4),
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Text(
                                  _dateFormat(_historicoList[i].createdAt) +
                                      ' ' +
                                      _historicoList[i].status!.status,
                                ),
                          onTap: () {
                            setState(() {
                              _selectedHistoryPos = i;
                              _modeloVisivel = false;
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

  Widget _maplongTextToUi(String? text) {
    if (text == null) return Text('');

    if (text.length > 80) {
      return Text(text.characters.take(80).toString() + '... (visualizar)');
    }
    return Text(text);
  }

  Future<void> _viewTextPopup(
    String text,
    String title,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: _relatorioFormKey,
          child: AlertDialog(
            title: Text(title),
            content: Container(
              width: 800,
              height: 500,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: text,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(text),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Fechar'),
              )
            ],
          ),
        );
      },
    );
  }

  void _copySnackbar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: const Text(
          'Copiado',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _viewPedido() {
    //set 3d models url to local storage for webview to access
    _setModelosUrlToStorage();

    //function to map files and get url
    List<Widget> mapFilesToUi(List<FileModel> f) {
      List<Widget> a = [];

      f.forEach((file) async {
        a.add(
          GestureDetector(
            onTap: () {
              imgViewPopup(file.url);
            },
            child: Image.network(
              file.formats!.thumbnail!.thumbnail ?? '',
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
          ),
        );
      });

      return a;
    }

    return Column(
      children: [
        if (_pedidoView.linkModelos.length > 0)
          Column(
            children: [
              const Text('Link da documentação'),
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _pedidoView.linkModelos),
                  );
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      content: Text(
                        'Link copiado',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                child: const Text('Copiar link'),
              ),
            ],
          ),
        if (_pedidoView.modeloCompactado.isNotEmpty)
          _baixarModeloCompactado(
            link: _pedidoView.modeloCompactado[0].url ?? '',
            typeName: 'Baixar modelo compactado',
          ),
        if (_pedidoView.pedidoRefinamento)
          TextButton(
            onPressed: () async {
              await _editarRefinamento();
            },
            child: const Text('Editar Refinamento'),
          ),
        ResponsiveGridRow(
          children: [
            //codigo pedido (headline)
            ResponsiveGridCol(
              lg: 12,
              child: Container(
                //color: Colors.black12.withOpacity(0.04),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: _pedidoView.codigoPedido,
                        ),
                      );
                      _copySnackbar();
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        _pedidoView.codigoPedido,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Data de Nascimento:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Data de Nascimento: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _dateFormat(_pedidoView.dataNascimento),
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
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
              ),
            ),
            //tratar
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Tratar:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Tratar: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.tratar,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.tratar),
                    ),
                  ),
                ),
              ),
            ),
            //queixa principal
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Queixa principal:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Queixa principal: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.queixaPrincipal,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          _viewTextPopup(
                            _pedidoView.queixaPrincipal,
                            'Queixa principal',
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: _maplongTextToUi(_pedidoView.queixaPrincipal),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //objetivos do tratamento
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Objetivos do tratamento:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Objetivos do tratamento: '),
                    ),
                  ),
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
                  child: GestureDetector(
                    onTap: () {
                      _viewTextPopup(
                        _pedidoView.objetivosTratamento,
                        'Objetivos do tratamento',
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _maplongTextToUi(_pedidoView.objetivosTratamento),
                    ),
                  ),
                ),
              ),
            ),
            //linha media superior
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Linha média superior (mm):',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Linha média superior (mm): '),
                    ),
                  ),
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
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: _pedidoView.linhaMediaSuperior,
                        ),
                      );
                      _copySnackbar();
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        color: Colors.black12.withOpacity(0.04),
                        height: 50,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_pedidoView.linhaMediaSuperior),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //linha media inferior
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Linha média inferior (mm):',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Linha média inferior (mm): '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.linhaMediaInferior,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.linhaMediaInferior),
                    ),
                  ),
                ),
              ),
            ),
            //overjet
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Overjet:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Overjet: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.overjet,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.overjet),
                    ),
                  ),
                ),
              ),
            ),
            //overbite
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Overbite (mm):',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Overbite (mm): '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.overbite,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.overbite),
                    ),
                  ),
                ),
              ),
            ),
            //Resolução de apinhamento superior
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Resolução de apinhamento superior:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Resolução de apinhamento superior: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.resApinSup,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    color: Colors.black12.withOpacity(0.04),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.resApinSup),
                    ),
                  ),
                ),
              ),
            ),
            //Resolução de apinhamento inferior
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Resolução de apinhamento inferior:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Resolução de apinhamento inferior: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.resApinInf,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.resApinInf),
                    ),
                  ),
                ),
              ),
            ),
            //Extração virtual de dentes
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Extração virtual:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Extração virtual: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.dentesExtVirtual,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.dentesExtVirtual),
                    ),
                  ),
                ),
              ),
            ),
            //Não movimentar os seguintes dentes
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Não movimentar:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Não movimentar: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.dentesNaoMov,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.dentesNaoMov),
                    ),
                  ),
                ),
              ),
            ),
            //Não colocar attachments
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Não colocar attachments:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Não colocar attachments: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.dentesSemAttach,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.dentesSemAttach),
                    ),
                  ),
                ),
              ),
            ),
            //Aceito desgastes interproximais (DIP)
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Aceito desgastes interproximais (DIP):',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        ' Aceito desgastes interproximais (DIP): ',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.opcAceitoDesg,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.opcAceitoDesg),
                    ),
                  ),
                ),
              ),
            ),
            //Recorte para elástico no alinhador
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Recorte para elástico no alinhador:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:
                          const Text(' Recorte para elástico no alinhador: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.opcRecorteElas,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.opcRecorteElas),
                    ),
                  ),
                ),
              ),
            ),
            //Recorte no alinhador para botão
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Recorte no alinhador para botão:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(' Recorte no alinhador para botão: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.opcRecorteAlin,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.opcRecorteAlin),
                    ),
                  ),
                ),
              ),
            ),
            //Alívio no alinhador para braço de força
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: 'Alívio no alinhador para braço de força:',
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                          ' Alívio no alinhador para braço de força: '),
                    ),
                  ),
                ),
              ),
            ),
            ResponsiveGridCol(
              xs: 6,
              lg: 6,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _pedidoView.opcAlivioAlin,
                    ),
                  );
                  _copySnackbar();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    color: Colors.black12.withOpacity(0.04),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_pedidoView.opcAlivioAlin),
                    ),
                  ),
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
          ],
        ),
        if (_pedidoView.modeloSuperior.length > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _baixarModelosLinks(
              link: _pedidoView.modeloSuperior[0].url ?? '',
              typeName: 'Baixar Superior',
            ),
          ),
        if (_pedidoView.modeloInferior.length > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _baixarModelosLinks(
              link: _pedidoView.modeloInferior[0].url ?? '',
              typeName: 'Baixar inferior',
            ),
          ),
        if (_screenSize!.width > 1115 &&
            (_pedidoView.modeloSuperior.isNotEmpty ||
                _pedidoView.modeloInferior.isNotEmpty))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _modeloVisivel = !_modeloVisivel;
                });
              },
              child: const Text(
                'Visualizar modelos',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                if (_pedidoView.modeloSuperior.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisualizarModeloSupV1(
                            key1: key1,
                          ),
                        ),
                      );
                    },
                    child: const Text('Modelo Superior'),
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_pedidoView.modeloInferior.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VisualizarModeloInfV1(
                            key1: key2,
                          ),
                        ),
                      );
                    },
                    child: const Text('Modelo Inferior'),
                  ),
              ],
            ),
          ),
        if (_modeloVisivel) _webViewModeloSuperior(),
      ],
    );
  }

  // --------- RELATÓRIO ---------------

  PedidoV1Model _getPedido() {
    return _pedidoStore!.getPedido(position: _args.messageInt);
  }

  bool _relatorioAprovadoLogic() {
    if (!_relatorioView.pedido!.pedidoRefinamento) {
      if (!_relatorioView.aprovado) {
        bool canUpdate = _checkListForAprovedPedido();
        if (!canUpdate) return true;
      } else {
        return false;
      }
    } else {
      if (!_relatorioView.aprovado) return true;
    }

    return false;
  }

  Widget _viewRelatorioText() {
    if (_relatorioView.pedido!.pedidoRefinamento) {
      return Text(
        'Relatório RL' +
            _relatorioView.id.toString() +
            ' do pedido de refinamento ' +
            _relatorioView.pedido!.codigoPedido,
      );
    } else {
      return Text(
        'Relatório RL' +
            _relatorioView.id.toString() +
            ' do pedido ' +
            _relatorioView.pedido!.codigoPedido,
      );
    }
  }

  String _formatLink(String s) {
    if (s.contains('https://') || s.contains('http://')) {
      return s;
    }
    return 'https://' + s;
  }

  Future<dynamic> imgViewPopup(String? link) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imagem'),
          content: Container(
            width: 800,
            height: 500,
            child: PhotoView(
              loadingBuilder: (context, event) {
                return Center(child: Text('Carregando...'));
              },
              maxScale: 2,
              imageProvider: NetworkImage(link ?? ''),
            ),
          ),
          actions: [
            Link(
              target: LinkTarget.defaultTarget,
              uri: Uri.parse(link ?? ''),
              builder: (BuildContext context, FollowLink? followLink) =>
                  TextButton(
                onPressed: followLink,
                child: Center(
                  child: const Text('Baixar'),
                ),
              ),
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar'),
            )
          ],
        );
      },
    );
  }

  Future<bool> _deletarRelatorio() async {
    try {
      var _response = await http.delete(
        Uri.parse(RotasUrl.rotaRelatoriosV1 + _relatorioView.id.toString()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
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
      print('deletarRelatório ->' + e.toString());
      return false;
    }
  }

  Future<dynamic> deleteRelatorioPopup() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: const Text('Deletar relatório')),
          content: Container(
            width: 500,
            height: 200,
            child: const Center(child: const Text('Deletar esse relatório?')),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  content: const Text(
                    'Deletando relatório...',
                    textAlign: TextAlign.center,
                  ),
                ));
                bool result = await _deletarRelatorio();
                if (result) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 3),
                    content: const Text(
                      'Ok',
                      textAlign: TextAlign.center,
                    ),
                  ));
                } else {
                  Navigator.pop(context, false);
                }
              },
              child: const Text('Confirmar'),
            ),
            const SizedBox(
              width: 50,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            )
          ],
        );
      },
    );
  }

  Widget _deletarRelatorioIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () async {
            bool result = await deleteRelatorioPopup();
            if (result) {
              setState(() {
                _selectedView = 0;
                isFetchHistorico = true;
              });
              await _fetchHistoricoPac();
              setState(() {
                isFetchHistorico = false;
              });
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 3),
                content: const Text(
                  'Não foi possível deletar esse relatório',
                  textAlign: TextAlign.center,
                ),
              ));
            }
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _newScreenRelatorioIcon() {
    return IconButton(
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VisualizarRelatorioV1(url: _relatorioView.relatorio?.url ?? ''),
          ),
        );
      },
      icon: const Icon(
        Icons.fit_screen,
        color: Colors.blue,
      ),
    );
  }

  Widget _viewRelatorio() {
    return Stack(
      children: [
        _newScreenRelatorioIcon(),
        Column(
          children: [
            if (_authStore!.role == 'Administrador' ||
                _authStore!.role == 'Gerente')
              _deletarRelatorioIcon(),
            _viewRelatorioText(),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  const Text('Link visualização 3d:'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Link(
                        target: LinkTarget.blank,
                        uri: Uri.parse(
                            _formatLink(_relatorioView.visualizador1)),
                        builder:
                            (BuildContext context, FollowLink? followLink) =>
                                TextButton(
                          onPressed: followLink,
                          child: const Text('Link'),
                        ),
                      ),
                      const Text('|    '),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: _formatLink(_relatorioView.visualizador1),
                            ),
                          );
                          _copySnackbar();
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: const Text(
                            'Copiar link',
                            style: const TextStyle(
                              color: DefaultColors.digitalAlignBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text('Link download do relatório:'),
                  SizedBox(
                    width: 400,
                    child: Wrap(
                      runAlignment: WrapAlignment.center,
                      children: [
                        Link(
                          target: LinkTarget.defaultTarget,
                          uri: Uri.parse(
                              _formatLink(_relatorioView.relatorio!.url ?? '')),
                          builder:
                              (BuildContext context, FollowLink? followLink) =>
                                  TextButton(
                            onPressed: followLink,
                            child: _relatorioView.relatorio!.url!.isNotEmpty
                                ? Center(child: const Text('Baixar relatório'))
                                : const Text('Vazio'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _relatorioAprovadoLogic() &&
                          _checkIfUserIsSame() &&
                          !isAprovando
                      ? () async {
                          setState(() {
                            isAprovando = true;
                          });
                          bool result = await _aprovarRelatorio();
                          if (result) {
                            await _fetchHistoricoPac();
                            setState(() {
                              isAprovando = false;
                            });
                          }
                        }
                      : null,
                  child: const Text('Aprovar'),
                ),
                TextButton(
                  onPressed: _relatorioAprovadoLogic() && _checkIfUserIsSame()
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
                enableDocumentLinkAnnotation: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _checkListForAprovedPedido() {
    bool doesExist = false;
    //only 1 pedido may be approved
    int pedidoAprovadoCount = 0;

    _historicoList.forEach((hist) {
      if (pedidoAprovadoCount >= 1) {
        doesExist = true;
        return;
      }
      if (hist.status!.codigoStatus == 'cs_rel') {
        if (!(hist.relatorio!.pedido!.pedidoRefinamento)) {
          if (hist.relatorio!.aprovado) pedidoAprovadoCount++;
        }
      }
    });
    return doesExist;
  }

  Future<bool> _aprovarRelatorio() async {
    if (!_relatorioView.pedido!.pedidoRefinamento) {
      bool doesExist = _checkListForAprovedPedido();

      if (doesExist) return false;
    }

    _relatorioView.payload = {'id_ped_selecionado': _getPedido().id};
    //changing aprovação to true
    _relatorioView.aprovado = true;
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

  Widget _baixarModelosLinks({String link = '', required String typeName}) {
    return Link(
      target: LinkTarget.defaultTarget,
      uri: Uri.parse(link),
      builder: (BuildContext context, FollowLink? followLink) => TextButton(
        onPressed: followLink,
        child: Center(
          child: Text(typeName),
        ),
      ),
    );
  }

  Widget _baixarModeloCompactado({String link = '', required String typeName}) {
    return Link(
      target: LinkTarget.defaultTarget,
      uri: Uri.parse(link),
      builder: (BuildContext context, FollowLink? followLink) => TextButton(
        onPressed: followLink,
        child: Center(
          child: Text(typeName),
        ),
      ),
    );
  }

// ---------- ALTERAÇÃO ---------------
  Future<bool> _sendSolicitarAlteracao() async {
    HistoricoPacV1 h = HistoricoPacV1(
      informacao: _solicitarAlteracao,
      pedido: _getPedido(),
      relatorio: RelatorioV1Model(
        id: _relatorioView.id,
        pedido: _relatorioView.pedido,
      ),
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
    return Column(
      children: [
        Text(_alteracaoView),
        Container(margin: EdgeInsets.only(top: 16), child: Divider(height: 8)),
        _commentsArea(),
      ],
    );
  }

  Widget _commentsArea() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 32),
            height: MediaQuery.of(context).size.height / 18,
            alignment: Alignment.centerLeft,
            child: Text(
              'Comentários',
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          _listOfMessages(),
          _bottomMessage()
        ],
      ),
    );
  }

  Widget _listOfMessages() {
    if (_commentList.isEmpty) {
      return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          alignment: Alignment.center,
          child: Text(
            'Não há comentários',
            style: TextStyle(
              color: Colors.grey,
            ),
          ));
    } else {
      return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          margin: EdgeInsets.only(top: 32, bottom: 4, left: 16, right: 16),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _commentList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Row(
                    //alinhar as mensagens por aqui
                    mainAxisAlignment: _commentList[index].idAutor == idUsuario
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _commentList[index].idAutor == idUsuario
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 4, bottom: 4),
                          width: _screenSize!.width <= _mediaQueryMd
                              ? MediaQuery.of(context).size.width * 0.3
                              : MediaQuery.of(context).size.width * 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "${_commentList[index].conteudo}",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 8, bottom: 8),
                                  child: Text(
                                      "${DateFormat('HH:mm').format(_commentList[index].data!)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      )))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }));
    }
  }

  Widget _bottomMessage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Row(
        children: [
          Flexible(
              flex: 5,
              child: new Container(
                padding: EdgeInsets.only(left: 16),
                margin: EdgeInsets.only(right: 8, left: 16),
                width: MediaQuery.of(context).size.width,
                child: new TextField(
                  maxLines: null,
                  controller: _messageController,
                  textAlign: TextAlign.start,
                  decoration: new InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    alignLabelWithHint: true,
                    border: InputBorder.none,
                  ),
                ),
              )),
          Expanded(
            child: Container(
              height: 40,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor),
              child: IconButton(
                onPressed: () {
                  //colocar service de envio aqui
                  _messageController.clear();
                },
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
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
                maxLength: 2000,
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
                      Navigator.pop(context);
                    }
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

  Future<void> _editarRefinamento() async {
    //set refinamento to provider
    _pedidoStore?.setRefinamento(_pedidoView);

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 200),
        content: Text(
          'Aguarde...',
          textAlign: TextAlign.center,
        ),
      ),
    );
    await Future.delayed(Duration(milliseconds: 200));
    try {
      Navigator.of(context)
          .pushNamed(
        PedidoV1Screen.routeName,
        arguments: ScreenArguments(
          title: _pedidoView.codigoPedido + ' (Refinamento)',
          messageMap: {'isEditarPaciente': true},
          messageInt: 0,
        ),
      )
          .then((_) async {
        if (true) {
          _pedidoStore?.removeRefinamento();
          await _fetchHistoricoPac();
          setState(() {
            _selectedView = 0;
            _selectedTilePos = -1;
          });
        }
      });
    } catch (e) {
      _pedidoStore?.removeRefinamento();
    }
  }

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;

    if (firstRun) {
      try {
        _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
      } catch (e) {
        print(e);
      }
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
    if (!_authStore!.isAuth) {
      return LoginScreen(
        showLoginMessage: true,
      );
    }
    //busca o id usuario
    _historicoList.forEach((element) {
      idUsuario = element.pedido?.usuario?.id;
    });

    return Scaffold(
      appBar: SecondaryAppbar(),
      drawer: null,
      body: RawScrollbar(
        radius: Radius.circular(10),
        thumbColor: Colors.grey,
        thickness: 15,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            height: _screenSize!.width < 768 ? 3050 : 2850,
            padding: _screenSize!.width <= _mediaQueryMd
                ? const EdgeInsets.symmetric(horizontal: 0)
                : const EdgeInsets.symmetric(horizontal: 100),
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
