import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Registrar Nacimiento de Crías".
///
/// Antes de abrirla se comprueban las mismas condiciones que en
/// `PosaDetailFragment`: que haya hembras, que exista empadre y que no se
/// haya llegado al límite de partos del ciclo.
Future<void> mostrarHojaNacimiento(BuildContext context, Posa posa) async {
  final impedimento = Repo.i.motivoParaNoRegistrarParto(posa);
  if (impedimento != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(impedimento), duration: const Duration(seconds: 4)),
    );
    return;
  }

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
  final _vivas = TextEditingController(text: '0');
  final _muertas = TextEditingController(text: '0');
  final _nota = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _vivas.dispose();
    _muertas.dispose();
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final usados = repo.partosEnCiclo(widget.posa);
    final limite = repo.limiteDePartos(widget.posa);
    final esHoy = _mismoDia(_fecha, DateTime.now());

    return HojaContenedor(
      titulo: '🐹 Registrar Nacimiento',
      subtitulo:
          'Anota el parto de la posa ${widget.posa.codigo}. Las crías vivas se '
          'suman a la posa y empiezan a contar para el destete.',
      contenido: [
        // Contador de partos del ciclo: una hembra, un parto.
        TarjetaTinte(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          hijo: Center(
            child: Text(
              'Partos registrados: $usados/$limite '
              '(quedan ${limite - usados})',
              style: const TextStyle(
                fontSize: 15.5,
                color: C.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Fecha del nacimiento',
                style: TextStyle(fontSize: 16),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              style: OutlinedButton.styleFrom(
                foregroundColor: C.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              icon: const Text('📅', style: TextStyle(fontSize: 16)),
              label: Text(esHoy ? 'Hoy' : fechaCorta(_fecha)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Empadre: ${fechaCorta(widget.posa.empadre!)} · el parto no puede '
          'ser anterior a esa fecha',
          style: const TextStyle(fontSize: 13, color: C.textSecondary),
        ),
        const SizedBox(height: 18),
        CampoNumero(etiqueta: 'Crías nacidas vivas', control: _vivas),
        const SizedBox(height: 16),
        CampoNumero(etiqueta: 'Crías nacidas muertas', control: _muertas),
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
        onPressed: _guardar,
        child: const Text('🐹  Registrar camada'),
      ),
    );
  }

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _elegirFecha() async {
    final empadre = widget.posa.empadre!;
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(empadre.year, empadre.month, empadre.day),
      lastDate: DateTime.now(),
    );
    if (elegida != null) setState(() => _fecha = elegida);
  }

  Future<void> _guardar() async {
    final vivas = int.tryParse(_vivas.text) ?? 0;
    final muertas = int.tryParse(_muertas.text) ?? 0;

    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);

    final error = await Repo.i.registrarNacimiento(
      widget.posa,
      vivas: vivas,
      muertas: muertas,
      fecha: _fecha,
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
          '🐹 Nacimiento registrado: $vivas crías vivas'
          '${muertas > 0 ? ', $muertas mortinatos' : ''}',
        ),
      ),
    );
  }
}
