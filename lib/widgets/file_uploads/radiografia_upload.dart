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

import './radiografia_model.dart';
import './multipart_request.dart';

//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class RadiografiaUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;
  RadiografiaUpload({
    this.isEdit,
    this.pedidoDados,
    @required this.blockUi,
  });

  @override
  _RadiografiaUploadState createState() => _RadiografiaUploadState();
}

class _RadiografiaUploadState extends State<RadiografiaUpload>
    with AutomaticKeepAliveClientMixin<RadiografiaUpload> {
  @override
  bool get wantKeepAlive => true;
  bool _isFetchEdit = true;
  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;
  //Clear after sending to server
  List<PlatformFile> _radiografiasDataList = <PlatformFile>[];

  //New radiografia object with id and image url from server
  List<RadiografiaModel> _radiografiasList = <RadiografiaModel>[];

  Future<dynamic> _deleteRadiografia(_token, radiografiaId) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeleteRadiografia + radiografiaId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    return _response;
  }

  Future<void> _sendRadiografia(_token, _currentRadiografia) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);
    RadiografiaModel pm = RadiografiaModel(listId: rNum);
    setState(() {
      _radiografiasList.add(pm);
    });

    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        for (int i = 0; i < _radiografiasList.length; i++) {
          if (_radiografiasList[0].listId == pm.listId) {
            setState(() {
              _radiografiasList[0].progress = progress;
            });
          }
        }
        print('progress: $progress % ($bytes/$total)');
      },
    );
    request.headers['authorization'] = 'Bearer $_token';

    request.files.add(http.MultipartFile.fromBytes(
      'files',
      _currentRadiografia.bytes,
      filename: _currentRadiografia.name,
    ));
    try {
      var response = await request.send();
      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      if (resData[0].containsKey('id')) {
        for (int i = 0; i < _radiografiasList.length; i++) {
          if (_radiografiasList[i].listId == rNum) {
            setState(() {
              _radiografiasList[i].id = resData[0]['id'];
              _radiografiasList[i].fileName = resData[0]['name'];
              _radiografiasList[i].imageUrl = resData[0]['url'];
              _radiografiasList[i].thumbnail =
                  resData[0]['formats']['thumbnail']['url'];
            });
          }
        }
      }
    } catch (e) {
      for (int i = 0; i < _radiografiasList.length; i++) {
        if (_radiografiasList[i].listId == rNum) {
          setState(() {
            _radiografiasList[i].id = -1;
            _radiografiasList[i].fileName =
                'Algo deu errado, por favor tente novamente.';
            _radiografiasList[i].imageUrl = '';
            _radiografiasList[i].thumbnail = '';
          });
        }
      }
      print(e);
    }
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'jpe', 'gif', 'png'],
      allowMultiple: true,
    );
    if (result != null && result.files.length + _radiografiasList.length <= 4) {
      _radiografiasDataList = result.files;
    } else {
      throw ('Excedeu número máximo de radiografias');
    }
  }

  List<Widget> _uiManageRadiografias(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curRadiografia in _radiografiasList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              curRadiografia.thumbnail == null
                  ? Center(
                      child: CircularProgressIndicator(
                        value: curRadiografia.progress,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Image.network(
                      curRadiografia.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
              SizedBox(width: 10),
              curRadiografia.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curRadiografia.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curRadiografia.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            _s3deleteStore.setIdToDelete(curRadiografia.id);
                            setState(() {
                              _radiografiasList.removeWhere(
                                (radiografia) =>
                                    radiografia.id == curRadiografia.id,
                              );
                            });
                          } else {
                            _deleteRadiografia(_token, curRadiografia.id)
                                .then((res) {
                              var data = json.decode(res.body);
                              if (data['id'] != null) {
                                setState(() {
                                  _radiografiasList.removeWhere(
                                    (radiografia) =>
                                        radiografia.id == data['id'],
                                  );
                                });
                              }
                            });
                          }
                        },
                ),
              if (curRadiografia.id == null) Container(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _radiografiasDataList = null;
    return _ump;
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getRadiografias(_token) async {
    var _response = await http.post(
      Uri.parse(RotasUrl.rotaRadiografiasList),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'foto1_id': widget.pedidoDados['radiografias']['foto1_id'],
        'foto2_id': widget.pedidoDados['radiografias']['foto2_id'],
        'foto3_id': widget.pedidoDados['radiografias']['foto3_id'],
        'foto4_id': widget.pedidoDados['radiografias']['foto4_id'],
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          RadiografiaModel pm = RadiografiaModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
          pm.imageUrl = resData[i]['url'];
          _radiografiasList.add(pm);
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
      _getRadiografias(_authStore.token);
    }

    if (_radiografiasList.isNotEmpty) {
      _novoPedStore.setRadiografiasList(_radiografiasList);
    } else {
      _novoPedStore.setRadiografiasList(null);
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
                              content: Text('Enviando radiografias...'),
                            ),
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            for (var radiografia in _radiografiasDataList) {
                              _sendRadiografia(_authStore.token, radiografia);
                            }
                          });
                        }).catchError((e) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content:
                                  Text('Selecione no máximo 4 radiografias!'),
                            ),
                          );
                        });
                      },
                child: const Text(
                  'CARREGAR RADIOGRAFIAS',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            //Showing loaded images, if any.
            _radiografiasList != null
                ? Column(
                    children: _uiManageRadiografias(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
