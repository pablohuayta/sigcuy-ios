import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../hojas/hoja_actividad.dart';
import '../hojas/hoja_baja_crias.dart';
import '../hojas/hoja_destete.dart';
import '../hojas/hoja_nacimiento.dart';
import '../hojas/hoja_traslado.dart';
import '../tema.dart';
import 'agregar_cuys.dart';
import 'qr_viewer.dart';
import 'registrar_salida.dart';

/// Ficha de la posa.
class PosaDetailPantalla extends StatelessWidget {
  const PosaDetailPantalla({super.key, required this.posaId});
  final int posaId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) {
        final posa = Repo.i.posaPorId(posaId);
        if (posa == null) return const Scaffold();
        return _Contenido(posa: posa);
      },
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.posa});
  final Posa posa;

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final movs = repo.movimientosDe(posa.id);
    final ultimo = repo.ultimoMovimiento(posa.id);

    return Scaffold(
      backgroundColor: C.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _bloqueNaranja(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _accionesRapidas(context),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => mostrarHojaNacimiento(context, posa),
                  child: const Text('🐹  Registrar Nacimiento de Crías'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => mostrarHojaTraslado(context, posa),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: C.recria,
                    side: const BorderSide(color: C.recria),
                  ),
                  child: const Text('🔄  Trasladar a otra posa'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => mostrarHojaActividad(context, posa),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: C.primary,
                    side: const BorderSide(color: C.primary),
                  ),
                  child: const Text('🧹  Actividad'),
                ),
                const SizedBox(height: 14),
                Text(
                  'Último movimiento: ${ultimo == null ? '—' : fechaHora(ultimo)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: C.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Historial de movimientos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (movs.isEmpty)
                  Card(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Sin movimientos registrados',
                          style: TextStyle(
                            fontSize: 14,
                            color: C.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  for (final m in movs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _FilaMovimiento(m: m),
                    ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () => _eliminar(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: C.descarte,
                    side: const BorderSide(color: Color(0xFFEF9A9A)),
                  ),
                  child: const Text('🗑  Eliminar Posa'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloqueNaranja(BuildContext context) {
    final arriba = MediaQuery.of(context).padding.top;

    return Container(
      color: C.primary,
      padding: EdgeInsets.fromLTRB(20, arriba + 8, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: const Padding(
                  padding: EdgeInsets.only(right: 8, top: 4),
                  child: Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Repo.i.galponDe(posa)?.nombre ?? '',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      posa.codigo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      posa.categoria.chip,
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QrViewerPantalla(posaId: posa.id),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0x33FFFFFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text(
                    'Ver QR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('${posa.totalAdultos}', 'Total'),
              _stat('${posa.machos}', '♂ Machos'),
              _stat('${posa.hembras}', '♀ Hembras'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x44FFFFFF), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  posa.empadre == null
                      ? '📅 Sin empadre registrado'
                      : '📅 Empadre: ${fechaCorta(posa.empadre!)}  ·  '
                            'Nacimientos ≈ ${fechaCorta(posa.empadre!.add(Duration(days: Repo.i.config.diasGestacion)))}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _editarEmpadre(context),
                child: const Text(
                  'Editar',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x44FFFFFF), height: 1),
          const SizedBox(height: 10),
          if (posa.categoria == Categoria.reproductoras &&
              posa.hembras > 0) ...[
            Text(
              '🍼 Partos del ciclo: ${Repo.i.partosEnCiclo(posa)}/'
              '${Repo.i.limiteDePartos(posa)}  ·  una hembra, un parto',
              style: const TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 10),
          ],
          const Text(
            '🐹 Crías en esta posa',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
          ),
          const SizedBox(height: 6),
          Center(
            child: Column(
              children: [
                Text(
                  '${posa.crias}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'Total crías',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _botonBlanco(
            icono: Icons.share,
            texto: '✂️  Destetar crías',
            onTap: () => mostrarHojaDestete(context, posa),
          ),
          const SizedBox(height: 10),
          _botonBlanco(
            icono: Icons.delete_outline,
            texto: '🐹  Registrar baja de crías',
            onTap: () => mostrarHojaBajaCrias(context, posa),
          ),
        ],
      ),
    );
  }

  Widget _stat(String valor, String etiqueta) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            etiqueta,
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _botonBlanco({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x66FFFFFF)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          children: [
            Icon(icono, size: 18, color: Colors.white),
            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 18),
          ],
        ),
      ),
    );
  }

  Widget _accionesRapidas(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AgregarCuysPantalla(posaId: posa.id),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Agregar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RegistrarSalidaPantalla(posaId: posa.id),
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: C.onSurface,
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.remove, size: 20),
            label: const Text('Salida'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _vaciar(context),
            style: ElevatedButton.styleFrom(backgroundColor: C.descarte),
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Vaciar'),
          ),
        ),
      ],
    );
  }

  Future<void> _editarEmpadre(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: posa.empadre ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (fecha != null) await Repo.i.registrarEmpadre(posa, fecha);
  }

  Future<void> _vaciar(BuildContext context) async {
    final ok = await _confirmar(
      context,
      'Vaciar posa ${posa.codigo}',
      'Se pondrán en cero los machos, hembras y crías de esta posa.',
      'Vaciar',
    );
    if (ok) await Repo.i.vaciarPosa(posa);
  }

  Future<void> _eliminar(BuildContext context) async {
    final ok = await _confirmar(
      context,
      'Eliminar posa ${posa.codigo}',
      'Se borrará la posa junto con su historial. No se puede deshacer.',
      'Eliminar',
    );
    if (!ok) return;
    await Repo.i.eliminarPosa(posa.id);
    if (context.mounted) Navigator.of(context).maybePop();
  }

  Future<bool> _confirmar(
    BuildContext context,
    String titulo,
    String mensaje,
    String accion,
  ) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(accion, style: const TextStyle(color: C.descarte)),
          ),
        ],
      ),
    );
    return r == true;
  }
}

class _FilaMovimiento extends StatelessWidget {
  const _FilaMovimiento({required this.m});
  final Movimiento m;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${m.emoji} ${m.titulo}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: m.color,
                    ),
                  ),
                ),
                if (m.derecha.isNotEmpty)
                  Text(
                    m.derecha,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            if (m.categoriaTexto.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  m.categoriaTexto,
                  style: const TextStyle(
                    fontSize: 12,
                    color: C.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.nota,
                    style: const TextStyle(
                      fontSize: 13,
                      color: C.textSecondary,
                    ),
                  ),
                ),
                Text(
                  fechaHora(m.fecha),
                  style: const TextStyle(fontSize: 12, color: C.gray600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
