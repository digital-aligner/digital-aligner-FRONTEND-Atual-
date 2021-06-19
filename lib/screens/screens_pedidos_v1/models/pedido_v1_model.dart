import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/paciente_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';

class PedidoV1Model {
  int id;
  String tratar;
  List<FileModel> fotografias;
  PacienteV1Model? paciente;
  UsuarioV1Model? usuario;
  EnderecoModel? enderecoEntrega;

  PedidoV1Model({
    this.id = 0,
    this.tratar = '',
    this.fotografias = const <FileModel>[],
    this.paciente,
    this.usuario,
    this.enderecoEntrega,
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
      paciente: PacienteV1Model.fromJson(data['paciente']),
      usuario: UsuarioV1Model.fromJson(data['usuario']),
      enderecoEntrega: EnderecoModel.fromJson(data['endereco_entrega']),
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> f = [];

    fotografias.forEach((fotografia) {
      f.add(fotografia.toJson());
    });

    return {
      'id': id,
      'tratar': tratar,
      'fotografias': f,
      'paciente': paciente?.toJson() ?? '',
      'usuario': usuario?.toJson() ?? '',
      'endereco_entrega': enderecoEntrega?.toJson() ?? ''
    };
  }
}
