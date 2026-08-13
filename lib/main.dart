import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'pantallas/login.dart';
import 'tema.dart';

/// Prototipo de interfaz de SigCuy para iOS.
///
/// No es la aplicación de producción: no hay base de datos, ni recordatorios
/// en segundo plano, ni respaldo en Drive. Reproduce la interfaz y el flujo de
/// navegación del sistema Android para su revisión en un dispositivo iOS.
///
/// El selector de dispositivos de la derecha lo aporta `device_preview`:
/// permite elegir el modelo de iPhone, rotarlo, cambiar a modo oscuro y
/// tomar capturas.
void main() => runApp(
  DevicePreview(enabled: true, builder: (context) => const AppSigCuy()),
);

class AppSigCuy extends StatelessWidget {
  const AppSigCuy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SigCuy',
      debugShowCheckedModeBanner: false,
      theme: temaSigCuy(),
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const LoginPantalla(),
    );
  }
}
