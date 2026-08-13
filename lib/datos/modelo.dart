import 'package:flutter/material.dart';
import '../tema.dart';

/// Modelo de datos calcado del proyecto Android (`data/db/entity/`).

enum Categoria { vacia, gazapo, recria, engorde, descarte, reproductoras }

extension CategoriaX on Categoria {
  /// Nombre tal como está en el catálogo de la base de datos.
  String get chip => switch (this) {
    Categoria.vacia => 'VACÍA',
    Categoria.gazapo => 'GAZAPO',
    Categoria.recria => 'RECRÍA',
    Categoria.engorde => 'ENGORDE',
    Categoria.descarte => 'DESCARTE',
    Categoria.reproductoras => 'REPRODUCTORAS',
  };

  String get plural => switch (this) {
    Categoria.vacia => 'Vacía',
    Categoria.gazapo => 'Gazapos',
    Categoria.recria => 'Recría',
    Categoria.engorde => 'Engorde',
    Categoria.descarte => 'Descarte',
    Categoria.reproductoras => 'Reproductoras',
  };

  String get singular => switch (this) {
    Categoria.vacia => 'Vacía',
    Categoria.gazapo => 'Gazapo',
    Categoria.recria => 'Recría',
    Categoria.engorde => 'Engorde',
    Categoria.descarte => 'Descarte',
    Categoria.reproductoras => 'Reproductoras',
  };

  String get emoji => switch (this) {
    Categoria.vacia => '⚪',
    Categoria.gazapo => '🐹',
    Categoria.recria => '📈',
    Categoria.engorde => '⚖️',
    Categoria.descarte => '🚫',
    Categoria.reproductoras => '🌸',
  };

  Color get color => switch (this) {
    Categoria.vacia => C.gray600,
    Categoria.gazapo => C.gazapo,
    Categoria.recria => C.recria,
    Categoria.engorde => C.engorde,
    Categoria.descarte => C.descarte,
    Categoria.reproductoras => C.reproductoras,
  };

  Color get colorChip =>
      this == Categoria.descarte ? C.descarteChip : color;

  static Categoria desde(String s) => Categoria.values.firstWhere(
    (c) => c.chip == s,
    orElse: () => Categoria.vacia,
  );
}

enum TipoActividad { limpieza, desinfeccion, desparasitacion }

extension TipoActividadX on TipoActividad {
  String get etiqueta => switch (this) {
    TipoActividad.limpieza => 'Limpieza',
    TipoActividad.desinfeccion => 'Desinfección',
    TipoActividad.desparasitacion => 'Desparasitación',
  };

  String get emoji => switch (this) {
    TipoActividad.limpieza => '🧹',
    TipoActividad.desinfeccion => '🧴',
    TipoActividad.desparasitacion => '💊',
  };

  Color get color => switch (this) {
    TipoActividad.limpieza => C.azulAccion,
    TipoActividad.desinfeccion => C.engorde,
    TipoActividad.desparasitacion => C.primary,
  };

  Color get tinte => switch (this) {
    TipoActividad.limpieza => C.tinteAzul,
    TipoActividad.desinfeccion => C.tinteVerde,
    TipoActividad.desparasitacion => C.tinteNaranja,
  };
}

enum MotivoSalida { venta, muerte, descarte, traslado, otro }

extension MotivoSalidaX on MotivoSalida {
  String get etiqueta => switch (this) {
    MotivoSalida.venta => 'Venta',
    MotivoSalida.muerte => 'Muerte',
    MotivoSalida.descarte => 'Descarte',
    MotivoSalida.traslado => 'Traslado',
    MotivoSalida.otro => 'Otro',
  };

  String get emoji => switch (this) {
    MotivoSalida.venta => '💰',
    MotivoSalida.muerte => '💀',
    MotivoSalida.descarte => '🚫',
    MotivoSalida.traslado => '🔄',
    MotivoSalida.otro => '📝',
  };
}

enum TipoMovimiento { ingreso, salida, nacimiento, actividad, destete }

class Galpon {
  Galpon({required this.id, required this.letra});

  final int id;
  String letra;

  String get nombre => 'Galpón $letra';

