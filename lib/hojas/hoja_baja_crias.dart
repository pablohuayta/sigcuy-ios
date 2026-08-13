import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Registrar Baja de Crías".
Future<void> mostrarHojaBajaCrias(BuildContext context, Posa posa) {
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
  final _cantidad = TextEditingController(text: '0');
  final _nota = TextEditingController();

  @override
  void dispose() {
    _cantidad.dispose();
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cantidad = int.tryParse(_cantidad.text) ?? 0;

    return HojaContenedor(
      titulo: '🐹 Registrar Baja de Crías',
      subtitulo:
          'Registra las crías que murieron. Se descontarán de los contadores '
          'de esta posa.',
      contenido: [
        TarjetaTinte(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          hijo: Center(
            child: Text(
              'Crías actuales: ${widget.posa.crias}',
              style: const TextStyle(fontSize: 16, color: C.primary),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TarjetaTinte(
          color: const Color(0xFFFDEDED),
          borde: const Color(0xFFF5C6C6),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          hijo: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💀 Crías muertas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: C.descarte,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _cantidad,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 17),
                decoration: const InputDecoration(
                  labelText: 'Cantidad de crías muertas',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(color: C.gray600, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _nota,
          decoration: const InputDecoration(
            hintText: 'Observaciones (opcional)',
          ),
        ),
        const SizedBox(height: 14),
        TarjetaTinte(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          hijo: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Total baja: ',
                    style: TextStyle(fontSize: 16, color: C.textSecondary),
                  ),
                  TextSpan(
                    text: '$cantidad crías',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: C.descarte,
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
        onPressed: _guardar,
        style: ElevatedButton.styleFrom(backgroundColor: C.descarte),
        child: const Text('🐹  Registrar Baja'),
      ),
    );
  }

  Future<void> _guardar() async {
    final cantidad = int.tryParse(_cantidad.text) ?? 0;

    if (cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica cuántas crías murieron')),
      );
      return;
    }
    if (cantidad > widget.posa.crias) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La posa solo tiene ${widget.posa.crias} crías'),
        ),
      );
      return;
    }

    await Repo.i.registrarBajaCrias(
      widget.posa,
      cantidad,
      nota: _nota.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }
}
