import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/paciente_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/status_pedidov1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/models/usuario_v1_model.dart';
import 'package:digital_aligner_app/screens/screens_pedidos_v1/uploader/model/FileModel.dart';
import 'package:digital_aligner_app/widgets/endereco_v1/endereco_model_.dart';

class PedidoV1Model {
  int id;
  String tratar;
  String queixaPrincipal;
  String objetivosTratamento;
  String linhaMediaSuperior;
  String linhaMediaInferior;
  List<FileModel> fotografias;
  List<FileModel> radiografias;
  List<FileModel> modeloSuperior;
  List<FileModel> modeloInferior;
  List<FileModel> modeloCompactado;
  PacienteV1Model? paciente;
  UsuarioV1Model? usuario;
  EnderecoModel? enderecoEntrega;
  StatusPedidoV1Model? statusPedido;

  PedidoV1Model({
    this.id = 0,
    this.tratar = '',
    this.queixaPrincipal = '',
    this.objetivosTratamento = '',
    this.linhaMediaSuperior = '',
    this.linhaMediaInferior = '',
    this.fotografias = const <FileModel>[],
    this.radiografias = const <FileModel>[],
    this.modeloSuperior = const <FileModel>[],
    this.modeloInferior = const <FileModel>[],
    this.modeloCompactado = const <FileModel>[],
    this.paciente,
    this.usuario,
    this.enderecoEntrega,
    this.statusPedido,
  });

  factory PedidoV1Model.fromJson(Map<String, dynamic> data) {
    List<FileModel> f = [];
    List<FileModel> r = [];
    List<FileModel> ms = [];
    List<FileModel> mi = [];
    List<FileModel> mc = [];
    //fotografias list to objects list
    if (data['fotografias'] != null) {
      data['fotografias'].forEach((fotografia) {
        f.add(FileModel.fromJson(fotografia));
      });
    }
    //radiografias list to objects list
    if (data['radiografias'] != null) {
      data['radiografias'].forEach((radiografia) {
        f.add(FileModel.fromJson(radiografia));
      });
    } //modelo superior list to objects list
    if (data['modelo_superior'] != null) {
      data['modelo_superior'].forEach((modeloSup) {
        f.add(FileModel.fromJson(modeloSup));
      });
    } //modelo inferior list to objects list
    if (data['modelo_inferior'] != null) {
      data['modelo_inferior'].forEach((modeloInf) {
        f.add(FileModel.fromJson(modeloInf));
      });
    }
    //modelo compactado list to objects list
    if (data['modelo_compactado'] != null) {
      data['modelo_compactado'].forEach((modeloComp) {
        f.add(FileModel.fromJson(modeloComp));
      });
    }

    return PedidoV1Model(
      id: data['id'] ?? 0,
      tratar: data['tratar'] ?? '',
      queixaPrincipal: data['queixa_principal'],
      objetivosTratamento: data['objetivos_tratamento'],
      linhaMediaSuperior: data['linha_media_superior'],
      linhaMediaInferior: data['linha_media_inferior'],
      fotografias: f,
      radiografias: r,
      modeloSuperior: ms,
      modeloInferior: mi,
      modeloCompactado: mc,
      paciente: PacienteV1Model.fromJson(data['paciente']),
      usuario: UsuarioV1Model.fromJson(data['usuario']),
      enderecoEntrega: EnderecoModel.fromJson(data['endereco_entrega']),
      statusPedido: StatusPedidoV1Model.fromJson(data['status_pedido']),
    );
  }

  Map<String, dynamic> toJson() {
    List<dynamic> f = [];
    List<dynamic> r = [];
    List<dynamic> ms = [];
    List<dynamic> mi = [];
    List<dynamic> mc = [];

    fotografias.forEach((fotografia) {
      f.add(fotografia.toJson());
    });
    radiografias.forEach((radiografia) {
      r.add(radiografia.toJson());
    });
    modeloSuperior.forEach((modeloSup) {
      ms.add(modeloSup.toJson());
    });
    modeloInferior.forEach((modeloInf) {
      mi.add(modeloInf.toJson());
    });
    modeloCompactado.forEach((modeloComp) {
      mc.add(modeloComp.toJson());
    });

    return {
      'id': id,
      'tratar': tratar,
      'queixa_principal': queixaPrincipal,
      'objetivos_tratamento': objetivosTratamento,
      'linha_media_superior': linhaMediaSuperior,
      'linha_media_inferior': linhaMediaInferior,
      'fotografias': f,
      'radiografias': r,
      'modelo_superior': ms,
      'modelo_inferior': mi,
      'modelo_compactado': mc,
      'paciente': paciente?.toJson() ?? '',
      'usuario': usuario?.toJson() ?? '',
      'endereco_entrega': enderecoEntrega?.toJson() ?? '',
      'status_pedido': statusPedido?.toJson() ?? ''
    };
  }
}
