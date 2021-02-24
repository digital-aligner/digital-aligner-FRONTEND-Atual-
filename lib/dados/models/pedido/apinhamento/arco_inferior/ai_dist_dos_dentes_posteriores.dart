import 'ai_dist_desgastes_interproximais.dart';
import 'ai_dist_lado_direito.dart';
import 'ai_dist_lado_esquerdo.dart';

class AiDistDosDentesPosteriores {
  int id;
  AiDistLadoEsquerdo aiDistLadoEsquerdo;
  AiDistLadoDireito aiDistLadoDireito;
  AiDistDesgastesInterproximais aiDistDesgastesInterproximais;

  AiDistDosDentesPosteriores({
    this.id,
    this.aiDistLadoEsquerdo,
    this.aiDistLadoDireito,
    this.aiDistDesgastesInterproximais,
  });

  factory AiDistDosDentesPosteriores.fromJson(Map<String, dynamic> data) {
    return AiDistDosDentesPosteriores(
      id: data['id'],
      aiDistLadoEsquerdo: AiDistLadoEsquerdo.fromJson(
        data['ai_dist_lado_esquerdo'],
      ),
      aiDistLadoDireito: AiDistLadoDireito.fromJson(
        data['ai_dist_lado_direito'],
      ),
      aiDistDesgastesInterproximais: AiDistDesgastesInterproximais.fromJson(
        data['ai_dist_desgastes_interproximais'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ai_dist_lado_esquerdo': aiDistLadoEsquerdo.toJson(),
      'ai_dist_lado_direito': aiDistLadoDireito.toJson(),
      'ai_dist_desgastes_interproximais':
          aiDistDesgastesInterproximais.toJson(),
    };
  }
}
