import 'ai_expansao_transversal.dart';

import 'ai_dist_dos_dentes_posteriores.dart';
import 'ai_inclin_proj_vest_dos_incisivo.dart';

class ArcoInferior {
  int id;
  AiExpansaoTransversal aiExpansaoTransversal;
  AiInclinProjVestDosIncisivo aiInclinProjVestDosIncisivo;
  AiDistDosDentesPosteriores aiDistDosDentesPosteriores;

  ArcoInferior({
    this.id,
    this.aiExpansaoTransversal,
    this.aiInclinProjVestDosIncisivo,
    this.aiDistDosDentesPosteriores,
  });

  factory ArcoInferior.fromJson(Map<String, dynamic> data) {
    return ArcoInferior(
      id: data['id'],
      aiExpansaoTransversal: AiExpansaoTransversal.fromJson(
        data['ai_expansao_transversal'],
      ),
      aiInclinProjVestDosIncisivo: AiInclinProjVestDosIncisivo.fromJson(
        data['ai_inclin_proj_vest_dos_incisivo'],
      ),
      aiDistDosDentesPosteriores: AiDistDosDentesPosteriores.fromJson(
        data['ai_dist_dos_dentes_posteriores'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ai_expansao_transversal': aiExpansaoTransversal.toJson(),
      'ai_inclin_proj_vest_dos_incisivo': aiInclinProjVestDosIncisivo.toJson(),
      'ai_dist_dos_dentes_posteriores': aiDistDosDentesPosteriores.toJson(),
    };
  }
}
