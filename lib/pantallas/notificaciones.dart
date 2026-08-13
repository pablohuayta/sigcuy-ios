import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/vacio.dart';
import 'shell.dart';

/// Avisos calculados en el momento, igual que `RevisionRecordatorios`.
class NotificacionesPantalla extends StatelessWidget {
  const NotificacionesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) {
        final avisos = Repo.i.avisos();

        return Scaffold(
          backgroundColor: C.background,
          extendBody: true,
          appBar: BarraSigCuy(
            titulo: 'Notificaciones',
            emoji: '🔔',
            conVolver: true,
            acciones: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline, size: 26),
              ),
            ],
          ),
          body: avisos.isEmpty
              ? const EstadoVacio(
                  emoji: '🔔',
                  titulo: 'Sin avisos por ahora',
                  mensaje:
                      'Aquí aparecerán los recordatorios de parto, destete y '
                      'mantenimiento cuando se cumplan los días configurados',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                  itemCount: avisos.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _Item(a: avisos[i]),
                ),
          bottomNavigationBar: const BarraInferior(indice: -1),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.a});
  final Aviso a;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: C.verdeNotif,
                shape: BoxShape.circle,
              ),
              child: const Text('🐹', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.titulo,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.detalle,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: C.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fechaHora(a.fecha),
                    style: const TextStyle(fontSize: 12.5, color: C.gray600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
