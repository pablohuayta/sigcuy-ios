import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';

/// Pantalla "Registrar Salida / Venta".
///
/// Si el motivo es **Traslado** no basta con descontar: hay que decir a qué
/// posa van los cuys, y el movimiento se escribe en las dos. Por eso aparece
/// el selector de destino solo en ese caso.
class RegistrarSalidaPantalla extends StatefulWidget {
  const RegistrarSalidaPantalla({super.key, required this.posaId});
  final int posaId;

  @override
  State<RegistrarSalidaPantalla> createState() =>
      _RegistrarSalidaPantallaState();
}

class _RegistrarSalidaPantallaState extends State<RegistrarSalidaPantalla> {
  MotivoSalida? _motivo;
  Posa? _destino;
  final _machos = TextEditingController(text: '0');
  final _hembras = TextEditingController(text: '0');
  final _nota = TextEditingController();

  @override
  void dispose() {
    _machos.dispose();
    _hembras.dispose();
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posa = Repo.i.posaPorId(widget.posaId);
    if (posa == null) return const Scaffold();

    final esTraslado = _motivo == MotivoSalida.traslado;
    final destinos = Repo.i.posasDestino(posa.id);

    return Scaffold(
      backgroundColor: C.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            const Text(
              'Registrar Salida / Venta',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TarjetaTinte(
              color: C.tinteNaranja,
              borde: const Color(0xFFF0DCC2),
              hijo: Center(
                child: Text(
                  'Disponibles en ${posa.codigo}: '
                  '♂${posa.machos}  ♀${posa.hembras}',
                  style: const TextStyle(fontSize: 15.5, color: C.primary),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Motivo de salida:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in MotivoSalida.values)
                  ChipOpcion(
                    texto: '${m.emoji} ${m.etiqueta}',
                    activo: _motivo == m,
                    onTap: () => setState(() => _motivo = m),
                  ),
              ],
            ),
            if (esTraslado) ...[
              const SizedBox(height: 20),
              const Text(
                'Posa de destino:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (destinos.isEmpty)
                const Text(
                  'No hay otras posas creadas todavía.',
                  style: TextStyle(fontSize: 14.5, color: C.textSecondary),
                )
              else
                DropdownButtonFormField<Posa>(
                  initialValue: _destino,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Elige la posa de destino',
                  ),
                  items: [
                    for (final p in destinos)
                      DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.codigo}  ·  ${p.categoria.chip}  ·  '
                          '♂${p.machos} ♀${p.hembras}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                  ],
                  onChanged: (p) => setState(() => _destino = p),
                ),
            ],
            const SizedBox(height: 20),
            CampoNumero(etiqueta: '♂ Cantidad de Machos', control: _machos),
            const SizedBox(height: 16),
            CampoNumero(etiqueta: '♀ Cantidad de Hembras', control: _hembras),
            const SizedBox(height: 16),
            TextField(
              controller: _nota,
              decoration: const InputDecoration(
                hintText: 'Observaciones (opcional)',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _guardar(posa),
              child: const Text('Guardar'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar(Posa posa) async {
    final m = int.tryParse(_machos.text) ?? 0;
    final h = int.tryParse(_hembras.text) ?? 0;

    if (_motivo == null) {
      _aviso('Elige el motivo de la salida');
      return;
    }
    if (m <= 0 && h <= 0) {
      _aviso('Indica cuántos cuys salen');
      return;
    }
    if (m > posa.machos || h > posa.hembras) {
      _aviso('La posa tiene ${posa.machos} machos y ${posa.hembras} hembras');
      return;
    }

    if (_motivo == MotivoSalida.traslado) {
      if (_destino == null) {
        _aviso('Elige la posa de destino');
        return;
      }
      final error = await Repo.i.registrarTraslado(
        posa,
        _destino!,
        machos: m,
        hembras: h,
        nota: _nota.text.trim(),
      );
      if (error != null) {
        _aviso(error);
        return;
      }
    } else {
      await Repo.i.registrarSalida(
        posa,
        machos: m,
        hembras: h,
        motivo: _motivo!,
        nota: _nota.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).maybePop();
  }

  void _aviso(String m) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m)));
}
