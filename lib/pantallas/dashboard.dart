import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import 'historial.dart';
import 'notificaciones.dart';
import 'shell.dart';

/// Pantalla "Inicio".
class DashboardPantalla extends StatelessWidget {
  const DashboardPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final categorias = repo.porCategoria;
    final maximo = categorias.values.isEmpty
        ? 1
        : categorias.values.reduce((a, b) => a > b ? a : b);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        children: [
          _cabecera(),
          const SizedBox(height: 14),
          _TarjetaHero(repo: repo),
          const SizedBox(height: 18),
          const _Titulo('Accesos rápidos'),
          const SizedBox(height: 10),
          _accesos(context, repo),
          const SizedBox(height: 18),
          const _Titulo('Por categoría'),
          const SizedBox(height: 10),
          if (repo.poblacionTotal == 0)
            Card(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 26),
                child: Center(
                  child: Text(
                    'Todavía no hay cuys registrados',
                    style: TextStyle(fontSize: 14.5, color: C.textSecondary),
                  ),
                ),
              ),
            )
          else
            for (final cat in [
              Categoria.gazapo,
              Categoria.reproductoras,
              Categoria.recria,
              Categoria.engorde,
              Categoria.descarte,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FilaCategoria(
                  categoria: cat,
                  cantidad: categorias[cat] ?? 0,
                  maximo: maximo == 0 ? 1 : maximo,
                ),
              ),
        ],
      ),
    );
  }

  Widget _cabecera() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inicio',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'SigCuy · Panel general',
                style: TextStyle(fontSize: 13, color: C.textSecondary),
              ),
            ],
          ),
        ),
        const Text('🐹', style: TextStyle(fontSize: 40)),
      ],
    );
  }

  Widget _accesos(BuildContext context, Repo repo) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Acceso(
                icono: Icons.grid_view_rounded,
                tinte: C.tinteNaranja,
                colorIcono: C.primary,
                titulo: 'Galpones',
                valor: '${repo.totalPosas}',
                sufijo: ' posas',
                onTap: () => irAPestana(context, 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Acceso(
                icono: Icons.bar_chart,
                tinte: C.tinteAzul,
                colorIcono: C.azulAccion,
                titulo: 'Actividades',
                subtitulo: 'Limpieza, desinf., despar.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistorialPantalla()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _Acceso(
                icono: Icons.notifications,
                tinte: C.tinteRojo,
                colorIcono: C.rojoAccion,
                titulo: 'Notificaciones',
                subtitulo: 'Avisos recibidos',
                badge: repo.avisos().length,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificacionesPantalla(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Acceso(
                icono: Icons.person_outline,
                tinte: C.tinteAmarillo,
                colorIcono: C.amarilloAccion,
                titulo: 'Perfil',
                subtitulo: 'Ajustes y respaldo',
                onTap: () => irAPestana(context, 3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );
}

class _TarjetaHero extends StatelessWidget {
  const _TarjetaHero({required this.repo});
  final Repo repo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '🐹 SigCuy',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                'Gestión inteligente',
                style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Todo en un vistazo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          const Text(
            'Total de cuys en la granja',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
          ),
          Text(
            '${repo.totalAdultos}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 46,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ChipHero(
                  valor: '${repo.totalMachos}',
                  texto: '♂ Machos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChipHero(
                  valor: '${repo.totalHembras}',
                  texto: '♀ Hembras',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChipHero(
                  valor: '${repo.posasActivas}',
                  texto: 'Activas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipHero extends StatelessWidget {
  const _ChipHero({required this.valor, required this.texto});
  final String valor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x66FFFFFF)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            texto,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icono,
    required this.tinte,
    required this.colorIcono,
    required this.titulo,
    this.subtitulo,
    this.valor,
    this.sufijo,
    this.badge,
    required this.onTap,
  });

  final IconData icono;
  final Color tinte;
  final Color colorIcono;
  final String titulo;
  final String? subtitulo;
  final String? valor;
  final String? sufijo;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: tinte,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icono, color: colorIcono, size: 20),
                  ),
                  if (badge != null && badge! > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: C.descarte,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    'Abrir ›',
                    style: TextStyle(
                      color: colorIcono,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              if (valor != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      valor!,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: C.primary,
                      ),
                    ),
                    Text(
                      sufijo ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: C.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  subtitulo ?? '',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: C.textSecondary,
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaCategoria extends StatelessWidget {
  const _FilaCategoria({
    required this.categoria,
    required this.cantidad,
    required this.maximo,
  });

  final Categoria categoria;
  final int cantidad;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: categoria.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    categoria.plural,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: categoria.color,
                    ),
                  ),
                ),
                Text(
                  '$cantidad',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: categoria.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: cantidad / maximo,
                minHeight: 6,
                backgroundColor: const Color(0xFFDCDCDC),
                valueColor: AlwaysStoppedAnimation(categoria.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
