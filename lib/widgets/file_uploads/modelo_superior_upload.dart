import 'dart:async';
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
import 'multipart_request.dart' as mt;
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class ModeloSuperiorUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;
  ModeloSuperiorUpload({
    this.isEdit,
    this.pedidoDados,
    @required this.blockUi,
  });
  @override
  _ModeloSuperiorUploadState createState() => _ModeloSuperiorUploadState();
}

class _ModeloSuperiorUploadState extends State<ModeloSuperiorUpload> {
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
      Uri.parse(RotasUrl.rotaDeleteModeloSup + modeloSupId.toString()),
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
      withReadStream: true,
    );
    if (result != null && result.files.length + _modeloSupsList.length <= 1) {
      _modeloSupsDataList = result.files;
    } else {
      throw ('Selecione apenas 1 modelo.');
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
              if (curmodeloSup.imageUrl == null)
                Center(
                  child: CircularProgressIndicator(
                    value: curmodeloSup.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (curmodeloSup.id < 0)
                const Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: const AssetImage('logos/error.jpg'),
                )
              else
                const Image(
                  fit: BoxFit.cover,
                  width: 100,
                  image: const AssetImage('logos/cubo.jpg'),
                ),
              const SizedBox(width: 10),
              curmodeloSup.fileName == null
                  ? const Text(
                      'Carregando...',
                      style: const TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curmodeloSup.fileName,
                      style: const TextStyle(
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
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            //If negitive, error ocurred só delete only from list
                            if (curmodeloSup.id < 0) {
                              setState(() {
                                _modeloSupsList.removeWhere(
                                  (photo) => photo.id == curmodeloSup.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _s3deleteStore.setIdToDelete(curmodeloSup.id);
                              setState(() {
                                _modeloSupsList.removeWhere(
                                  (modeloSup) =>
                                      modeloSup.id == curmodeloSup.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            }
                          } else {
                            //If negitive, error ocurred só delete only from list
                            if (curmodeloSup.id < 0) {
                              setState(() {
                                _modeloSupsList.removeWhere(
                                  (photo) => photo.id == curmodeloSup.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _deletemodeloSup(_token, curmodeloSup.id)
                                  .then((res) {
                                var data = json.decode(res.body);
                                if (data['id'] != null) {
                                  setState(() {
                                    _modeloSupsList.removeWhere(
                                      (modeloSup) => modeloSup.id == data['id'],
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
              if (curmodeloSup.id == null) Container(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }

    return _ump;
  }

  Future<void> _sendmodeloSup(
    String _token,
    PlatformFile _currentmodeloSup,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    ModeloSuperiorModel pm = ModeloSuperiorModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );

    int posContainingWidget = 0;

    setState(() {
      _modeloSupsList.add(pm);
      for (int i = 0; i < _modeloSupsList.length; i++) {
        if (_modeloSupsList[i].listId == rNum) {
          posContainingWidget = i;
        }
      }
    });

    final uri = Uri.parse(RotasUrl.rotaUploads3Custom);

    final request = mt.MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer $_token';

    request.files.add(http.MultipartFile(
      'files',
      _currentmodeloSup.readStream,
      _currentmodeloSup.size,
      filename: _currentmodeloSup.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(seconds: 2);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_modeloSupsList[posContainingWidget].progress < 1 || isUploading) {
          setState(() {
            double currentProgess =
                _modeloSupsList[posContainingWidget].progress;
            _modeloSupsList[posContainingWidget].progress =
                currentProgess + 0.01;
          });
        } else {
          t.cancel();
        }
      });

      var response = await request.send();
      var resStream = await response.stream.bytesToString();
      var resData = json.decode(resStream);

      //if server returned any errors
      if (resData[0].containsKey('error')) {
        throw resData[0]['error'];
      }

      //If there is connection error, acessing id (not exists) will throw error
      if (resData[0]['id'] != null) {
        //STOP UI PROGRESS IF NOT FINISHED
        isUploading = false;

        if (_modeloSupsList[posContainingWidget].progress < 0.5) {
          setState(() {
            _modeloSupsList[posContainingWidget].progress = 0.70;
          });
          await Future.delayed(Duration(seconds: 2));
          setState(() {
            _modeloSupsList[posContainingWidget].progress = 1;
          });
          await Future.delayed(Duration(seconds: 2));
        }

        setState(() {
          _modeloSupsList[posContainingWidget].id = resData[0]['id'];
          _modeloSupsList[posContainingWidget].fileName = resData[0]['name'];
          _modeloSupsList[posContainingWidget].imageUrl = resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _modeloSupsList[posContainingWidget].id = -1;
        _modeloSupsList[posContainingWidget].fileName =
            'Erro de conexão. Por favor tente novamente.';
        _modeloSupsList[posContainingWidget].imageUrl = '';
      });
      //For send btn block
      _novoPedStore.setFstMSupError(true);
      print(e);
    }
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getModeloSup(_token) async {
    print(widget.pedidoDados.toString());

    var _response = await http.post(
      Uri.parse(RotasUrl.rotaModeloSuperiorList),
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

  //CHECK FOR ERRORS IN LIST
  void _doesListHaveErrors() {
    if (_modeloSupsList.length > 0) {
      _modeloSupsList.forEach((photo) {
        if (photo.id != null) {
          if (photo.id < 0) {
            _novoPedStore.setFstMSupError(true);
            return;
          }
        }
      });
      _novoPedStore.setFstMSupError(false);
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
      _getModeloSup(_authStore.token);
    }

    if (_modeloSupsList.isNotEmpty) {
      _novoPedStore.setModeloSuperiorList(_modeloSupsList);
    } else {
      _novoPedStore.setModeloSuperiorList(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //If sending, but not this (modelo sup)
            if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstMSup())
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
            //If sending and is this
            else if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() ==
                    _novoPedStore.getFstMSup())
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
                              fstSendValue: _novoPedStore.getFstMSup(),
                            );
                            Future.delayed(const Duration(seconds: 1),
                                () async {
                              int count = 1;

                              for (var modeloSup in _modeloSupsDataList) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(minutes: 3),
                                    content: Text(
                                        'Enviando modelo superior ${count.toString()} de ${_modeloSupsDataList.length.toString()}.'),
                                  ),
                                );
                                await _sendmodeloSup(
                                  _authStore.token,
                                  modeloSup,
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
                    'MODELO SUPERIOR',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
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
