import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/qr.dart';

/// Visor del QR de una posa. Réplica de `QrViewerFragment`.
///
/// En Android el botón guarda el PNG en `Pictures/AppCuy` vía MediaStore. En
/// web no existe la galería, así que se ofrece copiar el contenido del código.
class QrViewerPantalla extends StatelessWidget {
  const QrViewerPantalla({super.key, required this.posaId});
  final int posaId;

  @override
  Widget build(BuildContext context) {
    final posa = Repo.i.posaPorId(posaId);
    if (posa == null) return const Scaffold();

    final contenido = contenidoQrPosa(posa.codigo);

    return Scaffold(
      backgroundColor: C.background,
      appBar: BarraSigCuy(
        titulo: 'Código QR',
        emoji: '🔳',
        conVolver: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.tarjetaBorde),
              ),
              child: CodigoQr(datos: contenido, tamano: 250),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: Text(
              posa.codigo,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: C.primary,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${Repo.i.galponDe(posa)?.nombre ?? ''} · ${posa.categoria.chip}',
              style: const TextStyle(fontSize: 15, color: C.textSecondary),
            ),
          ),
          const SizedBox(height: 26),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contenido del código',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: C.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    contenido,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: contenido));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contenido del QR copiado')),
              );
            },
            icon: const Icon(Icons.copy, size: 20),
            label: const Text('Copiar contenido'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Imprime este código y pégalo en la posa. Al escanearlo con la '
            'app se abre directamente su ficha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: C.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
