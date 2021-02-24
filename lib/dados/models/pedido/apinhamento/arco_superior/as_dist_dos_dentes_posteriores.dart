import 'package:digital_aligner_app/dados/models/pedido/apinhamento/arco_superior/as_dist_desgastes_interproximais.dart';

import 'as_dist_lado_direito.dart';
import 'as_dist_lado_esquerdo.dart';

class AsDistDosDentesPosteriores {
  int id;
  AsDistLadoEsquerdo asDistLadoEsquerdo;
  AsDistLadoDireito asDistLadoDireito;
  AsDistDesgastesInterproximais asDistDesgastesInterproximais;

  AsDistDosDentesPosteriores({
    this.id,
    this.asDistLadoEsquerdo,
    this.asDistLadoDireito,
    this.asDistDesgastesInterproximais,
  });

  factory AsDistDosDentesPosteriores.fromJson(Map<String, dynamic> data) {
    return AsDistDosDentesPosteriores(
      id: data['id'],
      asDistLadoEsquerdo: AsDistLadoEsquerdo.fromJson(
        data['as_dist_lado_esquerdo'],
      ),
      asDistLadoDireito: AsDistLadoDireito.fromJson(
        data['as_dist_lado_direito'],
      ),
      asDistDesgastesInterproximais: AsDistDesgastesInterproximais.fromJson(
        data['as_dist_desgastes_interproximais'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'as_dist_lado_esquerdo': asDistLadoEsquerdo.toJson(),
      'as_dist_lado_direito': asDistLadoDireito.toJson(),
      'as_dist_desgastes_interproximais':
          asDistDesgastesInterproximais.toJson(),
    };
  }
}
