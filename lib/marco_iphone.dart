import 'package:flutter/material.dart';

/// Dibuja un iPhone alrededor de la aplicación.
///
/// No es el simulador de Apple: es un marco que reproduce las medidas reales
/// de un iPhone 15/16 (393 x 852 puntos lógicos), su isla dinámica, la barra
/// de estado y el indicador inferior. Sirve para revisar y presentar la
/// interfaz desde una laptop con Windows.
///
/// Para desactivarlo y ver la app a pantalla completa, cambia `activo` a false
/// en `main.dart`.
class MarcoIPhone extends StatelessWidget {
  const MarcoIPhone({super.key, required this.child});

  final Widget child;

  // Medidas del iPhone 15 / 16 en puntos lógicos.
  static const double anchoPantalla = 393;
  static const double altoPantalla = 852;
  static const double areaSegura = 59; // isla dinámica + barra de estado
  static const double areaSeguraInferior = 34; // indicador de inicio

  @override
  Widget build(BuildContext context) {
    const double bisel = 12;

    return ColoredBox(
      color: const Color(0xFFE8E8EA),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: anchoPantalla + bisel * 2,
              height: altoPantalla + bisel * 2,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(66),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(bisel),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(54),
                child: SizedBox(
                  width: anchoPantalla,
                  height: altoPantalla,
                  child: MediaQuery(
                    // Se le miente al layout: la app cree que corre en un
                    // iPhone, con sus áreas seguras arriba y abajo.
                    data: MediaQuery.of(context).copyWith(
                      size: const Size(anchoPantalla, altoPantalla),
                      padding: const EdgeInsets.only(
                        top: areaSegura,
                        bottom: areaSeguraInferior,
                      ),
                      viewPadding: const EdgeInsets.only(
                        top: areaSegura,
                        bottom: areaSeguraInferior,
                      ),
                      viewInsets: EdgeInsets.zero,
                      textScaler: TextScaler.noScaling,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: child),
                        const _BarraEstadoIOS(),
                        const _IslaDinamica(),
                        const _IndicadorInicio(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hora, señal, wifi y batería, como en iOS.
class _BarraEstadoIOS extends StatelessWidget {
  const _BarraEstadoIOS();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MarcoIPhone.areaSegura,
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.only(top: 14, left: 32, right: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '9:41',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  CustomPaint(
                    size: const Size(17, 11),
                    painter: _SenalPainter(),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.wifi, size: 15, color: Colors.black),
                  const SizedBox(width: 5),
                  CustomPaint(
                    size: const Size(25, 12),
                    painter: _BateriaPainter(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SenalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    const barras = 4;
    final anchoBarra = size.width / (barras * 2 - 1);
    for (var i = 0; i < barras; i++) {
      final alto = size.height * (0.35 + 0.22 * i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * anchoBarra * 2,
            size.height - alto,
            anchoBarra,
            alto,
          ),
          const Radius.circular(1),
        ),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BateriaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final borde = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cuerpo = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width - 3, size.height),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(cuerpo, borde);

    // Punta
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 2, size.height * 0.3, 2, size.height * 0.4),
        const Radius.circular(1),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Carga
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 1.5, (size.width - 6) * 0.8, size.height - 3),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IslaDinamica extends StatelessWidget {
  const _IslaDinamica();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 11,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 125,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicadorInicio extends StatelessWidget {
  const _IndicadorInicio();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 140,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
