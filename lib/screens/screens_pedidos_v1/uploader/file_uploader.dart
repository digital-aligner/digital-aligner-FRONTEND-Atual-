import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:digital_aligner_app/providers/pedido_provider.dart';
import 'package:digital_aligner_app/providers/s3_delete_provider.dart';
import 'package:http/http.dart' as http;

import 'package:digital_aligner_app/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import '../../../rotas_url.dart';

//https://stackoverflow.com/questions/63314063/upload-image-file-to-strapi-flutter-web

class FileModel {
  int id;
  String imageUrl;
  String thumbnail;
  String fileName;
  double progress;
  bool hasError;

  FileModel({
    this.id = 0,
    this.imageUrl = '',
    this.thumbnail = '',
    this.fileName = '',
    this.progress = 0,
    this.hasError = false,
  });
}

class FileUploader extends StatefulWidget {
  final int filesQt;
  final List<String> acceptedFileExt;
  final String sendButtonText;
  FileUploader({
    @required this.filesQt,
    @required this.acceptedFileExt,
    @required this.sendButtonText,
  });

  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  AuthProvider _authStore;
  PedidoProvider _novoPedStore;

  List<PlatformFile> _filesData = <PlatformFile>[];
  List<FileModel> _serverFiles = [];

  //manage ui states
  bool isDeleting = false;
  bool isUploading = false;

  Future<void> _openFileExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.acceptedFileExt,
      allowMultiple: true,
      withReadStream: true,
    );
    if (result != null) {
      if (result.files.length + _serverFiles.length <= widget.filesQt) {
        _filesData = result.files;
      } else {
        throw ('Selecione até ${widget.filesQt.toString()} arquivos.');
      }
    } else {
      throw ('Nenhum arquivo escolhido.');
    }
  }

  MultipartRequest _buildRequest(PlatformFile currentFile) {
    final uri = Uri.parse(RotasUrl.rotaUpload);

    final request = MultipartRequest(
      'POST',
      uri,
    );

    request.headers['authorization'] = 'Bearer ${_authStore.token}';

    request.files.add(http.MultipartFile(
      'files',
      currentFile.readStream,
      currentFile.size,
      filename: currentFile.name,
    ));
    return request;
  }

  void _fakeTimer() {
    const oneSec = const Duration(milliseconds: 100);
    Timer.periodic(oneSec, (Timer t) {
      if (!_serverFiles.last.hasError && _serverFiles.last.progress < 1) {
        setState(() {
          double currentProgess = _serverFiles.last.progress;
          _serverFiles.last.progress = currentProgess + 0.01;
        });
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _sendFile(PlatformFile currentFile) async {
    //create file model and insert in list
    setState(() {
      _serverFiles.add(FileModel());
    });

    //build request
    MultipartRequest r = _buildRequest(currentFile);

    try {
      //TIMER (for fake ui progress)
      _fakeTimer();

      //send file
      var response = await r.send();
      var resStream = await response.stream.bytesToString();
      //decode data
      var resData = json.decode(resStream);

      //put timer progress at 1
      setState(() {
        _serverFiles.last.progress = 1;
      });

      if (resData[0].containsKey('id')) {
        setState(() {
          _serverFiles.last.id = resData[0]['id'];
          _serverFiles.last.fileName = resData[0]['name'] ?? '';
          _serverFiles.last.thumbnail =
              resData[0]['formats']['thumbnail']['url'] ?? '';
          _serverFiles.last.imageUrl = resData[0]['url'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _serverFiles.last.fileName =
            'Erro de conexão. Por favor tente novamente.';
        _serverFiles.last.thumbnail = 'logos/error.jpg';
        _serverFiles.last.imageUrl = '';
        _serverFiles.last.hasError = true;
      });
      print(e);
    }
  }

  Future<bool> _newFiledelete(int id) async {
    var _response = await http.delete(
      Uri.parse(RotasUrl.rotaDeletePhoto + id.toString()),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${_authStore.token}',
      },
    );
    var data = json.decode(_response.body);

    if (data.containsKey('id')) return true;

    return false;
  }

  Widget _fileUiImg(int pos) {
    return _serverFiles[pos].hasError
        ? const Image(
            fit: BoxFit.cover,
            width: 100,
            image: const AssetImage('logos/error.jpg'),
          )
        : Image.network(
            _serverFiles[pos].thumbnail,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
  }

  Widget _fileUi(int pos) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          children: <Widget>[
            _fileUiImg(pos),
            if (_serverFiles[pos].progress < 1)
              Center(
                child: CircularProgressIndicator(
                  value: _serverFiles[pos].progress,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            if (_serverFiles[pos].progress == 1 || _serverFiles[pos].hasError)
              IconButton(
                color: Colors.blueAccent,
                icon: const Icon(Icons.delete),
                onPressed: isUploading || isDeleting
                    ? null
                    : () async {
                        setState(() => isDeleting = true);
                        bool result =
                            await _newFiledelete(_serverFiles[pos].id);
                        if (result)
                          setState(() {
                            _serverFiles.remove(_serverFiles[pos]);
                            isDeleting = false;
                          });
                      },
              ),
          ],
        ),
      ),
    );
  }

  Widget _fileUiList() {
    List<Widget> l = [];
    for (int i = 0; i < _serverFiles.length; i++) {
      l.add(_fileUi(i));
    }
    return Wrap(children: l);
  }

  Widget _uploadBtn() {
    return ElevatedButton(
      onPressed: isUploading || isDeleting
          ? null
          : () async {
              await _openFileExplorer();
              setState(() {
                isUploading = true;
              });
              for (var file in _filesData) {
                await _sendFile(file);
              }
              setState(() {
                isUploading = false;
              });
            },
      child: Text(
        widget.sendButtonText,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _authStore = Provider.of<AuthProvider>(context);
    _novoPedStore = Provider.of<PedidoProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _uploadBtn(),
          _fileUiList(),
        ],
      ),
    );
  }
}
