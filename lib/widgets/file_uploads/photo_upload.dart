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

import './photo_model.dart';

import './multipart_request.dart';

//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class PhotoUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;
  PhotoUpload({
    this.isEdit,
    this.pedidoDados,
    @required this.blockUi,
  });

  @override
  _PhotoUploadState createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload>
    with AutomaticKeepAliveClientMixin<PhotoUpload> {
  @override
  bool get wantKeepAlive => true;

  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;
  bool _isFetchEdit = true;

  //Clear after sending to server
  List<PlatformFile> _photosDataList = <PlatformFile>[];

  //New photo object with id and image url from server
  List<PhotoModel> _photosList = <PhotoModel>[];
  //For novo pedido screen
  Future<dynamic> _deletePhoto(_token, photoId) async {
    var _response = await http.delete(
      RotasUrl.rotaDeletePhoto + photoId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    return _response;
  }

  Future<void> _sendPhoto(_token, _currentPhoto) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);
    PhotoModel pm = PhotoModel(listId: rNum);
    setState(() {
      _photosList.add(pm);
    });

    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
      onProgress: (int bytes, int total) {
        final progress = bytes / total;
        for (int i = 0; i < _photosList.length; i++) {
          if (_photosList[0].listId == pm.listId) {
            setState(() {
              _photosList[0].progress = progress;
            });
          }
        }
        print('progress: $progress % ($bytes/$total)');
      },
    );

    request.headers['authorization'] = 'Bearer $_token';
    request.files.add(http.MultipartFile.fromBytes(
      'files',
      _currentPhoto.bytes,
      filename: _currentPhoto.name,
    ));
    try {
      var response = await request.send();
      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      if (resData[0].containsKey('id')) {
        for (int i = 0; i < _photosList.length; i++) {
          if (_photosList[i].listId == rNum) {
            setState(() {
              _photosList[i].id = resData[0]['id'];
              _photosList[i].fileName = resData[0]['name'];
              _photosList[i].thumbnail =
                  resData[0]['formats']['thumbnail']['url'];
              _photosList[i].imageUrl = resData[0]['url'];
            });
          }
        }
      }
    } catch (e) {
      for (int i = 0; i < _photosList.length; i++) {
        if (_photosList[i].listId == rNum) {
          setState(() {
            _photosList[i].id = -1;
            _photosList[i].fileName =
                'Algo deu errado, por favor tente novamente.';
            _photosList[i].thumbnail = '';
            _photosList[i].imageUrl = '';
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
    if (result != null && result.files.length + _photosList.length <= 16) {
      _photosDataList = result.files;
    } else {
      throw ('Excedeu número máximo de imagens');
    }
  }

  List<Widget> _uiManagePhotos(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curPhoto in _photosList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              curPhoto.thumbnail == null
                  ? Center(
                      child: CircularProgressIndicator(
                        value: curPhoto.progress,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Image.network(
                      curPhoto.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
              SizedBox(width: 10),
              curPhoto.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curPhoto.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curPhoto.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            _s3deleteStore.setIdToDelete(curPhoto.id);
                            setState(() {
                              _photosList.removeWhere(
                                (photo) => photo.id == curPhoto.id,
                              );
                            });
                          } else {
                            _deletePhoto(_token, curPhoto.id).then((res) {
                              var data = json.decode(res.body);
                              if (data['id'] != null) {
                                setState(() {
                                  _photosList.removeWhere(
                                    (photo) => photo.id == data['id'],
                                  );
                                });
                              }
                            });
                          }
                        },
                ),
              if (curPhoto.id == null) Container(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _photosDataList = null;
    return _ump;
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getPhotos(_token) async {
    var _response = await http.post(
      RotasUrl.rotafotografiasList,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'foto1_id': widget.pedidoDados['fotografias']['foto1_id'],
        'foto2_id': widget.pedidoDados['fotografias']['foto2_id'],
        'foto3_id': widget.pedidoDados['fotografias']['foto3_id'],
        'foto4_id': widget.pedidoDados['fotografias']['foto4_id'],
        'foto5_id': widget.pedidoDados['fotografias']['foto5_id'],
        'foto6_id': widget.pedidoDados['fotografias']['foto6_id'],
        'foto7_id': widget.pedidoDados['fotografias']['foto7_id'],
        'foto8_id': widget.pedidoDados['fotografias']['foto8_id'],
        'foto9_id': widget.pedidoDados['fotografias']['foto9_id'],
        'foto10_id': widget.pedidoDados['fotografias']['foto10_id'],
        'foto11_id': widget.pedidoDados['fotografias']['foto11_id'],
        'foto12_id': widget.pedidoDados['fotografias']['foto12_id'],
        'foto13_id': widget.pedidoDados['fotografias']['foto13_id'],
        'foto14_id': widget.pedidoDados['fotografias']['foto14_id'],
        'foto15_id': widget.pedidoDados['fotografias']['foto15_id'],
        'foto16_id': widget.pedidoDados['fotografias']['foto16_id'],
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          PhotoModel pm = PhotoModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
          pm.imageUrl = resData[i]['url'];
          _photosList.add(pm);
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
      _getPhotos(_authStore.token);
    }

    if (_photosList.isNotEmpty) {
      _novoPedStore.setPhotosList(_photosList);
    } else {
      _novoPedStore.setPhotosList(null);
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
                              content: Text('Enviando imagens...'),
                            ),
                          );

                          Future.delayed(const Duration(milliseconds: 500), () {
                            for (var photo in _photosDataList) {
                              _sendPhoto(_authStore.token, photo)
                                  .then((value) {});
                            }
                          });
                        }).catchError((e) {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 8),
                              content: Text('Selecione no máximo 16 imagens!'),
                            ),
                          );
                        });
                      },
                child: const Text(
                  'CARREGAR FOTOGRAFIAS',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            //Showing loaded images, if any.
            _photosList != null
                ? Column(
                    children: _uiManagePhotos(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
