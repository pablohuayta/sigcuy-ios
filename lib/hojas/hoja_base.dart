import 'package:flutter/material.dart';
import '../tema.dart';

/// Cuerpo común de las hojas modales inferiores.
///
/// Reproduce los `BottomSheetDialogFragment` de la app Android: esquinas
/// superiores redondeadas, fondo lila muy claro, título con X para cerrar y
/// los botones al final.
class HojaContenedor extends StatelessWidget {
  const HojaContenedor({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.contenido,
    this.botonPrincipal,
    this.textoCancelar = 'Cancelar',
    this.conCerrar = true,
    this.conAsa = false,
  });

  final String titulo;
  final String? subtitulo;
  final List<Widget> contenido;
  final Widget? botonPrincipal;
  final String textoCancelar;
  final bool conCerrar;
  final bool conAsa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: C.hoja,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (conAsa) ...[
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D8D8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(22, conAsa ? 18 : 24, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (conCerrar)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Icon(Icons.close, color: C.gray600, size: 28),
                      ),
                    ),
                ],
              ),
            ),
            if (subtitulo != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: C.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                children: contenido,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                18,
                22,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  if (botonPrincipal != null) ...[
                    SizedBox(width: double.infinity, child: botonPrincipal),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(textoCancelar),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atajo para hojas que no necesitan estado propio.
Future<void> mostrarHoja(
  BuildContext context, {
  required String titulo,
  String? subtitulo,
  required List<Widget> contenido,
  Widget? botonPrincipal,
  String textoCancelar = 'Cancelar',
  bool conCerrar = true,
  bool conAsa = false,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => HojaContenedor(
      titulo: titulo,
      subtitulo: subtitulo,
      contenido: contenido,
      botonPrincipal: botonPrincipal,
      textoCancelar: textoCancelar,
      conCerrar: conCerrar,
      conAsa: conAsa,
    ),
  );
}
