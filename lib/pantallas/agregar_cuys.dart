import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';

/// Pantalla "Agregar Cuys".
class AgregarCuysPantalla extends StatefulWidget {
  const AgregarCuysPantalla({super.key, required this.posaId});
  final int posaId;

  @override
  State<AgregarCuysPantalla> createState() => _AgregarCuysPantallaState();
}

class _AgregarCuysPantallaState extends State<AgregarCuysPantalla> {
  int _origen = -1;
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
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) {
        final posa = Repo.i.posaPorId(widget.posaId);
        if (posa == null) return const Scaffold();

        return Scaffold(
          backgroundColor: C.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                const Text(
                  'Agregar Cuys',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                SelectorCategoria(posa: posa),
                const SizedBox(height: 20),
                const Text(
                  '¿De dónde vienen los cuys?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChipOpcion(
                      texto: '🐹 Nacimiento',
                      activo: _origen == 0,
                      onTap: () => setState(() => _origen = 0),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: ChipOpcion(
                        texto: '🔄 Traslado de otra posa',
                        activo: _origen == 1,
                        onTap: () => setState(() => _origen = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CampoNumero(
                  etiqueta: '♂ Cantidad de Machos',
                  control: _machos,
                ),
                const SizedBox(height: 16),
                CampoNumero(
                  etiqueta: '♀ Cantidad de Hembras',
                  control: _hembras,
                ),
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
      },
    );
  }

  Future<void> _guardar(Posa posa) async {
    final m = int.tryParse(_machos.text) ?? 0;
    final h = int.tryParse(_hembras.text) ?? 0;

    if (m <= 0 && h <= 0) {
      _aviso('Indica al menos un macho o una hembra');
      return;
    }
    if (_origen == -1) {
      _aviso('Elige de dónde vienen los cuys');
      return;
    }
    if (posa.categoria == Categoria.vacia) {
      _aviso('Elige primero la categoría de la posa, tocando la llave 🔧');
      return;
    }

    await Repo.i.agregarCuys(
      posa,
      machos: m,
      hembras: h,
      porNacimiento: _origen == 0,
      nota: _nota.text.trim(),
    );
    if (mounted) Navigator.of(context).maybePop();
  }

  void _aviso(String m) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(m)));
}
