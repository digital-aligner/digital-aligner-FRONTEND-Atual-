import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';

class PedidoV1Model {
  int id;
  String tratar;
  List<FileModel> fotografias;

  PedidoV1Model({
    this.id = 0,
    this.tratar = '',
    this.fotografias = const <FileModel>[],
  });

  factory PedidoV1Model.fromJson(Map<String, dynamic> data) {
    List<FileModel> f = [];
    //fotografias list to objects list
    if (data['fotografias'] != null) {
      data['fotografias'].forEach((fotografia) {
        f.add(FileModel.fromJson(fotografia));
      });
    }

    return PedidoV1Model(
      id: data['id'] ?? 0,
      tratar: data['tratar'] ?? '',
      fotografias: f,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tratar': tratar,
    };
  }
}