  Map<String, dynamic> aJson() => {'id': id, 'letra': letra};

  static Galpon deJson(Map<String, dynamic> j) =>
      Galpon(id: j['id'] as int, letra: j['letra'] as String);
}

/// Una camada (parto) de la posa. Equivale a la entidad `Nacimiento`.
class Camada {
  Camada({
    required this.id,
    required this.fecha,
    required this.vivas,
    this.mortinatos = 0,
    this.destetada = false,
  });

  final int id;
  final DateTime fecha;
  int vivas;
  final int mortinatos;
  bool destetada;

  int diasDeVida(DateTime hoy) => hoy.difference(fecha).inDays;

  Map<String, dynamic> aJson() => {
    'id': id,
    'fecha': fecha.toIso8601String(),
    'vivas': vivas,
    'mortinatos': mortinatos,
    'destetada': destetada,
  };

  static Camada deJson(Map<String, dynamic> j) => Camada(
    id: j['id'] as int,
    fecha: DateTime.parse(j['fecha'] as String),
    vivas: j['vivas'] as int,
    mortinatos: j['mortinatos'] as int? ?? 0,
    destetada: j['destetada'] as bool? ?? false,
  );
}

class Posa {
  Posa({
    required this.id,
    required this.galponId,
    required this.numero,
    required this.codigo,
    this.categoria = Categoria.vacia,
    this.machos = 0,
    this.hembras = 0,
    this.empadre,
    this.observaciones = '',
    List<Camada>? camadas,
  }) : camadas = camadas ?? [];

  final int id;
  final int galponId;
  final int numero;
  final String codigo;
  Categoria categoria;
  int machos;
  int hembras;
  DateTime? empadre;
  String observaciones;
  List<Camada> camadas;

  int get crias =>
      camadas.where((c) => !c.destetada).fold(0, (s, c) => s + c.vivas);
  int get totalAdultos => machos + hembras;
  int get total => totalAdultos + crias;
  bool get estaVacia => total == 0;
  String get estado => estaVacia ? 'Vacía' : 'Activa';

  Map<String, dynamic> aJson() => {
    'id': id,
    'galponId': galponId,
    'numero': numero,
    'codigo': codigo,
    'categoria': categoria.chip,
    'machos': machos,
    'hembras': hembras,
    'empadre': empadre?.toIso8601String(),
    'observaciones': observaciones,
    'camadas': camadas.map((c) => c.aJson()).toList(),
  };

  static Posa deJson(Map<String, dynamic> j) => Posa(
    id: j['id'] as int,
    galponId: j['galponId'] as int,
    numero: j['numero'] as int,
    codigo: j['codigo'] as String,
    categoria: CategoriaX.desde(j['categoria'] as String? ?? 'VACÍA'),
    machos: j['machos'] as int? ?? 0,
    hembras: j['hembras'] as int? ?? 0,
    empadre: j['empadre'] == null
        ? null
        : DateTime.parse(j['empadre'] as String),
    observaciones: j['observaciones'] as String? ?? '',
    camadas: (j['camadas'] as List? ?? [])
        .map((c) => Camada.deJson(c as Map<String, dynamic>))
        .toList(),
  );
}

class RegistroActividad {
  RegistroActividad({
    required this.id,
    required this.posaId,
    required this.tipo,
    required this.fecha,
  });

  final int id;
  final int posaId;
  final TipoActividad tipo;
  final DateTime fecha;

  Map<String, dynamic> aJson() => {
    'id': id,
    'posaId': posaId,
    'tipo': tipo.name,
    'fecha': fecha.toIso8601String(),
  };

  static RegistroActividad deJson(Map<String, dynamic> j) => RegistroActividad(
    id: j['id'] as int,
    posaId: j['posaId'] as int,
    tipo: TipoActividad.values.byName(j['tipo'] as String),
    fecha: DateTime.parse(j['fecha'] as String),
  );
}

class Movimiento {
  Movimiento({
    required this.id,
    required this.posaId,
    required this.tipo,
    required this.titulo,
    required this.fecha,
    this.machos = 0,
    this.hembras = 0,
    this.crias = 0,
    this.nota = '',
    this.categoriaTexto = '',
  });

