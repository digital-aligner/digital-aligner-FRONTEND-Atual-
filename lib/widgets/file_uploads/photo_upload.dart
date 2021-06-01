import 'dart:async';
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

import './multipart_request.dart' as mt;

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

class _PhotoUploadState extends State<PhotoUpload> {
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
      Uri.parse(RotasUrl.rotaDeletePhoto + photoId.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    return _response;
  }

  Future<void> _sendPhoto(
    String _token,
    PlatformFile _currentPhoto,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    PhotoModel pm = PhotoModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );

    int posContainingWidget = 0;

    setState(() {
      _photosList.add(pm);
      for (int i = 0; i < _photosList.length; i++) {
        if (_photosList[i].listId == rNum) {
          posContainingWidget = i;
        }
      }
    });

    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = mt.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer $_token';

    request.files.add(http.MultipartFile(
      'files',
      _currentPhoto.readStream,
      _currentPhoto.size,
      filename: _currentPhoto.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(milliseconds: 100);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_photosList[posContainingWidget].progress < 1 || isUploading) {
          setState(() {
            double currentProgess = _photosList[posContainingWidget].progress;
            _photosList[posContainingWidget].progress = currentProgess + 0.01;
          });
        } else {
          t.cancel();
        }
      });

      var response = await request.send();

      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      if (resData[0]['id'] != null) {
        //STOP UI PROGRESS IF NOT FINISHED
        isUploading = false;

        setState(() {
          _photosList[posContainingWidget].id = resData[0]['id'];
          _photosList[posContainingWidget].fileName = resData[0]['name'];
          _photosList[posContainingWidget].thumbnail =
              resData[0]['formats']['thumbnail']['url'];
          _photosList[posContainingWidget].imageUrl = resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _photosList[posContainingWidget].id = -rNum;
        _photosList[posContainingWidget].fileName =
            'Erro de conexão. Por favor tente novamente.';
        _photosList[posContainingWidget].thumbnail = 'logos/error.jpg';
        _photosList[posContainingWidget].imageUrl = '';
      });
      //For send btn block
      _novoPedStore.setFstFotoError(true);
      print(e);
    }
  }

  Future<void> _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'jpe', 'gif', 'png'],
      allowMultiple: true,
      withReadStream: true,
    );
    if (result != null) {
      if (result.files.length + _photosList.length <= 16) {
        _photosDataList = result.files;
      } else {
        throw ('Selecione até 16 fotografias.');
      }
    } else {
      throw ('Nenhum arquivo escolhido.');
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
              const SizedBox(height: 10),
              if (curPhoto.thumbnail == null)
                Center(
                  child: CircularProgressIndicator(
                    value: curPhoto.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (curPhoto.id < 0)
                const Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: const AssetImage('logos/error.jpg'),
                )
              else
                Image.network(
                  curPhoto.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(width: 10),
              curPhoto.fileName == null
                  ? const Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curPhoto.fileName,
                      style: const TextStyle(
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
                            //If negative, error ocurred só delete only from list
                            if (curPhoto.id < 0) {
                              setState(() {
                                _photosList.removeWhere(
                                  (photo) => photo.id == curPhoto.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _s3deleteStore.setIdToDelete(curPhoto.id);
                              setState(() {
                                _photosList.removeWhere(
                                  (photo) => photo.id == curPhoto.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            }
                          } else {
                            if (curPhoto.id < 0) {
                              setState(() {
                                _photosList.removeWhere(
                                  (photo) => photo.id == curPhoto.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _deletePhoto(_token, curPhoto.id).then((res) {
                                var data = json.decode(res.body);
                                if (data['id'] != null) {
                                  setState(() {
                                    _photosList.removeWhere(
                                      (photo) => photo.id == data['id'],
                                    );
                                  });
                                  //Block send button in pedido_form
                                  _doesListHaveErrors();
                                }
                              });
                            }
                          }
                        },
                ),
              if (curPhoto.id == null) Container(),
              const SizedBox(
                height: 10,
                width: 20,
              ),
            ],
          ),
        ),
      );
    }

    return _ump;
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getPhotos(_token) async {
    var _response = await http.post(
      Uri.parse(RotasUrl.rotafotografiasList),
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
          //pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
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

  //CHECK FOR ERRORS IN LIST
  void _doesListHaveErrors() {
    if (_photosList.length > 0) {
      _photosList.forEach((photo) {
        if (photo.id != null) {
          if (photo.id < 0) {
            _novoPedStore.setFstFotoError(true);
            return;
          }
        }
      });
      _novoPedStore.setFstFotoError(false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //If sending, but not this (photo)
            if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstFoto())
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text(
                    'AGUARDE...',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            //If sending, and is this
            else if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() ==
                    _novoPedStore.getFstFoto())
              Container(
                width: 300,
                child: ElevatedButton(
                  onPressed: null,
                  child: const Text(
                    'ENVIANDO...',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
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
                            //Change btn states/block ui while sending
                            _novoPedStore.setFstSendState(
                              fstSendValue: _novoPedStore.getFstFoto(),
                            );
                            Future.delayed(const Duration(seconds: 1),
                                () async {
                              int count = 1;
                              for (var photo in _photosDataList) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(minutes: 3),
                                    content: Text(
                                        'Enviando imagem ${count.toString()} de ${_photosDataList.length.toString()}.'),
                                  ),
                                );

                                await _sendPhoto(_authStore.token, photo);

                                count++;
                              }
                              //Unblock when finished
                              _novoPedStore.setFstSendState(
                                fstSendValue:
                                    _novoPedStore.getFstNotSendingState(),
                              );
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();
                            });
                          }).catchError((e) {
                            //Unblock when finished
                            _novoPedStore.setFstSendState(
                              fstSendValue:
                                  _novoPedStore.getFstNotSendingState(),
                            );
                            ScaffoldMessenger.of(context)
                                .removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 8),
                                content: Text(e),
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
            const SizedBox(height: 20),
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
