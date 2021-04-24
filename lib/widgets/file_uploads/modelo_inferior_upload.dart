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

import 'modelo_inferior.dart';
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class ModeloInferiorUpload extends StatefulWidget {
  final bool isEdit;
  final Map pedidoDados;
  final bool blockUi;
  ModeloInferiorUpload({
    this.isEdit,
    this.pedidoDados,
    @required this.blockUi,
  });
  @override
  _ModeloInferiorUploadState createState() => _ModeloInferiorUploadState();
}

class _ModeloInferiorUploadState extends State<ModeloInferiorUpload> {
  bool _isFetchEdit = true;

  AuthProvider _authStore;
  PedidoProvider _novoPedStore;
  S3DeleteProvider _s3deleteStore;

  //Clear after sending to server
  List<PlatformFile> _modeloInfsDataList = <PlatformFile>[];

  //New modeloInf object with id and image url from server
  List<ModeloInferiorModel> _modeloInfsList = <ModeloInferiorModel>[];

  Future<dynamic> _deletemodeloInf(_token, modeloInfId) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeleteModeloInf + modeloInfId.toString()),
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
    if (result != null && result.files.length + _modeloInfsList.length <= 1) {
      _modeloInfsDataList = result.files;
    } else {
      throw ('Selecione apenas 1 modelo.');
    }
  }

  List<Widget> _uiManagemodeloInfs(_token) {
    List<Widget> _ump = <Widget>[];
    for (var curmodeloInf in _modeloInfsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              if (curmodeloInf.imageUrl == null)
                Center(
                  child: CircularProgressIndicator(
                    value: curmodeloInf.progress,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                )
              else if (curmodeloInf.id < 0)
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
              curmodeloInf.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      curmodeloInf.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              if (curmodeloInf.id != null)
                IconButton(
                  icon: widget.isEdit == false
                      ? const Icon(Icons.delete)
                      : const Icon(Icons.delete_forever),
                  onPressed: widget.blockUi
                      ? null
                      : () {
                          if (widget.isEdit) {
                            //If negitive, error ocurred só delete only from list
                            if (curmodeloInf.id < 0) {
                              setState(() {
                                _modeloInfsList.removeWhere(
                                  (photo) => photo.id == curmodeloInf.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _s3deleteStore.setIdToDelete(curmodeloInf.id);
                              setState(() {
                                _modeloInfsList.removeWhere(
                                  (modeloInf) =>
                                      modeloInf.id == curmodeloInf.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            }
                          } else {
                            //If negitive, error ocurred só delete only from list
                            if (curmodeloInf.id < 0) {
                              setState(() {
                                _modeloInfsList.removeWhere(
                                  (photo) => photo.id == curmodeloInf.id,
                                );
                              });
                              //Block send button in pedido_form
                              _doesListHaveErrors();
                            } else {
                              _deletemodeloInf(_token, curmodeloInf.id)
                                  .then((res) {
                                var data = json.decode(res.body);
                                if (data['id'] != null) {
                                  setState(() {
                                    _modeloInfsList.removeWhere(
                                      (modeloInf) => modeloInf.id == data['id'],
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
              if (curmodeloInf.id == null) Container(),
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

  Future<void> _sendmodeloInf(
    String _token,
    PlatformFile _currentmodeloInf,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    ModeloInferiorModel pm = ModeloInferiorModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );

    int posContainingWidget = 0;

    setState(() {
      _modeloInfsList.add(pm);
      for (int i = 0; i < _modeloInfsList.length; i++) {
        if (_modeloInfsList[i].listId == rNum) {
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
      _currentmodeloInf.readStream,
      _currentmodeloInf.size,
      filename: _currentmodeloInf.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(seconds: 2);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_modeloInfsList[posContainingWidget].progress < 1 || isUploading) {
          setState(() {
            double currentProgess =
                _modeloInfsList[posContainingWidget].progress;
            _modeloInfsList[posContainingWidget].progress =
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

        if (_modeloInfsList[posContainingWidget].progress < 0.5) {
          setState(() {
            _modeloInfsList[posContainingWidget].progress = 0.70;
          });
          await Future.delayed(Duration(seconds: 2));
          setState(() {
            _modeloInfsList[posContainingWidget].progress = 1;
          });
          await Future.delayed(Duration(seconds: 2));
        }

        setState(() {
          _modeloInfsList[posContainingWidget].id = resData[0]['id'];
          _modeloInfsList[posContainingWidget].fileName = resData[0]['name'];
          _modeloInfsList[posContainingWidget].imageUrl = resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _modeloInfsList[posContainingWidget].id = -1;
        _modeloInfsList[posContainingWidget].fileName =
            'Erro de conexão. Por favor tente novamente.';
        _modeloInfsList[posContainingWidget].imageUrl = '';
      });
      //For send btn block
      _novoPedStore.setFstMInfError(true);
    }
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getModeloInf(_token) async {
    var _response = await http.post(
      Uri.parse(RotasUrl.rotaModeloInferiorList),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'modelo_inferior': widget.pedidoDados['modelo_inferior']
            ['modelo_inferior_id'],
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          ModeloInferiorModel pm =
              ModeloInferiorModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          pm.imageUrl = resData[i]['url'];
          _modeloInfsList.add(pm);
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
    if (_modeloInfsList.length > 0) {
      _modeloInfsList.forEach((photo) {
        if (photo.id != null) {
          if (photo.id < 0) {
            _novoPedStore.setFstMInfError(true);
            return;
          }
        }
      });
      _novoPedStore.setFstMInfError(false);
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
      _getModeloInf(_authStore.token);
    }

    if (_modeloInfsList.isNotEmpty) {
      _novoPedStore.setModeloInferiorList(_modeloInfsList);
    } else {
      _novoPedStore.setModeloInferiorList(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //If sending, but not this (modelo inferior)
            if (_novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstNotSendingState() &&
                _novoPedStore.getFstSendingState() !=
                    _novoPedStore.getFstMInf())
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
                    _novoPedStore.getFstMInf())
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
                              fstSendValue: _novoPedStore.getFstMInf(),
                            );
                            Future.delayed(const Duration(seconds: 1),
                                () async {
                              int count = 1;

                              for (var modeloInf in _modeloInfsDataList) {
                                ScaffoldMessenger.of(context)
                                    .removeCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(minutes: 3),
                                    content: Text(
                                        'Enviando modelo inferior ${count.toString()} de ${_modeloInfsDataList.length.toString()}.'),
                                  ),
                                );
                                await _sendmodeloInf(
                                  _authStore.token,
                                  modeloInf,
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
                    'MODELO INFERIOR',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
            //Showing loaded images, if any.
            _modeloInfsList != null
                ? Column(
                    children: _uiManagemodeloInfs(_authStore.token),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
