import 'package:flutter/material.dart';
import '../tema.dart';

/// Estado vacío, como el `layoutEmpty` de `fragment_galpones.xml`.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.mensaje,
  });

  final String emoji;
  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 54)),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: C.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
