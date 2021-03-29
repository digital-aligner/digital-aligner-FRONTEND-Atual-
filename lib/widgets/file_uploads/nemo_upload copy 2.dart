import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:http/http.dart' as http;
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import '../../rotas_url.dart';
import './multipart_request.dart';
import 'nemo_model.dart';
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class NemoUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;
  NemoUpload({
    this.isEdit,
    this.pedidoDados,
    this.blockUi,
  });
  @override
  _NemoUploadState createState() => _NemoUploadState();
}

class _NemoUploadState extends State<NemoUpload>
    with AutomaticKeepAliveClientMixin<NemoUpload> {
  @override
  bool get wantKeepAlive => true;
  bool _isFetchEdit = true;

  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;
  //Clear after sending to server
  List<PlatformFile> _nemoUploadsDataList = <PlatformFile>[];
  //List<PlatformFile> _nemoUploadsDataList =  List<PlatformFile>();
  //New nemoUpload object with id and image url from server
  List<NemoModel> _nemoUploadsList = <NemoModel>[];
  //List<NemoModel> _nemoUploadsList = List<NemoModel>();
  Future<dynamic> _deleteNemoUpload(_token, nemoUploadId) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeleteNemoUpload + nemoUploadId.toString()),
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
      allowedExtensions: ['nmz'],
      allowMultiple: false,
      withReadStream: true,
    );
    if (result != null && result.files.length + _nemoUploadsList.length <= 1) {
      _nemoUploadsDataList = result.files;
    } else {
      throw ('Excedeu número máximo de modelos do nemo');
    }
  }

  List<Widget> _uiManagenemoUploads(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curnemoUpload in _nemoUploadsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              if (curnemoUpload.id == null)
                Center(
                  child: CircularProgressIndicator(
                    value: curnemoUpload.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (curnemoUpload.id == -1)
                Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: AssetImage('logos/error.png'),
                )
              else
                Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: AssetImage('logos/nemo_logo.png'),
                ),
              const SizedBox(width: 10),
              curnemoUpload.fileName == null
                  ? const Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curnemoUpload.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curnemoUpload.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            _s3deleteStore.setIdToDelete(curnemoUpload.id);
                            setState(() {
                              _nemoUploadsList.removeWhere(
                                (nemoUpload) =>
                                    nemoUpload.id == curnemoUpload.id,
                              );
                            });
                          } else {
                            _deleteNemoUpload(_token, curnemoUpload.id)
                                .then((res) {
                              var data = json.decode(res.body);
                              if (data['id'] != null) {
                                setState(() {
                                  _nemoUploadsList.removeWhere(
                                    (nemoUpload) => nemoUpload.id == data['id'],
                                  );
                                });
                              }
                            });
                          }
                        },
                ),
              if (curnemoUpload.id == null) Container(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _nemoUploadsDataList = null;
    return _ump;
  }

  Future<void> _sendnemoUpload(_token, PlatformFile _currentnemoUpload) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);
    NemoModel pm = NemoModel(listId: rNum);

    int posContainingWidget = 0;

    setState(() {
      _nemoUploadsList.add(pm);
      for (int i = 0; i < _nemoUploadsList.length; i++) {
        if (_nemoUploadsList[i].listId == rNum) {
          posContainingWidget = i;
        }
      }
    });

    try {
      Map<String, String> data = {
        'files': _currentnemoUpload.readStream.toString(),
        'filename': _currentnemoUpload.name,
      };

      Map<String, String> headers = {
        'authorization': 'Bearer $_token',
        'content-type': 'application/octet-stream',
      };

      var resData = await html.HttpRequest.postFormData(
        RotasUrl.rotaUpload,
        data,
        requestHeaders: headers,
        onProgress: (e) {
          print(e.loaded.toStringAsFixed(3));
        },
      ).then((value) => null).then((value) => json.decode(value));

      if (resData[0]['id'] != null) {
        for (int i = 0; i < _nemoUploadsList.length; i++) {
          if (_nemoUploadsList[i].listId == rNum) {
            setState(() {
              _nemoUploadsList[i].id = resData[0]['id'];
              _nemoUploadsList[i].fileName = resData[0]['name'];
              _nemoUploadsList[i].imageUrl = resData[0]['url'];
            });
          }
        }
      }
    } catch (e) {
      for (int i = 0; i < _nemoUploadsList.length; i++) {
        if (_nemoUploadsList[i].listId == rNum) {
          setState(() {
            _nemoUploadsList[i].id = -1;
            _nemoUploadsList[i].fileName =
                'Algo deu errado, por favor tente novamente.';
            _nemoUploadsList[i].imageUrl = '';
          });
        }
      }
      print(e);
    }
  }

//FOR EDIT SCREEN
  Future<dynamic> _getModeloNemo(_token) async {
    var resData;
    try {
      var _response = await http.post(
        Uri.parse(RotasUrl.rotaModeloNemoList),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'modelo_nemo': widget.pedidoDados['modelo_nemo']['modelo_nemo_id'],
        }),
      );
      resData = json.decode(_response.body);

      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          NemoModel pm = NemoModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.imageUrl = resData[i]['url'];
          _nemoUploadsList.add(pm);
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
      _getModeloNemo(_authStore.token);
    }

    if (_nemoUploadsList.isNotEmpty) {
      _novoPedStore.setModeloNemoList(_nemoUploadsList);
    } else {
      _novoPedStore.setModeloNemoList(null);
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
                                'Enviando modelo nemo. Por favor aguarde...',
                              ),
                            ),
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            for (PlatformFile nemoUpload
                                in _nemoUploadsDataList) {
                              _sendnemoUpload(_authStore.token, nemoUpload);
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
                  'MODELO NEMO',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            //Showing loaded images, if any.
            _nemoUploadsList != null
                ? Column(
                    children: _uiManagenemoUploads(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
