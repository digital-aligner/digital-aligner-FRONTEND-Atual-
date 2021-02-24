import 'dart:convert';
import 'dart:math';
import 'package:digital_aligner_app/providers/pedido_provider.dart';

import 'package:http/http.dart' as http;

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart';
import 'package:provider/provider.dart';
//import 'package:universal_io/io.dart';
import '../../rotas_url.dart';

import 'package:multipart_request/multipart_request.dart';

//import './multipart_request.dart';

import 'modelo_superior.dart';
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class ModeloSuperiorUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  ModeloSuperiorUpload({
    this.isEdit,
    this.pedidoDados,
  });
  @override
  _ModeloSuperiorUploadState createState() => _ModeloSuperiorUploadState();
}

class _ModeloSuperiorUploadState extends State<ModeloSuperiorUpload>
    with AutomaticKeepAliveClientMixin<ModeloSuperiorUpload> {
  @override
  bool get wantKeepAlive => true;
  bool _isFetchEdit = true;
  //Clear after sending to server
  List<PlatformFile> _modeloSupsDataList = <PlatformFile>[];

  //New modeloSup object with id and image url from server
  List<ModeloSuperiorModel> _modeloSupsList = <ModeloSuperiorModel>[];

  Future<dynamic> _deletemodeloSup(_token, modeloSupId) async {
    var _response = await http.delete(
      RotasUrl.rotaDeleteModeloSup + modeloSupId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    return _response;
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['stl'],
      allowMultiple: false,
    );
    if (result != null && result.files.length + _modeloSupsList.length <= 1) {
      _modeloSupsDataList = result.files;
    } else {
      throw ('Excedeu número máximo de modelos');
    }
  }

  List<Widget> _uiManagemodeloSups(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curmodeloSup in _modeloSupsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              curmodeloSup.imageUrl == null
                  ? Center(
                      child: CircularProgressIndicator(
                        value: curmodeloSup.progress,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Image(
                      fit: BoxFit.cover,
                      width: 100,
                      image: AssetImage('logos/cubo.jpg'),
                    ),
              SizedBox(width: 10),
              curmodeloSup.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curmodeloSup.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curmodeloSup.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: () {
                    _deletemodeloSup(_token, curmodeloSup.id).then((res) {
                      var data = json.decode(res.body);
                      if (data['id'] != null) {
                        setState(() {
                          _modeloSupsList.removeWhere(
                            (modeloSup) => modeloSup.id == data['id'],
                          );
                        });
                      }
                    });
                  },
                ),
              if (curmodeloSup.id == null) Container(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _modeloSupsDataList = null;
    return _ump;
  }

  Future<void> _sendmodeloSup(_token, _currentmodeloSup) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);
    ModeloSuperiorModel pm = ModeloSuperiorModel(listId: rNum);

    setState(() {
      _modeloSupsList.add(pm);
    });
    /*
    final uri = Uri.parse(RotasUrl.rotaUpload);
    final request = MultipartRequest(
      'POST',
      uri,
    );
    request.headers['authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      _currentmodeloSup.bytes,
      filename: _currentmodeloSup.name,
    ));
    var response = await request.send();
    var resStream = await response.stream.bytesToString();
    var resData = json.decode(resStream);
    print(resData);
  */

    /*
    var dio = Dio();
    dio.options.headers['content-type'] = 'multipart/form-data';
    dio.options.headers['authorization'] = 'Bearer $_token';

    FormData formData = FormData.fromMap({
      'files': MultipartFile.fromBytes(
        _currentmodeloSup.bytes,
        filename: _currentmodeloSup.name,
      ),
    });

    Response response = await dio.post(
      RotasUrl.rotaUpload,
      data: formData,
      onSendProgress: (int sent, int total) {
        double curr = ((sent / total) * 1);
        setState(() {
          _modeloSupsList[0].progress = curr;
        });
        print("$curr of 1");
      },
    );*/

    var request = MultipartRequest();

    request.setUrl(RotasUrl.rotaUpload);
    request.addFile('application/octet-stream', _currentmodeloSup.bytes);
    request.addHeaders({
      'authorization': 'Bearer $_token',
      'content-type': 'multipart/form-data',
    });
    //Response response = request.send();
    /*
    final uri = Uri.parse(RotasUrl.rotaUpload);
    final request = http.MultipartRequest(
      'POST',
      uri,
    );
    request.headers['authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      _currentmodeloSup.bytes,
      filename: _currentmodeloSup.name,
    )); */

    Response response = request.send();

    response.onError = () {
      print("Error");
    };

    response.onComplete = (response) {
      print(response);
    };

    response.progress.listen((int progress) {
      print("progress from response object " + progress.toString());
    });
    /*
    if (response.data[0]['id'] != null) {
      for (int i = 0; i < _modeloSupsList.length; i++) {
        if (_modeloSupsList[i].listId == rNum) {
          setState(() {
            _modeloSupsList[i].id = response.data[0]['id'];
            _modeloSupsList[i].fileName = response.data[0]['name'];
            _modeloSupsList[i].imageUrl = response.data[0]['url'];
          });
        }
      }
    }*/
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getModeloSup(_token) async {
    print(widget.pedidoDados.toString());

    var _response = await http.post(
      RotasUrl.rotaModeloSuperiorList,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'modelo_superior': widget.pedidoDados['modelo_superior']
            ['modelo_superior_id'],
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          ModeloSuperiorModel pm =
              ModeloSuperiorModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.imageUrl = resData[i]['url'];
          _modeloSupsList.add(pm);
        }
      }
      setState(() {
        _isFetchEdit = false;
      });
    } catch (error) {
      print(error);
    }

    return resData;
  }

  @override
  Widget build(BuildContext context) {
    //For the "wantToKeepAlive" mixin
    super.build(context);

    AuthProvider _authStore = Provider.of<AuthProvider>(context);
    PedidoProvider _novoPedStore = Provider.of<PedidoProvider>(context);

    if (widget.isEdit && _isFetchEdit) {
      _getModeloSup(_authStore.token);
    }

    if (_modeloSupsList.isNotEmpty) {
      _novoPedStore.setModeloSuperiorList(_modeloSupsList);
    } else {
      _novoPedStore.setModeloSuperiorList(null);
    }

    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 8),
                      content: const Text('Aguarde...'),
                    ),
                  );

                  _openFileExplorer().then((_) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(
                            'Enviando modelo superior. Por ser um arquivo grande, por favor aguarde...'),
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 500), () {
                      for (var modeloSup in _modeloSupsDataList) {
                        _sendmodeloSup(_authStore.token, modeloSup);
                      }
                    });
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text('Selecione no máximo 1 modelo!'),
                      ),
                    );
                  });
                },
                child: const Text(
                  'MODELO SUPERIOR',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            //Showing loaded images, if any.
            _modeloSupsList != null
                ? Column(
                    children: _uiManagemodeloSups(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
