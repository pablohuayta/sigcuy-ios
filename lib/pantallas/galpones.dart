import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../hojas/hoja_generar_posas.dart';
import '../tema.dart';
import '../widgets/vacio.dart';
import 'posas_del_galpon.dart';

/// Pestaña "Posas": lista de galpones.
class GalponesPantalla extends StatelessWidget {
  const GalponesPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;

    return Scaffold(
      backgroundColor: C.background,
      appBar: const BarraSigCuy(titulo: 'Galpones'),
      body: repo.galpones.isEmpty
          ? const EstadoVacio(
              emoji: '🐾',
              titulo: 'Sin galpones aún',
              mensaje:
                  'Toca el botón + para crear un galpón y generar sus posas',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
              itemCount: repo.galpones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ItemGalpon(galpon: repo.galpones[i]),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 46),
        child: FloatingActionButton.extended(
          onPressed: () => mostrarHojaGenerarPosas(context),
          backgroundColor: C.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add, size: 26),
          label: const Text(
            'Nuevo Galpón',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ItemGalpon extends StatelessWidget {
  const _ItemGalpon({required this.galpon});
  final Galpon galpon;

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final total = repo.posasDe(galpon.id).length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PosasDelGalponPantalla(galponId: galpon.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: C.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  galpon.letra,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: galpon.letra.length > 1 ? 17 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      galpon.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$total posas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: C.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${repo.activasDe(galpon.id)} activas · '
                      '${repo.vaciasDe(galpon.id)} vacías',
                      style: const TextStyle(
                        fontSize: 13,
                        color: C.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmarBorrado(context, galpon),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF9A9A),
                  size: 26,
                ),
              ),
              const Icon(Icons.skip_next, color: Color(0xFF424242), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarBorrado(BuildContext context, Galpon g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Eliminar ${g.nombre}'),
        content: const Text(
          'Se borrarán también todas sus posas y su historial. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: C.descarte),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await Repo.i.eliminarGalpon(g.id);
  }
}
