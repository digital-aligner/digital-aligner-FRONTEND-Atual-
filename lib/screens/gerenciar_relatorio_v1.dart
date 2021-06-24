import 'dart:convert';

import 'package:digital_aligner_app/appbar/MyDrawer.dart';
import 'package:digital_aligner_app/appbar/SecondaryAppbar.dart';
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/pedido_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/relatorio_v1_model.dart';
import 'package:digital_aligner_app/widgets/screen%20argument/screen_argument.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_grid/responsive_grid.dart';

import '../rotas_url.dart';
import 'screens_pedidos_v1/uploader/file_uploader.dart';
import 'screens_pedidos_v1/uploader/model/FileModel.dart';

class GerenciarRelatorioV1 extends StatefulWidget {
  static const routeName = '/gerenciar-relatorio-v1';
  const GerenciarRelatorioV1({Key? key}) : super(key: key);

  @override
  GerenciarRelatorioV1State createState() => GerenciarRelatorioV1State();
}

class GerenciarRelatorioV1State extends State<GerenciarRelatorioV1> {
  PedidoProvider? _pedidoStore;
  AuthProvider? _authStore;
  Size? _screenSize;
  bool firstRun = true;
  bool isFetchHistorico = true;

  //route arguments
  ScreenArguments _args = ScreenArguments();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //form vars
  String _vis1 = '';
  String _vis2 = '';

  //managing upload
  List<PlatformFile> _filesData = <PlatformFile>[];
  List<FileModel> _serverFiles = [];

  //manage ui states
  bool hasError = false;
  bool blockUi = false;

  Widget _header() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          _args.title,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
    );
  }

  Widget _pacienteDados() {
    var pedido = _pedidoStore!.getPedido(position: _args.messageInt);

    return Card(
      elevation: 10,
      child: SizedBox(
        width: 300,
        height: 300,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Image.asset('logos/user_avatar.png'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido: DA' + pedido.id.toString()),
                  Text('Credenciado: ' +
                      pedido.usuario!.nome +
                      ' ' +
                      pedido.usuario!.sobrenome),
                  Text('Cpf: ' + pedido.usuario!.username),
                  Text('Paciente: ' + pedido.nomePaciente),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _visualizador1() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLength: 60,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        onChanged: (value) {
          _vis1 = value;
        },
        decoration: const InputDecoration(
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Visualizador 3D *',
        ),
      ),
    );
  }

  Widget _visualizador2() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        maxLength: 60,
        enabled: true,
        validator: (String? value) {
          return value == null || value.isEmpty ? 'Campo vazio' : null;
        },
        onChanged: (value) {
          _vis2 = value;
        },
        decoration: const InputDecoration(
          border: const OutlineInputBorder(),
          counterText: '',
          labelText: 'Visualizador 3D (segunda opção) *',
        ),
      ),
    );
  }

  ScaffoldFeatureController _scaffoldMessage(String e) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          e,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  int _getPedidoId() {
    var pedido = _pedidoStore!.getPedido(position: _args.messageInt);
    return pedido.id;
  }

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
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
      print(e);
    }
  }

  Future<bool> _newFiledelete(int id) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeletePhoto + id.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authStore!.token}',
      },
    );
    var data = json.decode(_response.body);

    if (data.containsKey('id')) return true;

    return false;
  }

  Widget _fileUi() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: <Widget>[
            if (hasError)
              const Image(
                fit: BoxFit.cover,
                width: 100,
                image: const AssetImage('logos/error.jpg'),
              ),
            if (!hasError && _serverFiles.length > 0)
              const Image(
                fit: BoxFit.cover,
                width: 100,
                image: const AssetImage('logos/pdf.png'),
              ),
            if (blockUi || _serverFiles.length > 0)
              IconButton(
                color: Colors.blueAccent,
                icon: const Icon(Icons.delete),
                onPressed: blockUi
                    ? null
                    : () async {
                        setState(() => blockUi = true);
                        bool result = false;
                        try {
                          result =
                              await _newFiledelete(_serverFiles[0].id as int);
                        } catch (e) {
                          setState(() => blockUi = false);
                        }

                        if (result)
                          setState(() {
                            _serverFiles.remove(_serverFiles[0]);
                            blockUi = false;
                            hasError = false;
                          });
                      },
              ),
          ],
        ),
      ),
    );
  }

  Widget _relatorioBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: blockUi
                ? null
                : () async {
                    await _openFileExplorer().catchError((e) {
                      _scaffoldMessage(e);
                    });

                    setState(() {
                      blockUi = true;
                    });
                    if (_filesData.isNotEmpty) {
                      await _sendFile(_filesData[0]);
                      _filesData = [];
                    }

                    setState(() {
                      blockUi = false;
                    });
                  },
            child: Text(
              'CARREGAR RELATÓRIO',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _managePdf() {
    return Column(
      children: <Widget>[
        _relatorioBtn(),
        _fileUi(),
      ],
    );
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withReadStream: true,
    );

    if (result != null) {
      if (result.files.length + _serverFiles.length <= 1) {
        _filesData = result.files;
      } else {
        throw ('Selecione até 1 arquivos.');
      }
    } else {
      throw ('Nenhum arquivo escolhido.');
    }
  }

  Widget _enviarRelatorioBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: blockUi
                ? null
                : () async {
                    //verifications
                    if (_serverFiles.isEmpty) {
                      _scaffoldMessage(
                          'Por favor carregue um relatório antes de enviar');
                      return;
                    }

                    setState(() {
                      blockUi = true;
                    });

                    if (_formKey.currentState!.validate()) {
                      await _enviarPrimeiroPedido();
                    }
                    setState(() {
                      blockUi = false;
                    });
                  },
            child: Text(
              'ENVIAR RELATÓRIO',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _enviarPrimeiroPedido() async {
    //map fields to relatorio object and insert relatorio/pdf object from server
    RelatorioV1Model r = RelatorioV1Model(
        id: 0,
        visualizador1: _vis1,
        visualizador2: _vis2,
        aprovado: false,
        relatorio: _serverFiles[0],
        payload: {
          'id_pedido': _getPedidoId(),
        });

    try {
      var _response = await http.post(
        Uri.parse(RotasUrl.rotaRelatoriosV1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_authStore!.token}',
        },
        body: json.encode(r.toJson()),
      );
      try {
        var data = json.decode(_response.body);
        if (data.containsKey('id')) {
          print('ok!');
          return true;
        }
      } catch (e) {
        print(e);
        return false;
      }

      return false;
    } catch (e) {
      print('enviarPrimeiroRelatório ->' + e.toString());
      return false;
    }
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _visualizador1(),
          _visualizador2(),
          _managePdf(),
          _enviarRelatorioBtn(),
        ],
      ),
    );
  }

  Widget _pacienteAndRelatorioLayout() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Column(
          children: [
            _pacienteDados(),
          ],
        ),
        Card(
          child: Container(
            padding: EdgeInsets.all(20),
            width: 800,
            child: _form(),
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

  //--------- VIEW PEDIDO WIDGET ------------

  @override
  void didChangeDependencies() async {
    _authStore = Provider.of<AuthProvider>(context);
    _pedidoStore = Provider.of<PedidoProvider>(context);
    _screenSize = MediaQuery.of(context).size;

    if (firstRun) {
      _args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
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
            height: _screenSize!.width < 1200 ? 1000 : 800,
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              children: <Widget>[
                _header(),
                _pacienteAndRelatorioLayout(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
