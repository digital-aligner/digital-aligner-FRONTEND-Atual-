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
import './multipart_request.dart' as mt;
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

class _CompactadoUploadState extends State<CompactadoUpload> {
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
      withReadStream: true,
    );
    if (result != null &&
        result.files.length + _compactUploadsList.length <= 1) {
      _compactUploadsDataList = result.files;
    } else {
      throw ('Selecione apenas 1 compactado');
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
              if (curcompactUpload.imageUrl == null)
                Center(
                  child: CircularProgressIndicator(
                    value: curcompactUpload.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (curcompactUpload.id < 0)
                const Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: const AssetImage('logos/error.jpg'),
                )
              else
                const Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: const AssetImage('logos/comp.jpg'),
                ),
              const SizedBox(width: 10),
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
                            //If negitive, error ocurred só delete only from list
                            if (curcompactUpload.id < 0) {
                              setState(() {
                                _compactUploadsList.removeWhere(
                                  (photo) => photo.id == curcompactUpload.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _s3deleteStore.setIdToDelete(curcompactUpload.id);
                              setState(() {
                                _compactUploadsList.removeWhere(
                                  (compactUpload) =>
                                      compactUpload.id == curcompactUpload.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            }
                          } else {
                            //If negitive, error ocurred só delete only from list
                            if (curcompactUpload.id < 0) {
                              setState(() {
                                _compactUploadsList.removeWhere(
                                  (photo) => photo.id == curcompactUpload.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
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
                                  //Block send button in pedido_form
                                  _doesListHaveErrors();
                                }
                              });
                            }
                          }
                        },
                ),
              if (curcompactUpload.id == null) Container(),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }

    return _ump;
  }

  Future<void> _sendcompactUpload(
    String _token,
    PlatformFile _currentcompactUpload,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    CompactadoModel pm = CompactadoModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );

    int posContainingWidget = 0;

    setState(() {
      _compactUploadsList.add(pm);
      for (int i = 0; i < _compactUploadsList.length; i++) {
        if (_compactUploadsList[i].listId == rNum) {
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
      _currentcompactUpload.readStream,
      _currentcompactUpload.size,
      filename: _currentcompactUpload.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(seconds: 2);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_compactUploadsList[posContainingWidget].progress < 1 ||
            isUploading) {
          setState(() {
            double currentProgess =
                _compactUploadsList[posContainingWidget].progress;
            _compactUploadsList[posContainingWidget].progress =
                currentProgess + 0.01;
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

        if (_compactUploadsList[posContainingWidget].progress < 0.5) {
          setState(() {
            _compactUploadsList[posContainingWidget].progress = 0.70;
          });
          await Future.delayed(Duration(seconds: 2));
          setState(() {
            _compactUploadsList[posContainingWidget].progress = 1;
          });
          await Future.delayed(Duration(seconds: 2));
        }
        /*
        for (int i = 0; i < _compactUploadsList.length; i++) {
          if (_compactUploadsList[i].listId == rNum) {
            setState(() {
              _compactUploadsList[i].id = resData[0]['id'];
              _compactUploadsList[i].fileName = resData[0]['name'];
              _compactUploadsList[i].imageUrl = resData[0]['url'];
            });
          }
        }*/

        setState(() {
          _compactUploadsList[posContainingWidget].id = resData[0]['id'];
          _compactUploadsList[posContainingWidget].fileName =
              resData[0]['name'];
          _compactUploadsList[posContainingWidget].imageUrl = resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _compactUploadsList[posContainingWidget].id = -1;
        _compactUploadsList[posContainingWidget].fileName =
            'Erro de conexão. Por favor tente novamente.';
        _compactUploadsList[posContainingWidget].imageUrl = '';
      });
      //For send btn block
      _novoPedStore.setFstCompError(true);
    }
  }

//FOR EDIT SCREEN
  Future<dynamic> _getModeloComp(_token) async {
    CompactadoModel pm = CompactadoModel(
      listId: -1,
      progress: 1,
      fileName: 'carregando...',
    );

    setState(() {
      _compactUploadsList = [];
      _compactUploadsList.add(pm);
    });

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
      /*
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          CompactadoModel pm = CompactadoModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.imageUrl = resData[i]['url'];
          _compactUploadsList.add(pm);
        }
      }*/

      if (resData[0]['id'] != null) {
        _compactUploadsList = [];
        CompactadoModel pm = CompactadoModel(listId: resData[0]['id']);
        pm.id = resData[0]['id'];
        pm.fileName = resData[0]['name'];
        pm.imageUrl = resData[0]['url'];
        _compactUploadsList.add(pm);
      } else {
        _compactUploadsList = [];
      }
      setState(() {
        _isFetchEdit = false;
      });
    } catch (error) {
      setState(() {
        _compactUploadsList = [];
        _isFetchEdit = false;
      });

      print(error);
    }

    return resData;
  }

  //CHECK FOR ERRORS IN LIST
  void _doesListHaveErrors() {
    if (_compactUploadsList.length > 0) {
      _compactUploadsList.forEach((photo) {
        if (photo.id != null) {
          if (photo.id < 0) {
            _novoPedStore.setFstCompError(true);
            return;
          }
        }
      });
      _novoPedStore.setFstCompError(false);
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
      _getModeloComp(_authStore.token);
    }

    if (_compactUploadsList.isNotEmpty) {
      _novoPedStore.setModeloCompactadoList(_compactUploadsList);
    } else {
      _novoPedStore.setModeloCompactadoList(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //If sending, but not this (modelo compactado)
            if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstComp())
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
            //If sending and this
            else if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() ==
                    _novoPedStore.getFstComp())
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
                              fstSendValue: _novoPedStore.getFstComp(),
                            );
                            Future.delayed(const Duration(seconds: 1),
                                () async {
                              int count = 1;

                              for (var compactUpload
                                  in _compactUploadsDataList) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(minutes: 3),
                                    content: Text(
                                        'Enviando compactado ${count.toString()} de ${_compactUploadsDataList.length.toString()}.'),
                                  ),
                                );
                                await _sendcompactUpload(
                                  _authStore.token,
                                  compactUpload,
                                );
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
                    'MODELOS COMPACTADO',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
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
