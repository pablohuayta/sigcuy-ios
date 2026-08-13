import 'package:flutter/material.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import '../widgets/campos.dart';
import 'hoja_base.dart';

/// Hoja "Registrar Actividad": tres tarjetas de color, una por tipo.
Future<void> mostrarHojaActividad(BuildContext context, Posa posa) {
  final repo = Repo.i;

  return mostrarHoja(
    context,
    titulo: '🧹 Registrar Actividad',
    subtitulo:
        'Toca la actividad realizada. Se guarda la fecha e inicia el '
        'contador para avisarte la próxima vez.',
    contenido: [
      for (final t in TipoActividad.values) ...[
        Builder(
          builder: (context) {
            final ultima = repo.ultimaActividad(posa.id, t);
            return GestureDetector(
              onTap: () async {
                await repo.registrarActividad(posa, t);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: TarjetaTinte(
                color: t.tinte,
                borde: t.color.withValues(alpha: 0.25),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                hijo: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.emoji} ${t.etiqueta}',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: t.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cada ${repo.config.intervalo(t)} días · Última: '
                      '${ultima == null ? 'nunca' : fechaCorta(ultima)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: C.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
      ],
    ],
  );
}
