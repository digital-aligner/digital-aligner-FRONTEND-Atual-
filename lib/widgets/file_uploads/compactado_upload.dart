import 'dart:convert';
import 'dart:math';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:http/http.dart' as http;
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../rotas_url.dart';
import './multipart_request.dart';
import 'compactado_model.dart';
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class CompactadoUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;

  CompactadoUpload({
    this.isEdit,
    this.pedidoDados,
    @required this.blockUi,
  });
  @override
  _CompactadoUploadState createState() => _CompactadoUploadState();
}

class _CompactadoUploadState extends State<CompactadoUpload>
    with AutomaticKeepAliveClientMixin<CompactadoUpload> {
  @override
  bool get wantKeepAlive => true;
  bool _isFetchEdit = true;

  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;
  //Clear after sending to server
  List<PlatformFile> _compactUploadsDataList = <PlatformFile>[];
  //List<PlatformFile> _compactUploadsDataList =  List<PlatformFile>();
  //New compactUpload object with id and image url from server
  List<CompactadoModel> _compactUploadsList = <CompactadoModel>[];
  //List<CompactadoModel> _compactUploadsList = List<CompactadoModel>();
  Future<dynamic> _deletecompactUpload(_token, compactUploadId) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeletecompactUpload + compactUploadId.toString()),
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
      allowedExtensions: ['zip', 'rar'],
      allowMultiple: false,
    );
    if (result != null &&
        result.files.length + _compactUploadsList.length <= 1) {
      _compactUploadsDataList = result.files;
    } else {
      throw ('Excedeu número máximo de modelos compactados');
    }
  }

  List<Widget> _uiManagecompactUploads(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curcompactUpload in _compactUploadsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              curcompactUpload.imageUrl == null
                  ? Center(
                      child: CircularProgressIndicator(
                        value: curcompactUpload.progress,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Image(
                      fit: BoxFit.cover,
                      width: 100,
                      image: AssetImage('logos/comp.jpg'),
                    ),
              SizedBox(width: 10),
              curcompactUpload.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curcompactUpload.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curcompactUpload.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            _s3deleteStore.setIdToDelete(curcompactUpload.id);
                            setState(() {
                              _compactUploadsList.removeWhere(
                                (compactUpload) =>
                                    compactUpload.id == curcompactUpload.id,
                              );
                            });
                          } else {
                            _deletecompactUpload(_token, curcompactUpload.id)
                                .then((res) {
                              var data = json.decode(res.body);
                              if (data['id'] != null) {
                                setState(() {
                                  _compactUploadsList.removeWhere(
                                    (compactUpload) =>
                                        compactUpload.id == data['id'],
                                  );
                                });
                              }
                            });
                          }
                        },
                ),
              if (curcompactUpload.id == null) Container(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _compactUploadsDataList = null;
    return _ump;
  }

  Future<void> _sendcompactUpload(_token, _currentcompactUpload) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);
    CompactadoModel pm = CompactadoModel(listId: rNum);
    setState(() {
      _compactUploadsList.add(pm);
    });

    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      _currentcompactUpload.bytes,
      filename: _currentcompactUpload.name,
    ));

    try {
      var response = await request.send();
      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      if (resData[0]['id'] != null) {
        for (int i = 0; i < _compactUploadsList.length; i++) {
          if (_compactUploadsList[i].listId == rNum) {
            setState(() {
              _compactUploadsList[i].id = resData[0]['id'];
              _compactUploadsList[i].fileName = resData[0]['name'];
              _compactUploadsList[i].imageUrl = resData[0]['url'];
            });
          }
        }
      }
    } catch (e) {
      print(e);
      for (int i = 0; i < _compactUploadsList.length; i++) {
        if (_compactUploadsList[i].listId == rNum) {
          setState(() {
            _compactUploadsList[i].id = -1;
            _compactUploadsList[i].fileName =
                'Algo deu errado, por favor tente novamente.';
            _compactUploadsList[i].imageUrl = '';
          });
        }
      }
    }
  }

//FOR EDIT SCREEN
  Future<dynamic> _getModeloComp(_token) async {
    var _response = await http.post(
      Uri.parse(RotasUrl.rotaModeloCompactadoList),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'modelo_compactado': widget.pedidoDados['modelo_compactado']
            ['modelo_compactado_id'],
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          CompactadoModel pm = CompactadoModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.imageUrl = resData[i]['url'];
          _compactUploadsList.add(pm);
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
      _getModeloComp(_authStore.token);
    }

    if (_compactUploadsList.isNotEmpty) {
      _novoPedStore.setModeloCompactadoList(_compactUploadsList);
    } else {
      _novoPedStore.setModeloCompactadoList(null);
    }

    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 300,
              child: ElevatedButton(
                onPressed: widget.blockUi
                    ? null
                    : () {
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
                              content: const Text(
                                'Enviando modelos compactado. Por ser um arquivo grande, por favor aguarde...',
                              ),
                            ),
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            for (var compactUpload in _compactUploadsDataList) {
                              _sendcompactUpload(
                                  _authStore.token, compactUpload);
                            }
                          });
                        }).catchError((e) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: Text('Selecione no máximo 1 arquivo!'),
                            ),
                          );
                        });
                      },
                child: const Text(
                  'MODELOS COMPACTADO',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            //Showing loaded images, if any.
            _compactUploadsList != null
                ? Column(
                    children: _uiManagecompactUploads(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
