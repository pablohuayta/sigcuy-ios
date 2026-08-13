import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Contenido del QR de una posa.
///
/// Es el mismo esquema que `QrGenerator.generarQrPosa()` en Android:
/// `appcuy://posa/{codigo}`. Mantenerlo idéntico importa, porque así un QR
/// impreso desde la app Android se lee en la de iOS y al revés.
String contenidoQrPosa(String codigo) => 'appcuy://posa/$codigo';

/// Extrae el código de posa de un texto escaneado.
///
/// Acepta la URI completa y también el código pelado, por si el criador
/// escribe "A1" a mano. Devuelve null si el QR no es de SigCuy.
String? codigoDesdeQr(String texto) {
  const prefijo = 'appcuy://posa/';
  final limpio = texto.trim();
  if (limpio.startsWith(prefijo)) {
    final codigo = limpio.substring(prefijo.length).trim();
    return codigo.isEmpty ? null : codigo.toUpperCase();
  }
  // Código suelto: letras seguidas de números, como A1 o JAU12.
  if (RegExp(r'^[A-Za-z]+\d+$').hasMatch(limpio)) return limpio.toUpperCase();
  return null;
}

/// Dibuja un código QR.
///
/// Se pinta a mano sobre el paquete `qr` (Dart puro) en vez de usar un
/// paquete de widgets, para no depender de librerías que se quedan atrás
/// respecto a la versión de Flutter.
class CodigoQr extends StatelessWidget {
  const CodigoQr({
    super.key,
    required this.datos,
    this.tamano = 240,
    this.color = Colors.black,
    this.fondo = Colors.white,
    this.margen = 12,
  });

  final String datos;
  final double tamano;
  final Color color;
  final Color fondo;
  final double margen;

  @override
  Widget build(BuildContext context) {
    final codigo = QrCode.fromData(
      data: datos,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final imagen = QrImage(codigo);

    return Container(
      width: tamano,
      height: tamano,
      color: fondo,
      padding: EdgeInsets.all(margen),
      child: CustomPaint(
        painter: _PintorQr(imagen: imagen, color: color),
        size: Size.square(tamano - margen * 2),
      ),
    );
  }
}

class _PintorQr extends CustomPainter {
  _PintorQr({required this.imagen, required this.color});

  final QrImage imagen;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final modulos = imagen.moduleCount;
    final lado = size.width / modulos;
    final pincel = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (var fila = 0; fila < modulos; fila++) {
      for (var col = 0; col < modulos; col++) {
        if (!imagen.isDark(fila, col)) continue;
        canvas.drawRect(
          // Se añade medio píxel para que no queden rendijas blancas entre
          // módulos por el redondeo de coordenadas.
          Rect.fromLTWH(col * lado, fila * lado, lado + 0.5, lado + 0.5),
          pincel,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorQr old) =>
      old.imagen != imagen || old.color != color;
}