  final int id;
  final int posaId;
  final TipoMovimiento tipo;
  final String titulo;
  final DateTime fecha;
  final int machos;
  final int hembras;
  final int crias;
  final String nota;
  final String categoriaTexto;

  Color get color =>
      tipo == TipoMovimiento.salida ? C.descarte : C.primary;

  String get emoji => switch (tipo) {
    TipoMovimiento.actividad => '🧹',
    TipoMovimiento.nacimiento => '🐹',
    TipoMovimiento.destete => '✂️',
    _ => '🔄',
  };

  String get derecha {
    if (crias > 0 && machos == 0 && hembras == 0) return '🐹 $crias crías';
    if (machos == 0 && hembras == 0) return '';
    return '♂$machos ♀$hembras  Total:${machos + hembras}';
  }

  Map<String, dynamic> aJson() => {
    'id': id,
    'posaId': posaId,
    'tipo': tipo.name,
    'titulo': titulo,
    'fecha': fecha.toIso8601String(),
    'machos': machos,
    'hembras': hembras,
    'crias': crias,
    'nota': nota,
    'categoriaTexto': categoriaTexto,
  };

  static Movimiento deJson(Map<String, dynamic> j) => Movimiento(
    id: j['id'] as int,
    posaId: j['posaId'] as int,
    tipo: TipoMovimiento.values.byName(j['tipo'] as String),
    titulo: j['titulo'] as String,
    fecha: DateTime.parse(j['fecha'] as String),
    machos: j['machos'] as int? ?? 0,
    hembras: j['hembras'] as int? ?? 0,
    crias: j['crias'] as int? ?? 0,
    nota: j['nota'] as String? ?? '',
    categoriaTexto: j['categoriaTexto'] as String? ?? '',
  );
}

/// Valores por defecto tomados de `Configuracion.kt`.
class Configuracion {
  Configuracion({
    this.diasGestacion = 67,
    this.diasDestete = 15,
    this.diasLimpieza = 30,
    this.diasDesinfeccion = 15,
    this.diasDesparasitacion = 90,
    this.reEmpadreAutomatico = true,
  });

  int diasGestacion;
  int diasDestete;
  int diasLimpieza;
  int diasDesinfeccion;
  int diasDesparasitacion;
  bool reEmpadreAutomatico;

  int intervalo(TipoActividad t) => switch (t) {
    TipoActividad.limpieza => diasLimpieza,
    TipoActividad.desinfeccion => diasDesinfeccion,
    TipoActividad.desparasitacion => diasDesparasitacion,
  };

  Map<String, dynamic> aJson() => {
    'diasGestacion': diasGestacion,
    'diasDestete': diasDestete,
    'diasLimpieza': diasLimpieza,
    'diasDesinfeccion': diasDesinfeccion,
    'diasDesparasitacion': diasDesparasitacion,
    'reEmpadreAutomatico': reEmpadreAutomatico,
  };

  static Configuracion deJson(Map<String, dynamic> j) => Configuracion(
    diasGestacion: j['diasGestacion'] as int? ?? 67,
    diasDestete: j['diasDestete'] as int? ?? 15,
    diasLimpieza: j['diasLimpieza'] as int? ?? 30,
    diasDesinfeccion: j['diasDesinfeccion'] as int? ?? 15,
    diasDesparasitacion: j['diasDesparasitacion'] as int? ?? 90,
    reEmpadreAutomatico: j['reEmpadreAutomatico'] as bool? ?? true,
  );
}

/// Aviso calculado en el momento, igual que `RevisionRecordatorios.ejecutar()`.
class Aviso {
  const Aviso({
    required this.titulo,
    required this.detalle,
    required this.fecha,
  });

  final String titulo;
  final String detalle;
  final DateTime fecha;
}

// ── Utilidades de fecha ──

String fechaCorta(DateTime d) =>
    '${_dd(d.day)}/${_dd(d.month)}/${d.year}';

String fechaHora(DateTime d) =>
    '${fechaCorta(d)} ${_dd(d.hour)}:${_dd(d.minute)}';

String _dd(int n) => n.toString().padLeft(2, '0');
