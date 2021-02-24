import './as_expansao_transversal.dart';

import './as_dist_dos_dentes_posteriores.dart';
import './as_inclin_proj_vest_dos_incisivo.dart';

class ArcoSuperior {
  int id;
  AsExpansaoTransversal asExpansaoTransversal;
  AsInclinProjVestDosIncisivo asInclinProjVestDosIncisivo;
  AsDistDosDentesPosteriores asDistDosDentesPosteriores;

  ArcoSuperior({
    this.id,
    this.asExpansaoTransversal,
    this.asInclinProjVestDosIncisivo,
    this.asDistDosDentesPosteriores,
  });

  factory ArcoSuperior.fromJson(Map<String, dynamic> data) {
    return ArcoSuperior(
      id: data['id'],
      asExpansaoTransversal: AsExpansaoTransversal.fromJson(
        data['as_expansao_transversal'],
      ),
      asInclinProjVestDosIncisivo: AsInclinProjVestDosIncisivo.fromJson(
        data['as_inclin_proj_vest_dos_incisivo'],
      ),
      asDistDosDentesPosteriores: AsDistDosDentesPosteriores.fromJson(
        data['as_dist_dos_dentes_posteriores'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'as_expansao_transversal': asExpansaoTransversal.toJson(),
      'as_inclin_proj_vest_dos_incisivo': asInclinProjVestDosIncisivo.toJson(),
      'as_dist_dos_dentes_posteriores': asDistDosDentesPosteriores.toJson(),
    };
  }
}
