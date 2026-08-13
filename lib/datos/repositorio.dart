import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'modelo.dart';

/// Estado de la sesión. Cada cuenta tiene su propio almacén, igual que
/// `CuentaBase.kt` en Android: entrar con otra cuenta muestra una granja
/// vacía y nunca pisa los datos de la anterior.
enum ModoSesion { ninguna, google, invitado }

/// Fuente única de datos de la aplicación.
///
/// Sustituye a Room: guarda todo en `shared_preferences` como un único JSON
/// por cuenta. La lógica de negocio (traslados, destete, avisos, indicadores)
/// replica la de `PosaRepository.kt` y `RevisionRecordatorios.kt`.
class Repo extends ChangeNotifier {
  Repo._();
  static final Repo i = Repo._();

  ModoSesion modo = ModoSesion.ninguna;
  String? correo;

  List<Galpon> galpones = [];
  List<Posa> posas = [];
  List<RegistroActividad> actividades = [];
  List<Movimiento> movimientos = [];
  Configuracion config = Configuracion();

  int _secuencia = 1;
  int _nuevoId() => _secuencia++;

  SharedPreferences? _prefs;

  String get _clave => switch (modo) {
    ModoSesion.google => 'sigcuy_${correo ?? 'google'}',
    ModoSesion.invitado => 'sigcuy_invitado',
    ModoSesion.ninguna => 'sigcuy_ninguna',
  };

  // ─────────────────────────── Sesión ───────────────────────────

  Future<void> iniciarSesion(ModoSesion nuevoModo, {String? email}) async {
    modo = nuevoModo;
    correo = email;
    _prefs ??= await SharedPreferences.getInstance();
    await _cargar();
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _guardar();
    modo = ModoSesion.ninguna;
    correo = null;
    galpones = [];
    posas = [];
    actividades = [];
    movimientos = [];
    config = Configuracion();
    _secuencia = 1;
    notifyListeners();
  }

  bool get vacio => galpones.isEmpty;

  // ────────────────────────── Persistencia ──────────────────────────

  Future<void> _cargar() async {
    final crudo = _prefs?.getString(_clave);
    if (crudo == null || crudo.isEmpty) {
      galpones = [];
      posas = [];
      actividades = [];
      movimientos = [];
      config = Configuracion();
      _secuencia = 1;
      return;
    }
    _aplicarJson(jsonDecode(crudo) as Map<String, dynamic>);
  }

