import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../hojas/hoja_anadir_posas.dart';
import '../tema.dart';
import '../widgets/vacio.dart';
import 'historial.dart';
import 'posa_detail.dart';

/// Cuadrícula de tres columnas con las posas del galpón.
class PosasDelGalponPantalla extends StatelessWidget {
  const PosasDelGalponPantalla({super.key, required this.galponId});
  final int galponId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) {
        final repo = Repo.i;
        final galpon = repo.galpones
            .where((g) => g.id == galponId)
            .firstOrNull;
        if (galpon == null) return const Scaffold();

        final lista = repo.posasDe(galponId);

        return Scaffold(
          backgroundColor: C.background,
          appBar: BarraSigCuy(
            titulo: galpon.nombre,
            conVolver: true,
            subtitulo:
                '${lista.length} posas · ${repo.activasDe(galponId)} activas · '
                '${repo.vaciasDe(galponId)} vacías',
            acciones: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistorialPantalla()),
                ),
                icon: const Icon(Icons.pending_actions, size: 26),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 26),
              ),
            ],
          ),
          body: lista.isEmpty
              ? const EstadoVacio(
                  emoji: '📦',
                  titulo: 'Este galpón no tiene posas',
                  mensaje: 'Usa "Añadir posas" para crear el rango que necesites',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 110),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _TarjetaPosa(
                    posa: lista[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PosaDetailPantalla(posaId: lista[i].id),
                      ),
                    ),
                  ),
                ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: FloatingActionButton.extended(
              onPressed: () => mostrarHojaAnadirPosas(context, galpon),
              backgroundColor: C.primary,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.add, size: 26),
              label: const Text(
                'Añadir posas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaPosa extends StatelessWidget {
  const _TarjetaPosa({required this.posa, required this.onTap});

  final Posa posa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 9, 9, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      posa.codigo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: C.primary,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: C.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.grid_view,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: posa.categoria.colorChip,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  child: Text(
                    posa.categoria.chip,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${posa.totalAdultos}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: C.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Container(width: 1, height: 30, color: C.divider),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '♂ ${posa.machos}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: C.macho,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '♀ ${posa.hembras}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: C.hembra,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                posa.estado,
                style: TextStyle(
                  fontSize: 12.5,
                  color: posa.estaVacia ? C.gray600 : C.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
