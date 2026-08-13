import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import 'hoja_base.dart';

/// Hoja "Añadir posas al Galpón X".
Future<void> mostrarHojaAnadirPosas(BuildContext context, Galpon galpon) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _Formulario(galpon: galpon),
  );
}

class _Formulario extends StatefulWidget {
  const _Formulario({required this.galpon});
  final Galpon galpon;

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _desde = TextEditingController();
  final _hasta = TextEditingController();

  @override
  void dispose() {
    _desde.dispose();
    _hasta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HojaContenedor(
      titulo: 'Añadir posas al ${widget.galpon.nombre}',
      subtitulo:
          'Las posas que ya existan en ese rango se omitirán automáticamente.',
      conCerrar: false,
      contenido: [
        _numero(_desde, 'Número inicial (ej: 11)'),
        const SizedBox(height: 16),
        _numero(_hasta, 'Número final (ej: 20)'),
        const SizedBox(height: 14),
      ],
      botonPrincipal: TextButton(
        onPressed: _anadir,
        style: TextButton.styleFrom(
          foregroundColor: C.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Añadir Posas'),
      ),
    );
  }

  Widget _numero(TextEditingController c, String hint) => TextField(
    controller: c,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    style: const TextStyle(fontSize: 17),
    decoration: InputDecoration(hintText: hint),
  );

  Future<void> _anadir() async {
    final desde = int.tryParse(_desde.text) ?? 0;
    final hasta = int.tryParse(_hasta.text) ?? 0;

    if (desde < 1 || hasta < desde) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa el rango de números')),
      );
      return;
    }

    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    final creadas = await Repo.i.generarPosas(
      widget.galpon.letra,
      desde,
      hasta,
    );
    navegador.pop();
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          creadas == 0
              ? 'No se creó ninguna posa: ya existían todas'
              : 'Se añadieron $creadas posas',
        ),
      ),
    );
  }
}