  Future<void> _guardar() async {
    if (modo == ModoSesion.ninguna) return;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_clave, jsonEncode(aJson()));
  }

  Map<String, dynamic> aJson() => {
    'version': 1,
    'secuencia': _secuencia,
    'config': config.aJson(),
    'galpones': galpones.map((g) => g.aJson()).toList(),
    'posas': posas.map((p) => p.aJson()).toList(),
    'actividades': actividades.map((a) => a.aJson()).toList(),
    'movimientos': movimientos.map((m) => m.aJson()).toList(),
  };

  void _aplicarJson(Map<String, dynamic> j) {
    _secuencia = j['secuencia'] as int? ?? 1;
    config = Configuracion.deJson(
      (j['config'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    galpones = (j['galpones'] as List? ?? [])
        .map((g) => Galpon.deJson((g as Map).cast<String, dynamic>()))
        .toList();
    posas = (j['posas'] as List? ?? [])
        .map((p) => Posa.deJson((p as Map).cast<String, dynamic>()))
        .toList();
    actividades = (j['actividades'] as List? ?? [])
        .map((a) => RegistroActividad.deJson((a as Map).cast<String, dynamic>()))
        .toList();
    movimientos = (j['movimientos'] as List? ?? [])
        .map((m) => Movimiento.deJson((m as Map).cast<String, dynamic>()))
        .toList();
    // Por si el JSON importado trae ids mayores que la secuencia guardada.
    final ids = [
      ...galpones.map((g) => g.id),
      ...posas.map((p) => p.id),
      ...actividades.map((a) => a.id),
      ...movimientos.map((m) => m.id),
    ];
    if (ids.isNotEmpty) {
      final maximo = ids.reduce((a, b) => a > b ? a : b);
      if (maximo >= _secuencia) _secuencia = maximo + 1;
    }
  }

  /// Copia de seguridad en texto, equivalente a "Exportar copia de seguridad".
  String exportarJson() => const JsonEncoder.withIndent('  ').convert(aJson());

  /// Restaura desde un JSON. Devuelve null si todo fue bien, o el error.
  Future<String?> importarJson(String texto) async {
    try {
      final j = jsonDecode(texto);
      if (j is! Map<String, dynamic>) return 'El archivo no tiene el formato esperado.';
      _aplicarJson(j);
      await _guardar();
      notifyListeners();
      return null;
    } catch (e) {
      return 'No se pudo leer el archivo: $e';
    }
  }

  Future<void> borrarTodo() async {
    galpones = [];
    posas = [];
    actividades = [];
    movimientos = [];
    _secuencia = 1;
    await _guardar();
    notifyListeners();
  }

  // ─────────────────────────── Galpones ───────────────────────────

  List<Posa> posasDe(int galponId) =>
      posas.where((p) => p.galponId == galponId).toList()
        ..sort((a, b) => a.numero.compareTo(b.numero));

  int activasDe(int galponId) =>
      posasDe(galponId).where((p) => !p.estaVacia).length;

  int vaciasDe(int galponId) =>
      posasDe(galponId).where((p) => p.estaVacia).length;

  /// Crea el galpón si no existe y genera las posas del rango indicado.
  /// Las que ya existan se omiten, igual que en la app original.
  Future<int> generarPosas(String letra, int desde, int hasta) async {
    final clave = letra.trim().toUpperCase();
    if (clave.isEmpty || desde < 1 || hasta < desde) return 0;

    var galpon = galpones.where((g) => g.letra == clave).firstOrNull;
    if (galpon == null) {
      galpon = Galpon(id: _nuevoId(), letra: clave);
      galpones.add(galpon);
      galpones.sort((a, b) => a.letra.compareTo(b.letra));
    }

    var creadas = 0;
    for (var n = desde; n <= hasta; n++) {
      final codigo = '$clave$n';
      if (posas.any((p) => p.codigo == codigo)) continue;
      posas.add(
        Posa(
          id: _nuevoId(),
          galponId: galpon.id,
          numero: n,
          codigo: codigo,
        ),
      );
      creadas++;
    }
    await _guardar();
    notifyListeners();
    return creadas;
  }

  Future<void> eliminarGalpon(int galponId) async {
    final ids = posasDe(galponId).map((p) => p.id).toSet();
    posas.removeWhere((p) => p.galponId == galponId);
    actividades.removeWhere((a) => ids.contains(a.posaId));
    movimientos.removeWhere((m) => ids.contains(m.posaId));
    galpones.removeWhere((g) => g.id == galponId);
    await _guardar();
    notifyListeners();
  }

  Future<void> eliminarPosa(int posaId) async {
    posas.removeWhere((p) => p.id == posaId);
    actividades.removeWhere((a) => a.posaId == posaId);
    movimientos.removeWhere((m) => m.posaId == posaId);
    await _guardar();
    notifyListeners();
  }

  Galpon? galponDe(Posa p) =>
      galpones.where((g) => g.id == p.galponId).firstOrNull;

  Posa? posaPorCodigo(String codigo) =>
      posas.where((p) => p.codigo == codigo).firstOrNull;

  Posa? posaPorId(int id) => posas.where((p) => p.id == id).firstOrNull;

  // ─────────────────────────── Movimientos ───────────────────────────

  Future<void> agregarCuys(
    Posa posa, {
    required int machos,
    required int hembras,
    required bool porNacimiento,
    String nota = '',
  }) async {
    if (machos <= 0 && hembras <= 0) return;
    posa.machos += machos;
    posa.hembras += hembras;
    if (posa.categoria == Categoria.vacia) {
      posa.categoria = Categoria.recria;
    }
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.ingreso,
        titulo: porNacimiento ? 'Ingreso · Nacimiento' : 'Ingreso · Traslado',
        fecha: DateTime.now(),
        machos: machos,
        hembras: hembras,
        nota: nota,
        categoriaTexto: posa.categoria.chip,
      ),
    );
    _abrirEmpadreSiCorresponde(posa);
    await _guardar();
    notifyListeners();
  }

  /// Abre el ciclo reproductivo automáticamente cuando en una posa de
  /// reproductoras quedan machos y hembras juntos y no hay empadre en curso.
  ///
  /// Es lo que hace `PosaRepository.registrarIngreso()` al final: si la
  /// categoría es REPRODUCTORAS y hay ambos sexos, inserta un `Empadre` con
  /// la fecha del momento. Sin eso no se puede registrar ningún parto.
  void _abrirEmpadreSiCorresponde(Posa posa) {
    if (posa.categoria != Categoria.reproductoras) return;
    if (posa.machos <= 0 || posa.hembras <= 0) return;
    posa.empadre ??= DateTime.now();
  }

  Future<void> registrarSalida(
    Posa posa, {
    required int machos,
    required int hembras,
    required MotivoSalida motivo,
    String nota = '',
  }) async {
    if (machos <= 0 && hembras <= 0) return;
    posa.machos = (posa.machos - machos).clamp(0, 1 << 30);
    posa.hembras = (posa.hembras - hembras).clamp(0, 1 << 30);
    if (posa.estaVacia) posa.categoria = Categoria.vacia;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.salida,
        titulo: 'Salida · ${motivo.etiqueta}',
        fecha: DateTime.now(),
        machos: machos,
        hembras: hembras,
        nota: nota,
        categoriaTexto: posa.categoria.chip,
      ),
    );
    await _guardar();
    notifyListeners();
  }

  Future<void> vaciarPosa(Posa posa) async {
    final m = posa.machos, h = posa.hembras;
    posa.machos = 0;
    posa.hembras = 0;
    posa.camadas.clear();
    posa.categoria = Categoria.vacia;
    posa.empadre = null;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.salida,
        titulo: 'Salida · Vaciado',
        fecha: DateTime.now(),
        machos: m,
        hembras: h,
      ),
    );
    await _guardar();
    notifyListeners();
  }

  Future<void> cambiarCategoria(Posa posa, Categoria nueva) async {
    posa.categoria = nueva;
    _abrirEmpadreSiCorresponde(posa);
    await _guardar();
    notifyListeners();
  }

  /// Traslada animales de una posa a otra, como `registrarTraslado()`.
  ///
  /// Escribe la salida en el origen y la entrada en el destino. Si el destino
  /// estaba vacío hereda la categoría del origen; si el origen queda en cero
  /// pasa a VACÍA y se cierra su ciclo reproductivo.
  Future<String?> registrarTraslado(
    Posa origen,
    Posa destino, {
    required int machos,
    required int hembras,
    String nota = '',
  }) async {
    if (origen.id == destino.id) return 'El origen y el destino son la misma posa.';
    if (machos <= 0 && hembras <= 0) return 'Indica cuántos cuys vas a trasladar.';
    if (machos > origen.machos || hembras > origen.hembras) {
      return 'La posa ${origen.codigo} solo tiene ♂${origen.machos} ♀${origen.hembras}.';
    }

    final ahora = DateTime.now();

    origen.machos -= machos;
    origen.hembras -= hembras;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: origen.id,
        tipo: TipoMovimiento.salida,
        titulo: 'Salida · Traslado',
        fecha: ahora,
        machos: machos,
        hembras: hembras,
        nota: nota.isEmpty ? 'Traslado a ${destino.codigo}' : nota,
        categoriaTexto: origen.categoria.chip,
      ),
    );

    if (destino.categoria == Categoria.vacia) {
      destino.categoria = origen.categoria;
    }
    destino.machos += machos;
    destino.hembras += hembras;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: destino.id,
        tipo: TipoMovimiento.ingreso,
        titulo: 'Ingreso · Traslado',
        fecha: ahora,
        machos: machos,
        hembras: hembras,
        nota: nota.isEmpty ? 'Traslado desde ${origen.codigo}' : nota,
        categoriaTexto: destino.categoria.chip,
      ),
    );

    _abrirEmpadreSiCorresponde(destino);

    if (origen.estaVacia) {
      origen.categoria = Categoria.vacia;
      origen.empadre = null;
    }

    await _guardar();
    notifyListeners();
    return null;
  }

  /// Posas a las que se puede trasladar (todas menos la de origen).
  List<Posa> posasDestino(int exceptoId) {
    final lista = posas.where((p) => p.id != exceptoId).toList();
    lista.sort((a, b) => a.codigo.compareTo(b.codigo));
    return lista;
  }

  Future<void> registrarEmpadre(Posa posa, DateTime fecha) async {
    posa.empadre = fecha;
    posa.categoria = Categoria.reproductoras;
    await _guardar();
    notifyListeners();
  }

  // ── Ciclo reproductivo ──

  /// Fecha del último destete de la posa. Marca el inicio del ciclo actual:
  /// `NacimientoDao.contarEnCiclo` cuenta los partos posteriores a ella.
  DateTime? _ultimoDestete(int posaId) {
    final lista = movimientos
        .where((m) => m.posaId == posaId && m.tipo == TipoMovimiento.destete)
        .toList();
    if (lista.isEmpty) return null;
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista.first.fecha;
  }

  /// Partos ya registrados en el ciclo en curso.
  int partosEnCiclo(Posa posa) {
    final corte = _ultimoDestete(posa.id);
    return posa.camadas
        .where((c) => corte == null || c.fecha.isAfter(corte))
        .length;
  }

  /// Máximo de partos por ciclo: una hembra, un parto.
  int limiteDePartos(Posa posa) => posa.hembras;

  bool puedeRegistrarParto(Posa posa) =>
      partosEnCiclo(posa) < limiteDePartos(posa);

  /// Comprueba las mismas condiciones que `PosaDetailFragment` antes de abrir
  /// la hoja de nacimiento. Devuelve null si se puede registrar.
  String? motivoParaNoRegistrarParto(Posa posa) {
    if (posa.hembras == 0) {
      return '⚠️ Se necesita al menos una hembra reproductora para registrar '
          'un nacimiento';
    }
    if (posa.empadre == null) {
      return '⚠️ Primero registra la fecha de empadre de esta posa. Un parto '
          'no puede registrarse antes de la monta.';
    }
    if (!puedeRegistrarParto(posa)) {
      return '🚫 Ya se registraron ${partosEnCiclo(posa)}/${limiteDePartos(posa)} '
          'partos en este ciclo. Para registrar más, primero desteta las crías '
          'o traslada las madres.';
    }
    return null;
  }

  Future<String?> registrarNacimiento(
    Posa posa, {
    required int vivas,
    required int muertas,
    DateTime? fecha,
    String nota = '',
  }) async {
    if (vivas <= 0 && muertas <= 0) return 'Ingresa al menos 1 cría';

    final impedimento = motivoParaNoRegistrarParto(posa);
    if (impedimento != null) return impedimento;

    final cuando = fecha ?? DateTime.now();
    final empadre = posa.empadre!;
    if (cuando.isBefore(DateTime(empadre.year, empadre.month, empadre.day))) {
      return 'El nacimiento no puede ser antes del empadre '
          '(${fechaCorta(empadre)})';
    }
    if (cuando.isAfter(DateTime.now())) {
      return 'El nacimiento no puede tener fecha futura';
    }

    if (vivas > 0) {
      posa.camadas.add(
        Camada(
          id: _nuevoId(),
          fecha: cuando,
          vivas: vivas,
          mortinatos: muertas,
        ),
      );
    }
    posa.categoria = Categoria.reproductoras;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.nacimiento,
        titulo: 'Nacimiento · Parto',
        fecha: cuando,
        crias: vivas,
        nota: nota,
        categoriaTexto: posa.categoria.chip,
      ),
    );
    if (muertas > 0) {
      movimientos.add(
        Movimiento(
          id: _nuevoId(),
          posaId: posa.id,
          tipo: TipoMovimiento.salida,
          titulo: 'Salida · Muerte de crías',
          fecha: cuando,
          crias: muertas,
          nota: 'Nacidas muertas',
        ),
      );
    }
    await _guardar();
    notifyListeners();
    return null;
  }

  Future<void> registrarBajaCrias(Posa posa, int cantidad, {String nota = ''}) async {
    if (cantidad <= 0) return;
    var restantes = cantidad;
    for (final c in posa.camadas.where((c) => !c.destetada)) {
      if (restantes == 0) break;
      final quita = restantes > c.vivas ? c.vivas : restantes;
      c.vivas -= quita;
      restantes -= quita;
    }
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.salida,
        titulo: 'Salida · Muerte de crías',
        fecha: DateTime.now(),
        crias: cantidad - restantes,
        nota: nota,
      ),
    );
    await _guardar();
    notifyListeners();
  }

  /// Camadas que ya cumplieron los días mínimos para destetar.
  List<Camada> camadasDestetables(Posa posa) => posa.camadas
      .where(
        (c) =>
            !c.destetada &&
            c.vivas > 0 &&
            c.diasDeVida(DateTime.now()) >= config.diasDestete,
      )
      .toList();

  Future<void> destetar(Posa posa, List<int> camadaIds) async {
    var total = 0;
    for (final c in posa.camadas) {
      if (camadaIds.contains(c.id) && !c.destetada) {
        c.destetada = true;
        total += c.vivas;
      }
    }
    if (total == 0) return;
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.destete,
        titulo: 'Destete · Crías separadas',
        fecha: DateTime.now(),
        crias: total,
      ),
    );
    _destetados += total;
    await _guardar();
    notifyListeners();
  }

  Future<void> registrarActividad(Posa posa, TipoActividad tipo) async {
    actividades.add(
      RegistroActividad(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: tipo,
        fecha: DateTime.now(),
      ),
    );
    movimientos.add(
      Movimiento(
        id: _nuevoId(),
        posaId: posa.id,
        tipo: TipoMovimiento.actividad,
        titulo: 'Actividad · ${tipo.etiqueta}',
        fecha: DateTime.now(),
        nota: '${tipo.emoji} ${tipo.etiqueta} realizada',
      ),
    );
    await _guardar();
    notifyListeners();
  }

  Future<void> guardarConfiguracion() async {
    await _guardar();
    notifyListeners();
  }

  DateTime? ultimaActividad(int posaId, TipoActividad tipo) {
    final lista = actividades
        .where((a) => a.posaId == posaId && a.tipo == tipo)
        .toList();
    if (lista.isEmpty) return null;
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista.first.fecha;
  }

  List<Movimiento> movimientosDe(int posaId) {
    final lista = movimientos.where((m) => m.posaId == posaId).toList();
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  DateTime? ultimoMovimiento(int posaId) {
    final lista = movimientosDe(posaId);
    return lista.isEmpty ? null : lista.first.fecha;
  }

  List<RegistroActividad> actividadesOrdenadas() {
    final lista = [...actividades];
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  // ─────────────────────────── Indicadores ───────────────────────────

  int _destetados = 0;

  int get totalAdultos => posas.fold(0, (s, p) => s + p.totalAdultos);
  int get totalCrias => posas.fold(0, (s, p) => s + p.crias);
  int get poblacionTotal => totalAdultos + totalCrias;
  int get totalMachos => posas.fold(0, (s, p) => s + p.machos);
  int get totalHembras => posas.fold(0, (s, p) => s + p.hembras);
  int get totalPosas => posas.length;
  int get posasActivas => posas.where((p) => !p.estaVacia).length;

  int get partos => movimientos
      .where((m) => m.tipo == TipoMovimiento.nacimiento)
      .length;

  int get criasNacidas => movimientos
      .where((m) => m.tipo == TipoMovimiento.nacimiento)
      .fold(0, (s, m) => s + m.crias);

  int get criasMuertas => movimientos
      .where((m) => m.titulo == 'Salida · Muerte de crías')
      .fold(0, (s, m) => s + m.crias);

  int get destetados => _destetados;

  String get criasPorParto {
    if (partos == 0) return '0';
    return (criasNacidas / partos).toStringAsFixed(1).replaceAll('.', ',');
  }

  int get porcentajeMachos {
    if (totalAdultos == 0) return 0;
    return (totalMachos * 100 / totalAdultos).round();
  }

  int get porcentajeHembras =>
      totalAdultos == 0 ? 0 : 100 - porcentajeMachos;

  Map<Categoria, int> get porCategoria {
    final mapa = <Categoria, int>{};
    for (final cat in [
      Categoria.gazapo,
      Categoria.recria,
      Categoria.engorde,
      Categoria.reproductoras,
      Categoria.descarte,
    ]) {
      mapa[cat] = posas
          .where((p) => p.categoria == cat)
          .fold(0, (s, p) => s + p.total);
    }
    // Las crías cuentan como gazapos aunque su posa sea de reproductoras.
    mapa[Categoria.gazapo] = mapa[Categoria.gazapo]! + totalCrias;
    mapa[Categoria.reproductoras] =
        (mapa[Categoria.reproductoras]! - totalCrias).clamp(0, 1 << 30);
    return mapa;
  }

  int get movimientosHistoricos => movimientos.length;

  // ────────────────────── Avisos (recordatorios) ──────────────────────

  /// Emite los avisos cuya condición se cumple hoy, con las mismas reglas de
  /// `RevisionRecordatorios.ejecutar()`.
  ///
  /// Son cuatro reglas, y el orden importa porque la primera y la tercera se
  /// excluyen entre sí:
  ///
  ///  1. **Nacimientos próximos** — solo en posas de reproductoras que *no*
  ///     tienen camadas vivas, cuando el empadre cumplió los días de gestación.
  ///  2. **Crías listas para separar** — por cada camada viva que superó los
  ///     días de destete.
  ///  3. **Parto próximo (re-empadre)** — si el re-empadre automático está
  ///     activo y quedó un macho, se predice el siguiente parto contando los
  ///     días de gestación desde el parto anterior.
  ///  4. **Mantenimiento** — agrupado *por galpón*, no por posa.
  List<Aviso> avisos() {
    final hoy = DateTime.now();
    final lista = <Aviso>[];

    for (final posa in posas) {
      if (posa.categoria != Categoria.reproductoras) continue;

      final vivas = posa.camadas.where((c) => !c.destetada && c.vivas > 0);

      // 1. Sin camadas en curso: se espera el primer parto del ciclo.
      if (vivas.isEmpty) {
        final empadre = posa.empadre;
        if (empadre != null &&
            hoy.difference(empadre).inDays >= config.diasGestacion) {
          lista.add(
            Aviso(
              titulo: '🍼 Nacimientos próximos',
              detalle:
                  'La posa ${posa.codigo} cumplió ${config.diasGestacion} días '
                  'de empadre. Está por iniciar los nacimientos.',
              fecha: hoy,
            ),
          );
        }
        continue;
      }

      for (final c in vivas) {
        // 2. Destete.
        if (c.diasDeVida(hoy) >= config.diasDestete) {
          lista.add(
            Aviso(
              titulo: '✂️ Crías listas para separar',
              detalle:
                  'La camada del ${fechaCorta(c.fecha)} en la posa '
                  '${posa.codigo} ya tiene ${config.diasDestete}+ días '
                  '(${c.vivas} crías). Listas para destetar.',
              fecha: hoy,
            ),
          );
        }

        // 3. Re-empadre: la hembra vuelve a parir tras el celo post-parto.
        if (config.reEmpadreAutomatico &&
            posa.machos > 0 &&
            c.diasDeVida(hoy) >= config.diasGestacion) {
          lista.add(
            Aviso(
              titulo: '🍼 Parto próximo (re-empadre)',
              detalle:
                  'Revisar la posa ${posa.codigo}: se espera parto de la '
                  'hembra que parió el ${fechaCorta(c.fecha)}.',
              fecha: hoy,
            ),
          );
        }
      }
    }

    // 4. Mantenimiento, agrupado por galpón.
    for (final galpon in galpones) {
      for (final tipo in TipoActividad.values) {
        final intervalo = config.intervalo(tipo);
        final vencidas = posasDe(galpon.id).where((p) {
          final ultima = ultimaActividad(p.id, tipo);
          return ultima != null &&
              hoy.difference(ultima).inDays >= intervalo;
        });
        if (vencidas.isNotEmpty) {
          lista.add(
            Aviso(
              titulo: '${tipo.emoji} Toca ${tipo.etiqueta.toLowerCase()}',
              detalle:
                  'El ${galpon.nombre} está disponible para '
                  '${tipo.etiqueta.toLowerCase()} (pasaron $intervalo días).',
              fecha: hoy,
            ),
          );
        }
      }
    }

    return lista;
  }
}
