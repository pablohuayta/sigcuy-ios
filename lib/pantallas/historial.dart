import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/vacio.dart';
import 'shell.dart';

/// Historial de actividades agrupado por galpón.
class HistorialPantalla extends StatelessWidget {
  const HistorialPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) {
        final repo = Repo.i;
        final registros = repo.actividadesOrdenadas();

        // Agrupa por galpón, como la cabecera "Galpón A · 30".
        final grupos = <int, List<RegistroActividad>>{};
        for (final a in registros) {
          final posa = repo.posaPorId(a.posaId);
          if (posa == null) continue;
          grupos.putIfAbsent(posa.galponId, () => []).add(a);
        }

        return Scaffold(
          backgroundColor: C.background,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            '‹ Volver',
                            style: TextStyle(
                              color: C.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Historial de actividades',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 66),
                    ],
                  ),
                ),
                Expanded(
                  child: registros.isEmpty
                      ? const EstadoVacio(
                          emoji: '🧹',
                          titulo: 'Sin actividades registradas',
                          mensaje:
                              'Registra limpiezas, desinfecciones y '
                              'desparasitaciones desde la ficha de cada posa',
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                          children: [
                            for (final entrada in grupos.entries) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '${repo.galpones.where((g) => g.id == entrada.key).firstOrNull?.nombre ?? 'Galpón'} '
                                  '· ${entrada.value.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: C.primary,
                                  ),
                                ),
                              ),
                              for (final a in entrada.value)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _Fila(a: a),
                                ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BarraInferior(indice: -1),
        );
      },
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.a});
  final RegistroActividad a;

  @override
  Widget build(BuildContext context) {
    final posa = Repo.i.posaPorId(a.posaId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Text(a.tipo.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.tipo.etiqueta,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Posa ${posa?.codigo ?? '—'}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: C.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              fechaHora(a.fecha),
              style: const TextStyle(fontSize: 14.5, color: C.gray600),
            ),
          ],
        ),
      ),
    );
  }
}
