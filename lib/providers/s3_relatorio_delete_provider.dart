import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../rotas_url.dart';

//Since each widget (fotografias upload, radio. upload, etc.) have
//there own state, using provider to batch the requests and send them
//when the pedido is updated.

class S3RelatorioDeleteProvider with ChangeNotifier {
  String _token;
  List<int> _idsToDelete = [];

  void clearData() {
    _token = null;
    _idsToDelete = [];
  }

  void setToken(String t) {
    _token = t;
  }

  void setIdToDelete(int id) {
    _idsToDelete.add(id);
  }

  Future<void> deleteFileRequest(int fileId) async {
    await http.delete(
      RotasUrl.rotaDeleteS3 + fileId.toString(),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
  }

  Future<void> batchDeleteFiles() async {
    for (var id in _idsToDelete) {
      deleteFileRequest(id);
    }
  }
}
