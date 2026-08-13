import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Destetar crías".
Future<void> mostrarHojaDestete(BuildContext context, Posa posa) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Formulario(posa: posa),
  );
}

class _Formulario extends StatefulWidget {
  const _Formulario({required this.posa});
  final Posa posa;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _elegidas = <int>{};

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final camadas =
        widget.posa.camadas.where((c) => !c.destetada && c.vivas > 0).toList();
    final listas = repo.camadasDestetables(widget.posa).map((c) => c.id).toSet();
    final total = camadas
        .where((c) => _elegidas.contains(c.id))
        .fold(0, (s, c) => s + c.vivas);

    return HojaContenedor(
      titulo: '✂️ Destetar crías',
      subtitulo:
          'Selecciona los partos cuyas crías vas a separar. Solo se pueden '
          'destetar las camadas que ya cumplieron los días mínimos.',
      contenido: [
        Row(
          children: [
            const Expanded(
              child: Text('Fecha del destete', style: TextStyle(fontSize: 16)),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: C.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
              icon: const Text('📅', style: TextStyle(fontSize: 16)),
              label: const Text('Hoy'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => setState(() {
            if (_elegidas.containsAll(listas) && listas.isNotEmpty) {
              _elegidas.clear();
            } else {
              _elegidas
                ..clear()
                ..addAll(listas);
            }
          }),
          child: Row(
            children: [
              _Casilla(
                marcada: listas.isNotEmpty && _elegidas.containsAll(listas),
              ),
              const SizedBox(width: 12),
              const Text(
                'Destetar todas las listas',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (camadas.isEmpty)
          TarjetaTinte(
            color: C.tarjeta,
            borde: C.tarjetaBorde,
            padding: const EdgeInsets.symmetric(vertical: 22),
            hijo: const Center(
              child: Text(
                'Esta posa no tiene camadas sin destetar',
                style: TextStyle(fontSize: 14.5, color: C.textSecondary),
              ),
            ),
          )
        else
          for (final c in camadas) ...[
            _FilaCamada(
              camada: c,
              lista: listas.contains(c.id),
              marcada: _elegidas.contains(c.id),
              diasMinimos: repo.config.diasDestete,
              onTap: () {
                if (!listas.contains(c.id)) return;
                setState(() {
                  if (!_elegidas.remove(c.id)) _elegidas.add(c.id);
                });
              },
            ),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 6),
        TarjetaTinte(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          hijo: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'A destetar: ',
                    style: TextStyle(fontSize: 16, color: C.textSecondary),
                  ),
                  TextSpan(
                    text: '$total crías',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: C.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
      botonPrincipal: ElevatedButton(
        onPressed: _destetar,
        child: const Text('✂️  Destetar'),
      ),
    );
  }

  Future<void> _destetar() async {
    if (_elegidas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una camada')),
      );
      return;
    }
    await Repo.i.destetar(widget.posa, _elegidas.toList());
    if (mounted) Navigator.of(context).pop();
  }
}

class _FilaCamada extends StatelessWidget {
  const _FilaCamada({
    required this.camada,
    required this.lista,
    required this.marcada,
    required this.diasMinimos,
    required this.onTap,
  });

  final Camada camada;
  final bool lista;
  final bool marcada;
  final int diasMinimos;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dias = camada.diasDeVida(DateTime.now());
    final faltan = diasMinimos - dias;

    return GestureDetector(
      onTap: onTap,
      child: TarjetaTinte(
        color: C.tarjeta,
        borde: marcada ? C.primary : C.tarjetaBorde,
        padding: const EdgeInsets.all(16),
        hijo: Row(
          children: [
            _Casilla(marcada: marcada, apagada: !lista),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parto ${fechaCorta(camada.fecha)}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: lista ? C.onSurface : C.gray600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lista
                        ? '$dias días · lista para destetar'
                        : '$dias días · faltan $faltan',
                    style: const TextStyle(
                      fontSize: 14,
                      color: C.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '🐹 ${camada.vivas}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: C.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({required this.marcada, this.apagada = false});

  final bool marcada;
  final bool apagada;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: marcada ? C.primary : Colors.transparent,
        border: Border.all(
          color: apagada
              ? const Color(0xFFCFCFCF)
              : (marcada ? C.primary : const Color(0xFF9E9E9E)),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: marcada
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}
