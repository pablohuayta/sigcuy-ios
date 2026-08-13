import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import 'hoja_base.dart';

/// Hoja "Generar Posas": crea el galpón y sus posas.
Future<void> mostrarHojaGenerarPosas(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _Formulario(),
  );
}

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _letra = TextEditingController();
  final _desde = TextEditingController(text: '1');
  final _hasta = TextEditingController();

  @override
  void dispose() {
    _letra.dispose();
    _desde.dispose();
    _hasta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HojaContenedor(
      titulo: 'Generar Posas',
      subtitulo: 'Selecciona el galpón y el rango de posas a crear',
      conCerrar: false,
      conAsa: true,
      contenido: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Galpón:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final l in const ['A', 'B', 'C', 'D', 'E', 'F']) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _letra.text = l),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _letra.text == l ? C.primary : C.orange50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF0DCC2)),
                    ),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _letra.text == l ? Colors.white : C.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              if (l != 'F') const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _letra,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Letra del galpón (ej: A)',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _numero(_desde, 'Desde N°', etiqueta: true)),
            const SizedBox(width: 14),
            Expanded(child: _numero(_hasta, 'Hasta N°')),
          ],
        ),
        const SizedBox(height: 14),
      ],
      botonPrincipal: TextButton(
        onPressed: _generar,
        style: TextButton.styleFrom(
          foregroundColor: C.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Generar Posas'),
      ),
    );
  }

  Widget _numero(
    TextEditingController c,
    String texto, {
    bool etiqueta = false,
  }) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: etiqueta ? texto : null,
        hintText: etiqueta ? null : texto,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: C.gray600, fontSize: 15),
      ),
    );
  }

  Future<void> _generar() async {
    final letra = _letra.text.trim().toUpperCase();
    final desde = int.tryParse(_desde.text) ?? 0;
    final hasta = int.tryParse(_hasta.text) ?? 0;

    if (letra.isEmpty) {
      _aviso('Escribe la letra del galpón');
      return;
    }
    if (desde < 1 || hasta < desde) {
      _aviso('Revisa el rango de números');
      return;
    }
    if (hasta - desde > 499) {
      _aviso('El rango no puede superar las 500 posas');
      return;
    }

    // El mensajero se toma antes de cerrar la hoja: después, este contexto
    // ya no existe y mostrar el aviso fallaría.
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    final creadas = await Repo.i.generarPosas(letra, desde, hasta);
    navegador.pop();
    mensajero.showSnackBar(
      SnackBar(
        content: Text(
          creadas == 0
              ? 'No se creó ninguna posa: ya existían todas'
              : 'Se crearon $creadas posas en el Galpón $letra',
        ),
      ),
    );
  }

  void _aviso(String m) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m)));
}
