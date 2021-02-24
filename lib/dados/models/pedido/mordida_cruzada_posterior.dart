import 'package:digital_aligner_app/dados/models/pedido/status_correcao.dart';

import './contracao_arco_inferior.dart';
import './expansao_arco_superior.dart';

import './opcionais_mordida_cruz_post.dart';

class MordidaCruzadaPosterior {
  int id;
  StatusCorrecao statusCorrecao;
  ExpansaoArcoSuperior expansaoArcoSuperior;
  ContracaoArcoInferior contracaoArcoInferior;
  OpcionaisMordidaCruzPost opcionaisMordidaCruzPost;

  MordidaCruzadaPosterior({
    this.id,
    this.statusCorrecao,
    this.expansaoArcoSuperior,
    this.contracaoArcoInferior,
    this.opcionaisMordidaCruzPost,
  });

  factory MordidaCruzadaPosterior.fromJson(Map<String, dynamic> data) {
    return MordidaCruzadaPosterior(
      id: data['id'],
      statusCorrecao: StatusCorrecao.fromJson(data['status_correcao']),
      expansaoArcoSuperior: ExpansaoArcoSuperior.fromJson(
        data['expansao_arco_superior'],
      ),
      contracaoArcoInferior: ContracaoArcoInferior.fromJson(
        data['contracao_arco_inferior;'],
      ),
      opcionaisMordidaCruzPost: OpcionaisMordidaCruzPost.fromJson(
        data['opcionais_mordida_cruz_post'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status_correcao': statusCorrecao.toJson(),
      'expansao_arco_superior': expansaoArcoSuperior.toJson(),
      'contracao_arco_inferior': contracaoArcoInferior.toJson(),
      'opcionais_mordida_cruz_post': opcionaisMordidaCruzPost.toJson(),
    };
  }
}
