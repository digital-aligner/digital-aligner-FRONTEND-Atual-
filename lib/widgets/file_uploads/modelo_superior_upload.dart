import 'dart:convert';

import 'dart:math';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
//import 'package:dio/dio.dart';

import 'package:http/http.dart' as http;

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:multipart_request/multipart_request.dart';
import 'package:provider/provider.dart';

import '../../rotas_url.dart';

import 'modelo_superior.dart';
import 'multipart_request.dart';
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

  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;
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
                    if (widget.isEdit) {
                      _s3deleteStore.setIdToDelete(curmodeloSup.id);
                      setState(() {
                        _modeloSupsList.removeWhere(
                          (modeloSup) => modeloSup.id == curmodeloSup.id,
                        );
                      });
                    } else {
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
                    }
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

    if (resData[0]['id'] != null) {
      for (int i = 0; i < _modeloSupsList.length; i++) {
        if (_modeloSupsList[i].listId == rNum) {
          setState(() {
            _modeloSupsList[i].id = resData[0]['id'];
            _modeloSupsList[i].fileName = resData[0]['name'];
            _modeloSupsList[i].imageUrl = resData[0]['url'];
          });
        }
      }
    }
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

    _authStore = Provider.of<AuthProvider>(context);
    _novoPedStore = Provider.of<PedidoProvider>(context);
    //Don't need to listen to changes, just delete on s3
    _s3deleteStore = Provider.of<S3DeleteProvider>(
      context,
      listen: false,
    );
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
