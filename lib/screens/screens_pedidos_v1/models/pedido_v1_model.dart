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
    //fotografias list to objects list
    if (data['fotografias'] != null) {
      List<dynamic> f = [];
      data['fotografias'].forEach((fotografia) {
        f.add(
          FileModel(
            id: fotografia['id'] ?? 0,
            name: fotografia['name'] ?? '',
            url: fotografia['url'] ?? '',
          ),
        );
      });
    }

    return PedidoV1Model(
      id: data['id'] ?? 0,
      tratar: data['tratar'] ?? '',
      fotografias: data['fotografias'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tratar': tratar,
    };
  }
}
