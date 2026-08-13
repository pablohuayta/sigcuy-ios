import 'package:flutter/material.dart';
import '../datos/repositorio.dart';
import '../tema.dart';
import 'shell.dart';

/// Pantalla de inicio de sesión.
///
/// Réplica de `LoginActivity.kt` más la opción de entrar como invitado:
///
///  - **Con Google**: los datos quedan asociados a esa cuenta y se respaldan
///    en su Drive. Entrar con otra cuenta muestra una granja vacía sin pisar
///    la anterior, igual que hace `CuentaBase` en Android.
///  - **Como invitado**: los datos se guardan solo en el dispositivo, sin
///    respaldo en la nube.
class LoginPantalla extends StatelessWidget {
  const LoginPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 104,
                  height: 104,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.orange50,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: C.orange200, width: 2),
                  ),
                  child: const Text('🐹', style: TextStyle(fontSize: 52)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SigCuy',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: C.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Gestión administrativa de cuyes',
                  style: TextStyle(fontSize: 15, color: C.textSecondary),
                ),
              ),
              const Spacer(),
              const Text(
                '¡Hola de nuevo! 👋',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu granja te espera. Ingresa con tu cuenta\n'
                'para ver tus posas y recordatorios.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: C.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _entrar(context, ModoSesion.google),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Iniciar sesión con Google'),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => _entrar(context, ModoSesion.invitado),
                style: OutlinedButton.styleFrom(
                  foregroundColor: C.primary,
                  side: const BorderSide(color: C.primary),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Continuar como invitado'),
              ),
              const SizedBox(height: 14),
              const Text(
                'Como invitado tus datos se guardan solo en este\n'
                'dispositivo, sin respaldo en Drive.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: C.gray600,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 15, color: C.gray600),
                  SizedBox(width: 6),
                  Text(
                    'Tus datos se guardan solo en tu teléfono',
                    style: TextStyle(fontSize: 12.5, color: C.gray600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Solo la primera vez necesitas internet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: C.gray600),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _entrar(BuildContext context, ModoSesion modo) async {
    String? correo;

    if (modo == ModoSesion.google) {
      correo = await _pedirCuenta(context);
      if (correo == null) return;
    }

    await Repo.i.iniciarSesion(modo, email: correo);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Shell()),
      (_) => false,
    );
  }

  /// Simula el selector de cuentas de Google. En la app Android esto lo
  /// resuelve `GoogleSignIn`; aquí basta con elegir un correo para que cada
  /// cuenta tenga su propio almacén.
  Future<String?> _pedirCuenta(BuildContext context) {
    final control = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Elegir cuenta',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cada cuenta tiene sus propios datos. Entrar con otra cuenta '
              'muestra una granja vacía y no toca la anterior.',
              style: TextStyle(fontSize: 13.5, color: C.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: control,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'correo@gmail.com',
                prefixIcon: Icon(Icons.account_circle_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final v = control.text.trim();
              Navigator.of(context).pop(v.isEmpty ? 'cuenta@gmail.com' : v);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
