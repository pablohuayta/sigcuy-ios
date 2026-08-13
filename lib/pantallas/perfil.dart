import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../datos/modelo.dart';
import '../datos/repositorio.dart';
import '../hojas/hoja_config_notificaciones.dart';
import '../tema.dart';
import 'login.dart';

/// Pestaña "Perfil".
class PerfilPantalla extends StatelessWidget {
  const PerfilPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Repo.i;
    final invitado = repo.modo == ModoSesion.invitado;
    final inicial = invitado
        ? 'I'
        : (repo.correo?.isNotEmpty == true
              ? repo.correo![0].toUpperCase()
              : 'A');

    return Scaffold(
      backgroundColor: C.background,
      appBar: const BarraSigCuy(titulo: 'Perfil', emoji: '👤'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: C.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                inicial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              invitado ? 'Invitado' : (repo.correo ?? 'Administrador'),
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 3),
          const Center(
            child: Text(
              'SigCuy — Gestión de Cuys',
              style: TextStyle(fontSize: 14, color: C.textSecondary),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🐾 Versión 1.0', style: TextStyle(fontSize: 14.5)),
                  SizedBox(height: 6),
                  Text(
                    '🌱 SigCuy — Sistema de gestión administrativa de cuyes',
                    style: TextStyle(fontSize: 14.5, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => mostrarHojaConfigNotificaciones(context),
            child: const Text('🔧 ⚙️  Configuración de notificaciones'),
          ),
          const SizedBox(height: 22),
          const _Etiqueta('Copia de seguridad'),
          const SizedBox(height: 10),
          _boton('⬆️  Exportar copia de seguridad', () => _exportar(context)),
          const SizedBox(height: 10),
          _boton('⬇️  Restaurar copia de seguridad', () => _importar(context)),
          const SizedBox(height: 10),
          const Text(
            'Guarda el archivo en tu Drive, correo o WhatsApp para no perder '
            'tus datos si cambias de celular.',
            style: TextStyle(fontSize: 13, color: C.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 22),
          const _Etiqueta('Respaldo automático en Google Drive'),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: invitado
                  ? const Text(
                      'Sin vincular. Estás usando la app como invitado: los '
                      'datos se guardan solo en este dispositivo.',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vinculado: ${repo.correo}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Último respaldo: —',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          if (invitado)
            ElevatedButton(
              onPressed: () => _cerrarSesion(context),
              child: const Text('🔗  Vincular una cuenta de Google'),
            )
          else ...[
            ElevatedButton(
              onPressed: () {},
              child: const Text('🔗  Re-vincular cuenta'),
            ),
            const SizedBox(height: 10),
            _boton('☁️  Respaldar en Drive ahora', () {}),
          ],
          const SizedBox(height: 22),
          const _Etiqueta('Zona de riesgo'),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _borrarTodo(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: C.descarte,
              side: const BorderSide(color: Color(0xFFEF9A9A)),
            ),
            child: const Text('🗑  Borrar todos los datos'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _cerrarSesion(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: C.descarte,
              side: const BorderSide(color: Color(0xFFEF9A9A)),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _boton(String texto, VoidCallback onTap) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: C.primary,
      side: const BorderSide(color: C.primary),
    ),
    child: Text(texto),
  );

  /// Muestra el JSON para copiarlo. Equivale a "Exportar copia de seguridad".
  Future<void> _exportar(BuildContext context) async {
    final texto = Repo.i.exportarJson();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Copia de seguridad'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              texto,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: texto));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Copiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Pega un JSON para restaurar. Sirve para cargar datos de prueba.
  Future<void> _importar(BuildContext context) async {
    final control = TextEditingController();

    final texto = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Restaurar copia'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pega aquí el contenido del archivo JSON de respaldo. '
                'Reemplazará los datos actuales de esta cuenta.',
                style: TextStyle(fontSize: 13, color: C.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: control,
                maxLines: 8,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: const InputDecoration(hintText: '{ ... }'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(control.text),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (texto == null || texto.trim().isEmpty) return;
    final error = await Repo.i.importarJson(texto);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Copia restaurada correctamente')),
    );
  }

  Future<void> _borrarTodo(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Borrar todos los datos'),
        content: const Text(
          'Se eliminarán galpones, posas, actividades y movimientos de esta '
          'cuenta. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar', style: TextStyle(color: C.descarte)),
          ),
        ],
      ),
    );
    if (ok == true) await Repo.i.borrarTodo();
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    await Repo.i.cerrarSesion();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPantalla()),
      (_) => false,
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: C.textSecondary,
    ),
  );
}
