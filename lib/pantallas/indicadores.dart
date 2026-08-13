import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/vacio.dart';

/// Pestaña "Indicadores". Todo se calcula desde el repositorio.
class IndicadoresPantalla extends StatelessWidget {
  const IndicadoresPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;

    return Scaffold(
      backgroundColor: C.background,
      appBar: const BarraSigCuy(titulo: 'Indicadores', emoji: '📊'),
      body: repo.posas.isEmpty
          ? const EstadoVacio(
              emoji: '📊',
              titulo: 'Aún no hay nada que medir',
              mensaje:
                  'Crea galpones y registra tus cuys; los indicadores se '
                  'calculan solos a partir de los movimientos',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
              children: [
                _Resumen(repo: repo),
                const SizedBox(height: 18),
                const _Titulo('Reproducción'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Metrica(
                        emoji: '🍼',
                        valor: '${repo.partos}',
                        etiqueta: 'Partos',
                        color: C.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metrica(
                        emoji: '🐹',
                        valor: '${repo.criasNacidas}',
                        etiqueta: 'Crías nacidas',
                        color: C.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Metrica(
                        emoji: '💀',
                        valor: '${repo.criasMuertas}',
                        etiqueta: 'Crías muertas',
                        color: C.descarte,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metrica(
                        emoji: '📊',
                        valor: repo.criasPorParto,
                        etiqueta: 'Crías / parto',
                        color: C.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _MachosVsHembras(repo: repo),
                const SizedBox(height: 14),
                _PorCategoria(repo: repo),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '📋 Movimientos históricos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${repo.movimientosHistoricos} total',
                          style: const TextStyle(
                            fontSize: 14,
                            color: C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
  );
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.repo});
  final Repo repo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de tu granja',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actualizado: ${fechaHora(DateTime.now())}',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('🐾', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Población total (incluye crías)',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
          Text(
            '${repo.poblacionTotal}',
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
                child: _ChipResumen(
                  valor: '${repo.totalAdultos}',
                  texto: 'Adultos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChipResumen(
                  valor: '${repo.totalCrias}',
                  texto: '🐹 Crías',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChipResumen(
                  valor: '${repo.posasActivas}',
                  texto: 'Posas activas',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipResumen extends StatelessWidget {
  const _ChipResumen({required this.valor, required this.texto});
  final String valor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x66FFFFFF)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            child: Text(
              texto,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.emoji,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final String emoji;
  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(fontSize: 14, color: C.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MachosVsHembras extends StatelessWidget {
  const _MachosVsHembras({required this.repo});
  final Repo repo;

  @override
  Widget build(BuildContext context) {
    final sinAdultos = repo.totalAdultos == 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '♀ Machos vs Hembras (adultos)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 14,
                child: sinAdultos
                    ? Container(color: const Color(0xFFE8E0D8))
                    : Row(
                        children: [
                          Expanded(
                            flex: repo.porcentajeMachos.clamp(0, 100),
                            child: Container(color: C.macho),
                          ),
                          Expanded(
                            flex: repo.porcentajeHembras.clamp(0, 100),
                            child: Container(color: C.hembra),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _leyenda(
                  C.macho,
                  '♂ Machos: ${repo.totalMachos} (${repo.porcentajeMachos}%)',
                ),
                _leyenda(
                  C.hembra,
                  '♀ Hembras: ${repo.totalHembras} (${repo.porcentajeHembras}%)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PorCategoria extends StatelessWidget {
  const _PorCategoria({required this.repo});
  final Repo repo;

  @override
  Widget build(BuildContext context) {
    final datos = repo.porCategoria;
    final maximo = datos.values.isEmpty
        ? 1
        : datos.values.reduce((a, b) => a > b ? a : b);

    const orden = [
      Categoria.gazapo,
      Categoria.recria,
      Categoria.engorde,
      Categoria.reproductoras,
      Categoria.descarte,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🐾 Cuys por categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final cat in orden) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${cat.emoji} ${cat.singular}',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: cat.color,
                      ),
                    ),
                  ),
                  Text(
                    '${datos[cat] ?? 0}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: cat.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: maximo == 0 ? 0 : (datos[cat] ?? 0) / maximo,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE8E0D8),
                  valueColor: AlwaysStoppedAnimation(cat.color),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
