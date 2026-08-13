import 'package:flutter/material.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import 'dashboard.dart';
import 'galpones.dart';
import 'indicadores.dart';
import 'perfil.dart';
import 'qr_scanner.dart';

/// Permite saltar a otra pestaña desde cualquier punto de la app.
void irAPestana(BuildContext context, int indice) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => Shell(indiceInicial: indice)),
    (_) => false,
  );
}

/// Contenedor principal: cuatro pestañas y el FAB cuadrado del escáner.
class Shell extends StatefulWidget {
  const Shell({super.key, this.indiceInicial = 0});

  final int indiceInicial;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late int _indice = widget.indiceInicial;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Repo.i,
      builder: (context, _) => Scaffold(
        backgroundColor: C.background,
        extendBody: true,
        // Ojo: estos hijos NO pueden ser `const`. Los widgets constantes se
        // reutilizan como la misma instancia, y entonces Flutter da el
        // subárbol por igual y no lo reconstruye — que es justo lo que hacía
        // que los datos nuevos no aparecieran en pantalla.
        // ignore: prefer_const_constructors
        body: IndexedStack(
          index: _indice,
          children: [
            // ignore: prefer_const_constructors
            DashboardPantalla(),
            // ignore: prefer_const_constructors
            GalponesPantalla(),
            // ignore: prefer_const_constructors
            IndicadoresPantalla(),
            // ignore: prefer_const_constructors
            PerfilPantalla(),
          ],
        ),
        bottomNavigationBar: BarraInferior(
          indice: _indice,
          onTap: (i) => setState(() => _indice = i),
        ),
      ),
    );
  }
}

/// Barra inferior blanca con el botón cuadrado del escáner al centro.
class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key, required this.indice, this.onTap});

  final int indice;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final abajo = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 64 + abajo,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 64 + abajo,
            color: Colors.white,
            padding: EdgeInsets.only(bottom: abajo),
            child: Row(
              children: [
                Expanded(
                  child: _Tab(
                    icono: Icons.home_outlined,
                    iconoActivo: Icons.home,
                    etiqueta: 'Inicio',
                    activo: indice == 0,
                    onTap: () => _ir(context, 0),
                  ),
                ),
                Expanded(
                  child: _Tab(
                    icono: Icons.grid_view_outlined,
                    iconoActivo: Icons.grid_view_rounded,
                    etiqueta: 'Posas',
                    activo: indice == 1,
                    onTap: () => _ir(context, 1),
                  ),
                ),
                const SizedBox(width: 64),
                Expanded(
                  child: _Tab(
                    icono: Icons.bar_chart,
                    iconoActivo: Icons.bar_chart,
                    etiqueta: 'Indicadores',
                    activo: indice == 2,
                    onTap: () => _ir(context, 2),
                  ),
                ),
                Expanded(
                  child: _Tab(
                    icono: Icons.person_outline,
                    iconoActivo: Icons.person,
                    etiqueta: 'Perfil',
                    activo: indice == 3,
                    onTap: () => _ir(context, 3),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -22,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QrScannerPantalla(),
                  ),
                ),
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: C.orange900.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _ir(BuildContext context, int i) {
    if (onTap != null) {
      onTap!(i);
    } else {
      irAPestana(context, i);
    }
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activo ? C.primary : const Color(0xFF6E6E73);

    return InkResponse(
      onTap: onTap,
      radius: 42,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(activo ? iconoActivo : icono, size: 25, color: color),
          const SizedBox(height: 3),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
