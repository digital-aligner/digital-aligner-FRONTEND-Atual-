import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:digital_aligner_app/providers/relatorio_provider.dart';
import 'package:digital_aligner_app/providers/s3_relatorio_delete_provider.dart';

import 'package:http/http.dart' as http;
import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../rotas_url.dart';
import './multipart_request.dart' as mt;

import 'relatorio_ppt_model.dart';
//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class RelatorioPPTUpload extends StatefulWidget {
  final bool isEdit;
  final Map relatorioDados;

  RelatorioPPTUpload({
    this.isEdit,
    this.relatorioDados,
  });

  @override
  _RelatorioPPTUploadState createState() => _RelatorioPPTUploadState();
}

class _RelatorioPPTUploadState extends State<RelatorioPPTUpload>
    with AutomaticKeepAliveClientMixin<RelatorioPPTUpload> {
  @override
  bool get wantKeepAlive => true;
  RelatorioProvider _relatorioStore;

  bool _isFetchEdit = true;

  S3RelatorioDeleteProvider _s3RelatorioDeleteStore;

  //Clear after sending to server
  List<PlatformFile> _relatorioPPTUploadsDataList = <PlatformFile>[];

  //New relatorioPPTUpload object with id and image url from server
  List<RelatorioPPTModel> _relatorioPPTUploadsList = <RelatorioPPTModel>[];

  Future<dynamic> _deleterelatorioPPTUpload(
      _token, relatorioPPTUploadId) async {
    var _response = await http.delete(
      Uri.parse(
          RotasUrl.rotaDeleteRelatorioUpload + relatorioPPTUploadId.toString()),
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
      allowedExtensions: ['ppt', 'pptx'],
      allowMultiple: false,
      withReadStream: true,
    );
    if (result != null &&
        result.files.length + _relatorioPPTUploadsList.length <= 1) {
      _relatorioPPTUploadsDataList = result.files;
    } else {
      throw ('Excedeu número máximo de relatórios em PPT!');
    }
  }

  List<Widget> _uiManagerelatorioPPTUploads(_token) {
    List<Widget> _ump = <Widget>[];
    for (var currelatorioPPTUpload in _relatorioPPTUploadsList) {
      _ump.add(
        Material(
          elevation: 5,
          child: Row(
            children: [
              currelatorioPPTUpload.imageUrl == null
                  ? Center(
                      child: CircularProgressIndicator(
                        value: currelatorioPPTUpload.progress,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : Image(
                      fit: BoxFit.cover,
                      width: 100,
                      image: AssetImage('logos/ppt.png'),
                    ),
              SizedBox(width: 10),
              currelatorioPPTUpload.fileName == null
                  ? Text(
                      'Carregando...',
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    )
                  : Text(
                      currelatorioPPTUpload.fileName,
                      style: TextStyle(
                        color: Colors.black38,
                      ),
                    ),
              Expanded(
                child: Container(),
              ),
              currelatorioPPTUpload.id != null
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (widget.isEdit) {
                          _s3RelatorioDeleteStore.setIdToDelete(
                            currelatorioPPTUpload.id,
                          );
                          setState(() {
                            _relatorioPPTUploadsList.removeWhere(
                              (relatorioPPTUpload) =>
                                  relatorioPPTUpload.id ==
                                  currelatorioPPTUpload.id,
                            );
                          });
                        } else {
                          _deleterelatorioPPTUpload(
                                  _token, currelatorioPPTUpload.id)
                              .then((res) {
                            var data = json.decode(res.body);
                            if (data['id'] != null) {
                              setState(() {
                                _relatorioPPTUploadsList.removeWhere(
                                  (relatorioPPTUpload) =>
                                      relatorioPPTUpload.id == data['id'],
                                );
                              });
                            }
                          });
                        }
                      },
                    )
                  : Container(),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      );
    }
    //Clear memory of unused byte array
    _relatorioPPTUploadsDataList = null;
    return _ump;
  }

  Future<void> _sendrelatorioPPTUpload(
    String _token,
    PlatformFile _currentrelatorioPPTUpload,
  ) async {
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    RelatorioPPTModel pm = RelatorioPPTModel(
      listId: rNum,
      progress: 0,
      fileName: 'Enviando...',
    );

    int posContainingWidget = 0;

    setState(() {
      _relatorioPPTUploadsList.add(pm);
      for (int i = 0; i < _relatorioPPTUploadsList.length; i++) {
        if (_relatorioPPTUploadsList[i].listId == rNum) {
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
      _currentrelatorioPPTUpload.readStream,
      _currentrelatorioPPTUpload.size,
      filename: _currentrelatorioPPTUpload.name,
    ));

    try {
      //TIMER (for fake ui progress)
      const oneSec = const Duration(milliseconds: 100);
      bool isUploading = true;

      Timer.periodic(oneSec, (Timer t) {
        if (_relatorioPPTUploadsList[posContainingWidget].progress < 1 ||
            isUploading) {
          setState(() {
            double currentProgess =
                _relatorioPPTUploadsList[posContainingWidget].progress;
            _relatorioPPTUploadsList[posContainingWidget].progress =
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

        _relatorioStore.updateRelatorioPPTs3Urls(resData[0]);

        setState(() {
          _relatorioPPTUploadsList[posContainingWidget].id = resData[0]['id'];
          _relatorioPPTUploadsList[posContainingWidget].fileName =
              resData[0]['name'];
          _relatorioPPTUploadsList[posContainingWidget].imageUrl =
              resData[0]['url'];
        });
      }
    } catch (e) {
      setState(() {
        _relatorioPPTUploadsList[posContainingWidget].id = -1;
        _relatorioPPTUploadsList[posContainingWidget].fileName =
            'Algo deu errado, por favor tente novamente.';
        _relatorioPPTUploadsList[posContainingWidget].imageUrl = '';
      });
    }
  }

  //FOR EDIT SCREEN
  Future<dynamic> _getPpts(_token) async {
    var _response = await http.post(
      Uri.parse(RotasUrl.rotaPptsList),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'relatorio1_id':
            widget.relatorioDados['relatorio_ppt']['relatorio1_id'].toString(),
      }),
    );
    var resData = json.decode(_response.body);

    try {
      for (int i = 0; i < resData.length; i++) {
        if (resData[i]['id'] != null) {
          RelatorioPPTModel pm = RelatorioPPTModel(listId: resData[i]['id']);
          pm.id = resData[i]['id'];
          pm.fileName = resData[i]['name'];
          //pm.thumbnail = resData[i]['formats']['thumbnail']['url'];
          pm.imageUrl = resData[i]['url'];
          _relatorioPPTUploadsList.add(pm);
        }
      }

      _isFetchEdit = false;
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
    _relatorioStore = Provider.of<RelatorioProvider>(context, listen: false);

    _s3RelatorioDeleteStore = Provider.of<S3RelatorioDeleteProvider>(
      context,
      listen: false,
    );

    if (widget.isEdit && _isFetchEdit) {
      _getPpts(_authStore.token);
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
                        content: const Text('Enviando relatório PDF'),
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 500), () {
                      for (var relatorioPPTUpload
                          in _relatorioPPTUploadsDataList) {
                        _sendrelatorioPPTUpload(
                            _authStore.token, relatorioPPTUpload);
                      }
                    });
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: const Text('Selecione no máximo 1 arquivo!'),
                      ),
                    );
                  });
                },
                child: const Text(
                  'RELATÓRIO PPT',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            //Showing loaded images, if any.
            _relatorioPPTUploadsList != null
                ? Column(
                    children: _uiManagerelatorioPPTUploads(_authStore.token),
                  )
                : Container(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
