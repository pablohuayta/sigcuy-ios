import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Trasladar a otra posa".
///
/// Equivale a `PosaRepository.registrarTraslado()`: escribe la salida en el
/// origen y la entrada en el destino en una sola operación, para que los
/// totales nunca queden descuadrados.
Future<void> mostrarHojaTraslado(BuildContext context, Posa origen) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Formulario(origen: origen),
  );
}

class _Formulario extends StatefulWidget {
  const _Formulario({required this.origen});
  final Posa origen;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
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
    final destinos = Repo.i.posasDestino(widget.origen.id);

    return HojaContenedor(
      titulo: '🔄 Trasladar cuys',
      subtitulo:
          'Los cuys salen de la posa ${widget.origen.codigo} y entran en la '
          'posa que elijas. Se registra en el historial de ambas.',
      contenido: [
        TarjetaTinte(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          hijo: Center(
            child: Text(
              'Disponibles en ${widget.origen.codigo}: '
              '♂${widget.origen.machos}  ♀${widget.origen.hembras}',
              style: const TextStyle(fontSize: 15.5, color: C.primary),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Posa de destino',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
        const SizedBox(height: 18),
        CampoNumero(etiqueta: '♂ Machos a trasladar', control: _machos),
        const SizedBox(height: 16),
        CampoNumero(etiqueta: '♀ Hembras a trasladar', control: _hembras),
        const SizedBox(height: 16),
        TextField(
          controller: _nota,
          decoration: const InputDecoration(
            hintText: 'Observaciones (opcional)',
          ),
        ),
        const SizedBox(height: 4),
      ],
      botonPrincipal: ElevatedButton(
        onPressed: _trasladar,
        child: const Text('🔄  Trasladar'),
      ),
    );
  }

  Future<void> _trasladar() async {
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    if (_destino == null) {
      mensajero.showSnackBar(
        const SnackBar(content: Text('Elige la posa de destino')),
      );
      return;
    }

    final error = await Repo.i.registrarTraslado(
      widget.origen,
      _destino!,
      machos: int.tryParse(_machos.text) ?? 0,
      hembras: int.tryParse(_hembras.text) ?? 0,
      nota: _nota.text.trim(),
    );

    if (error != null) {
      mensajero.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    navegador.pop();
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          'Traslado registrado hacia la posa ${_destino!.codigo}',
        ),
      ),
    );
  }
}
