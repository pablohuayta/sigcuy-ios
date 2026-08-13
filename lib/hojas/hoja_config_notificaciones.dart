import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Configuración de notificaciones". Guarda en el repositorio.
Future<void> mostrarHojaConfigNotificaciones(BuildContext context) {
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
  late final _config = Repo.i.config;
  late final _gestacion = TextEditingController(
    text: '${_config.diasGestacion}',
  );
  late final _destete = TextEditingController(text: '${_config.diasDestete}');
  late final _limpieza = TextEditingController(text: '${_config.diasLimpieza}');
  late final _desinfeccion = TextEditingController(
    text: '${_config.diasDesinfeccion}',
  );
  late final _desparasitacion = TextEditingController(
    text: '${_config.diasDesparasitacion}',
  );
  late bool _reEmpadre = _config.reEmpadreAutomatico;

  @override
  void dispose() {
    _gestacion.dispose();
    _destete.dispose();
    _limpieza.dispose();
    _desinfeccion.dispose();
    _desparasitacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HojaContenedor(
      titulo: '⚙️ Configuración de notificaciones',
      subtitulo:
          'Define los días que usa la app para avisarte de los nacimientos, '
          'el destete de las crías y el mantenimiento de las posas.',
      contenido: [
        _Bloque(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          titulo: '🍼 Días de gestación (empadre)',
          colorTitulo: C.primary,
          descripcion:
              'Aviso de que una posa está por iniciar nacimientos. '
              'Habitual: 67 días.',
          etiqueta: 'Días de gestación',
          control: _gestacion,
        ),
        const SizedBox(height: 14),
        _Bloque(
          color: C.tinteVerde,
          borde: const Color(0xFFC8E6C9),
          titulo: '✂️ Días para el destete',
          colorTitulo: C.engorde,
          descripcion:
              'Aviso de que las crías ya pueden separarse de las madres. '
              'Habitual: 15 días.',
          etiqueta: 'Días para el destete',
          control: _destete,
        ),
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '🛠️ Mantenimiento de posas',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 14),
        _Bloque(
          color: C.tinteAzul,
          borde: const Color(0xFFBBDEFB),
          titulo: '🧹 Días entre limpiezas',
          colorTitulo: C.azulAccion,
          descripcion: 'Aviso para limpiar la posa. Habitual: 30 días.',
          etiqueta: 'Días entre limpiezas',
          control: _limpieza,
        ),
        const SizedBox(height: 14),
        _Bloque(
          color: C.tinteVerde,
          borde: const Color(0xFFC8E6C9),
          titulo: '🧴 Días entre desinfecciones',
          colorTitulo: C.engorde,
          descripcion: 'Aviso para desinfectar la posa. Habitual: 15 días.',
          etiqueta: 'Días entre desinfecciones',
          control: _desinfeccion,
        ),
        const SizedBox(height: 14),
        _Bloque(
          color: C.tinteNaranja,
          borde: const Color(0xFFF0DCC2),
          titulo: '💊 Días entre desparasitaciones',
          colorTitulo: C.primary,
          descripcion: 'Aviso para desparasitar. Habitual: 90 días (3 meses).',
          etiqueta: 'Días entre desparasitaciones',
          control: _desparasitacion,
        ),
        const SizedBox(height: 14),
        TarjetaTinte(
          color: C.tinteAzul,
          borde: const Color(0xFFBBDEFB),
          hijo: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔄 Re-empadre automático',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: C.azulAccion,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Predice la próxima parición desde la fecha de cada '
                      'parto (celo post-parto).',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: C.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _reEmpadre,
                activeThumbColor: C.primary,
                onChanged: (v) => setState(() => _reEmpadre = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
      botonPrincipal: ElevatedButton(
        onPressed: _guardar,
        child: const Text('Guardar configuración'),
      ),
    );
  }

  Future<void> _guardar() async {
    int leer(TextEditingController c, int actual) =>
        int.tryParse(c.text.trim()) ?? actual;

    _config.diasGestacion = leer(_gestacion, _config.diasGestacion);
    _config.diasDestete = leer(_destete, _config.diasDestete);
    _config.diasLimpieza = leer(_limpieza, _config.diasLimpieza);
    _config.diasDesinfeccion = leer(_desinfeccion, _config.diasDesinfeccion);
    _config.diasDesparasitacion = leer(
      _desparasitacion,
      _config.diasDesparasitacion,
    );
    _config.reEmpadreAutomatico = _reEmpadre;

    await Repo.i.guardarConfiguracion();
    if (mounted) Navigator.of(context).pop();
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({
    required this.color,
    required this.borde,
    required this.titulo,
    required this.colorTitulo,
    required this.descripcion,
    required this.etiqueta,
    required this.control,
  });

  final Color color;
  final Color borde;
  final String titulo;
  final Color colorTitulo;
  final String descripcion;
  final String etiqueta;
  final TextEditingController control;

  @override
  Widget build(BuildContext context) {
    return TarjetaTinte(
      color: color,
      borde: borde,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colorTitulo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: C.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: control,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              labelText: etiqueta,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: const TextStyle(color: C.gray600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
