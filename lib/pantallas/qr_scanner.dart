import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/qr.dart';
import 'posa_detail.dart';

/// Escáner de códigos QR con cámara en vivo.
///
/// Réplica de `QrScannerFragment`. En Android la cámara la maneja ZXing; aquí
/// la maneja `mobile_scanner`, que usa la cámara nativa en móvil y la webcam
/// en el navegador.
///
/// Cuando no hay cámara disponible —el simulador de iOS no tiene, y el
/// navegador puede denegar el permiso— se cae al modo manual: escribir el
/// código de la posa. Así la pantalla nunca queda inservible.
class QrScannerPantalla extends StatefulWidget {
  const QrScannerPantalla({super.key});

  @override
  State<QrScannerPantalla> createState() => _QrScannerPantallaState();
}

class _QrScannerPantallaState extends State<QrScannerPantalla> {
  final _controlador = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _codigo = TextEditingController();

  bool _manual = false;
  bool _procesando = false;
  bool _linterna = false;

  @override
  void dispose() {
    _controlador.dispose();
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _cabecera(),
          Expanded(
            child: _manual ? _modoManual() : _modoCamara(),
          ),
        ],
      ),
    );
  }

  Widget _cabecera() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.primary, Color(0xFFD84315)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 6,
        12,
        14,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 26,
            ),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escanear Posa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Apunta al código QR de la posa',
                  style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                ),
              ],
            ),
          ),
          if (!_manual)
            IconButton(
              onPressed: () async {
                await _controlador.toggleTorch();
                setState(() => _linterna = !_linterna);
              },
              icon: Icon(
                _linterna ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 24,
              ),
            ),
          IconButton(
            onPressed: () => setState(() => _manual = !_manual),
            icon: Icon(
              _manual ? Icons.photo_camera_outlined : Icons.keyboard_alt_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modoCamara() {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controlador,
          fit: BoxFit.cover,
          onDetect: _alDetectar,
          errorBuilder: (context, error) => _sinCamara(error),
          placeholderBuilder: (context) => const ColoredBox(
            color: Color(0xFF0D0D0F),
            child: Center(
              child: CircularProgressIndicator(color: C.primary),
            ),
          ),
        ),
        // Oscurecido alrededor del visor.
        const ColoredBox(color: Color(0x66000000)),
        Center(
          child: SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(painter: _MarcoEnfoque()),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: C.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Buscando código QR...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Cada posa tiene su propio código QR. Encuádralo dentro del '
                'visor naranja para acceder a su ficha.',
                style: TextStyle(
                  color: Color(0xAAFFFFFF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Se muestra cuando la cámara no está disponible: sin permiso, sin
  /// dispositivo, o en el simulador de iOS, que no tiene cámara.
  Widget _sinCamara(MobileScannerException error) {
    return ColoredBox(
      color: const Color(0xFF0D0D0F),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Color(0x99FFFFFF),
              size: 54,
            ),
            const SizedBox(height: 18),
            const Text(
              'No se pudo abrir la cámara',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error.errorCode == MobileScannerErrorCode.permissionDenied
                  ? 'Se necesita permiso de cámara para escanear. Actívalo en '
                        'los ajustes del navegador o del dispositivo.'
                  : 'Este dispositivo no tiene cámara disponible. Puedes '
                        'escribir el código de la posa a mano.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xAAFFFFFF),
                fontSize: 14.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => setState(() => _manual = true),
              icon: const Icon(Icons.keyboard_alt_outlined, size: 20),
              label: const Text('Escribir el código'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modoManual() {
    return ColoredBox(
      color: const Color(0xFF0D0D0F),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              child: Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: CustomPaint(painter: _MarcoEnfoque()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Buscar posa por código',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escribe el código impreso en la posa, o el contenido completo '
              'del QR.',
              style: TextStyle(
                color: Color(0xAAFFFFFF),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _codigo,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Código o appcuy://posa/A1',
                prefixIcon: const Icon(Icons.qr_code_2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) => _resolver(v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _resolver(_codigo.text),
                child: const Text('Abrir posa'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_procesando) return;
    final valor = captura.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (valor == null) return;
    _resolver(valor);
  }

  Future<void> _resolver(String texto) async {
    if (_procesando) return;
    final limpio = texto.trim();
    if (limpio.isEmpty) return;

    _procesando = true;

    // Igual que en Android: primero se valida que el QR sea de SigCuy.
    final codigo = codigoDesdeQr(limpio);
    if (codigo == null) {
      _aviso('QR no válido para SigCuy');
      return;
    }

    final posa = Repo.i.posaPorCodigo(codigo);
    if (posa == null) {
      _aviso("Posa '$codigo' no encontrada");
      return;
    }

    await _controlador.stop();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PosaDetailPantalla(posaId: posa.id)),
    );
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
    // Se espera un momento antes de admitir otra lectura, para que la cámara
    // no dispare el mismo error veinte veces por segundo.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _procesando = false;
    });
  }
}

class _MarcoEnfoque extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = C.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.square;

    final l = size.width * 0.25;

    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - l, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, l),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - l)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - l, size.height),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(l, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - l),
      p,
    );

    canvas.drawLine(
      Offset(6, size.height / 2),
      Offset(size.width - 6, size.height / 2),
      Paint()
        ..color = C.primary.withValues(alpha: 0.75)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
