import 'package:flutter/material.dart';

/// Paleta tomada de `res/values/colors.xml` y ajustada contra las capturas
/// reales de la aplicación Android.
class C {
  // Naranja principal
  static const primary = Color(0xFFF57C00);
  static const primaryDark = Color(0xFFE65100);
  static const appBar = Color(0xFFEF6C00);
  static const onPrimary = Color(0xFFFFFFFF);

  static const orange50 = Color(0xFFFFF3E0);
  static const orange100 = Color(0xFFFFE0B2);
  static const orange200 = Color(0xFFFFCC80);
  static const orange400 = Color(0xFFFFA726);
  static const orange500 = Color(0xFFFF9800);
  static const orange700 = Color(0xFFF57C00);
  static const orange900 = Color(0xFFE65100);

  // Fondos
  static const background = Color(0xFFFFFBF5);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1C1B1F);

  /// Relleno crema de las tarjetas. En las capturas las tarjetas no son
  /// blancas: tienen un tinte durazno muy suave.
  static const tarjeta = Color(0xFFFDF5EC);
  static const tarjetaBorde = Color(0xFFF3E7DA);

  /// Fondo de las hojas modales inferiores (lila muy claro).
  static const hoja = Color(0xFFF9F5FA);

  // Categorías
  static const gazapo = Color(0xFFF57C00);
  static const recria = Color(0xFF1976D2);
  static const engorde = Color(0xFF2E7D32);
  static const descarte = Color(0xFFC62828);
  static const descarteChip = Color(0xFFB71C1C);
  static const reproductoras = Color(0xFFAD1457);

  // Género
  static const macho = Color(0xFF1565C0);
  static const hembra = Color(0xFFAD1457);

  // Neutros
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray600 = Color(0xFF757575);
  static const divider = Color(0xFFE0E0E0);
  static const textSecondary = Color(0xFF757575);

  // Tintes de los accesos rápidos del Dashboard
  static const tinteNaranja = Color(0xFFFFF0DC);
  static const tinteAzul = Color(0xFFE3F2FD);
  static const tinteRojo = Color(0xFFFFEBEE);
  static const tinteAmarillo = Color(0xFFFFFBE6);
  static const tinteVerde = Color(0xFFE8F5E9);

  static const azulAccion = Color(0xFF1976D2);
  static const rojoAccion = Color(0xFFE53935);
  static const amarilloAccion = Color(0xFFF9A825);
  static const verdeNotif = Color(0xFF22A65B);
}

ThemeData temaSigCuy() {
  final base = ThemeData(
    useMaterial3: true,
    // Física de scroll y transiciones de página propias de iOS.
    platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.primary,
      primary: C.primary,
      onPrimary: C.onPrimary,
      surface: C.surface,
      onSurface: C.onSurface,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: C.background,
  );

  return base.copyWith(
    cardTheme: CardThemeData(
      color: C.tarjeta,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.tarjetaBorde),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: C.divider, thickness: 1),
    textTheme: base.textTheme.apply(
      bodyColor: C.onSurface,
      displayColor: C.onSurface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: C.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: C.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFBDBDBD)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
      floatingLabelStyle: const TextStyle(color: C.gray600, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: C.primary, width: 2),
      ),
    ),
  );
}

/// Barra superior naranja con título en blanco, como en toda la app.
class BarraSigCuy extends StatelessWidget implements PreferredSizeWidget {
  const BarraSigCuy({
    super.key,
    required this.titulo,
    this.emoji,
    this.subtitulo,
    this.acciones,
    this.conVolver = false,
  });

  final String titulo;
  final String? emoji;
  final String? subtitulo;
  final List<Widget>? acciones;
  final bool conVolver;

  @override
  Size get preferredSize => Size.fromHeight(subtitulo == null ? 56 : 68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: C.appBar,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: conVolver ? 0 : 20,
      leading: conVolver
          ? IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.skip_previous, size: 26),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji == null ? titulo : '$emoji  $titulo',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitulo != null)
            Text(
              subtitulo!,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xCCFFFFFF),
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
      actions: acciones,
    );
  }
}
