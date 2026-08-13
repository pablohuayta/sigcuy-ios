import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../tema.dart';

/// Campo con etiqueta flotante recortando el borde, como en los formularios
/// de la app Android.
class CampoEtiquetado extends StatelessWidget {
  const CampoEtiquetado({
    super.key,
    required this.etiqueta,
    this.valor,
    this.placeholder,
  });

  final String etiqueta;
  final String? valor;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valor,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: placeholder,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: C.gray600, fontSize: 15),
      ),
    );
  }
}

/// Campo sin etiqueta, solo con texto de ayuda.
class CampoSimple extends StatelessWidget {
  const CampoSimple({
    super.key,
    required this.placeholder,
    this.valor,
    this.sufijo,
  });

  final String placeholder;
  final String? valor;
  final String? sufijo;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valor,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(hintText: placeholder, suffixText: sufijo),
    );
  }
}

/// Chip de opción con borde, usado en los selectores de motivo y origen.
class ChipOpcion extends StatelessWidget {
  const ChipOpcion({
    super.key,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: activo ? C.orange50 : Colors.transparent,
          border: Border.all(
            color: activo ? C.primary : const Color(0xFFBDBDBD),
            width: activo ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            color: activo ? C.primaryDark : C.onSurface,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Campo numérico con etiqueta flotante.
///
/// Al tocarlo selecciona todo el contenido, para que escribir "12" sobre un
/// "0" no acabe en "012".
class CampoNumero extends StatelessWidget {
  const CampoNumero({
    super.key,
    required this.etiqueta,
    required this.control,
    this.onChanged,
  });

  final String etiqueta;
  final TextEditingController control;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: control,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 17),
      onTap: () => control.selection = TextSelection(
        baseOffset: 0,
        extentOffset: control.text.length,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: etiqueta,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(color: C.gray600, fontSize: 15),
      ),
    );
  }
}

/// Tarjeta "Categoría de la posa" con la llave para cambiarla.
class SelectorCategoria extends StatelessWidget {
  const SelectorCategoria({super.key, required this.posa});

  final Posa posa;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => elegirCategoria(context, posa),
      child: TarjetaTinte(
        color: C.tinteNaranja,
        borde: const Color(0xFFF0DCC2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        hijo: Row(
          children: [
            const Text(
              'Categoría de la posa: ',
              style: TextStyle(fontSize: 15, color: C.textSecondary),
            ),
            Expanded(
              child: Text(
                posa.categoria.chip,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: posa.categoria.color,
                ),
              ),
            ),
            const Text('🔧', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

/// Hoja para elegir la categoría de una posa.
Future<void> elegirCategoria(BuildContext context, Posa posa) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: C.hoja,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: EdgeInsets.only(
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD8D8D8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 18, 22, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categoría de la posa',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Define qué tipo de cuys viven en esta posa.',
                style: TextStyle(fontSize: 14.5, color: C.textSecondary),
              ),
            ),
          ),
          for (final cat in Categoria.values)
            ListTile(
              onTap: () async {
                await Repo.i.cambiarCategoria(posa, cat);
                if (context.mounted) Navigator.of(context).pop();
              },
              leading: Text(
                cat.emoji,
                style: const TextStyle(fontSize: 22),
              ),
              title: Text(
                cat.chip,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cat.color,
                ),
              ),
              trailing: posa.categoria == cat
                  ? const Icon(Icons.check_circle, color: C.primary)
                  : null,
            ),
        ],
      ),
    ),
  );
}

/// Tarjeta de color suave usada dentro de las hojas modales.
class TarjetaTinte extends StatelessWidget {
  const TarjetaTinte({
    super.key,
    required this.color,
    required this.hijo,
    this.borde,
    this.padding = const EdgeInsets.all(14),
  });

  final Color color;
  final Color? borde;
  final Widget hijo;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borde ?? const Color(0x22000000)),
      ),
      child: hijo,
    );
  }
}
