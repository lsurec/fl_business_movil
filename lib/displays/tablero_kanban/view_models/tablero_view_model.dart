import 'package:flutter/material.dart';
import 'package:fl_business/displays/tablero_kanban/models/estado_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/prioridad_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/tarea_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/tipo_tarea_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/usuario_model.dart';
import 'package:fl_business/displays/tablero_kanban/services/estado_service.dart';
import 'package:fl_business/displays/tablero_kanban/services/invitados_de%20una_tarea.service.dart';
import 'package:fl_business/displays/tablero_kanban/services/prioridad_service.dart';
import 'package:fl_business/displays/tablero_kanban/services/tarea_service.dart';
import 'package:fl_business/displays/tablero_kanban/services/tipo_tarea_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';

class PrincipalViewModel extends ChangeNotifier {
  // Datos base
  List<Estado> _estados = [];
  List<TipoTarea> _tiposTarea = [];
  List<Prioridad> _prioridades = [];
  List<Tarea> _tareas = [];
  List<Tarea> _tareasCreadas = [];
  List<Tarea> _tareasAsignadas = [];
  List<Tarea> _tareasInvitadas = [];

  // Datos filtrados
  List<Tarea> _tareasFiltradasPorEstado = [];

  // Control de pestañas
  String _pestanaSeleccionada = "todas";

  // Filtros
  Estado? _estadoFiltroSeleccionado;
  TipoTarea? _tipoFiltroSeleccionado;
  Prioridad? _prioridadFiltroSeleccionada;
  String? _referenciaFiltroSeleccionada;
  Usuario? _usuarioSeleccionado;

  // UI
  bool _cargando = false;
  bool _mostrarFiltros = false;
  bool _cargandoInvitadas = false;
  bool _isLoading = false;

  // Paginación
  int _paginaActual = 0;
  final int _tamanioPagina = 30;

  // Getters
  List<Estado> get estados => _estados;
  List<TipoTarea> get tiposTarea => _tiposTarea;
  List<Prioridad> get prioridades => _prioridades;
  List<Tarea> get tareas => _tareas;
  List<Tarea> get tareasCreadas => _tareasCreadas;
  List<Tarea> get tareasAsignadas => _tareasAsignadas;
  List<Tarea> get tareasInvitadas => _tareasInvitadas;
  List<Tarea> get tareasFiltradasPorEstado => _tareasFiltradasPorEstado;
  String get pestanaSeleccionada => _pestanaSeleccionada;
  Estado? get estadoFiltroSeleccionado => _estadoFiltroSeleccionado;
  TipoTarea? get tipoFiltroSeleccionado => _tipoFiltroSeleccionado;
  Prioridad? get prioridadFiltroSeleccionada => _prioridadFiltroSeleccionada;
  String? get referenciaFiltroSeleccionada => _referenciaFiltroSeleccionada;
  Usuario? get usuarioSeleccionado => _usuarioSeleccionado;
  bool get cargando => _cargando;
  bool get mostrarFiltros => _mostrarFiltros;
  bool get cargandoInvitadas => _cargandoInvitadas;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get tamanioPagina => _tamanioPagina;

  // Setters
  set pestanaSeleccionada(String value) {
    _pestanaSeleccionada = value;
    notifyListeners();
  }

  set mostrarFiltros(bool value) {
    _mostrarFiltros = value;
    notifyListeners();
  }

  // ================== INICIALIZACIÓN ==================
  Future<void> init() async {
    await _cargarEstados();
    await _cargarTiposTarea();
    await _cargarPrioridades();
    await _cargarTareasPaginadas("todas");
  }

  // ================== CARGAS ==================
  Future<void> _cargarEstados() async {
    try {
      final data = await EstadoService().getEstados();
      _estados = data;
      notifyListeners();
    } catch (e) {
      print("Error cargando estados: $e");
    }
  }

  Future<void> _cargarTiposTarea() async {
    try {
      final data = await TipoTareaService().getTiposTarea();
      _tiposTarea = data;
      notifyListeners();
    } catch (e) {
      print("Error cargando tipos de tarea: $e");
    }
  }

  Future<void> _cargarPrioridades() async {
    try {
      final data = await PrioridadService().fetchPrioridades();
      _prioridades = data;
      notifyListeners();
    } catch (e) {
      print("Error cargando prioridades: $e");
    }
  }

  Future<void> _cargarTareasPaginadas(String tipo) async {
    _cargando = true;
    _isLoading = true;
    notifyListeners();

    int rangoIni = _paginaActual * _tamanioPagina;
    int rangoFin = rangoIni + _tamanioPagina;

    try {
      final user = Preferences.userName;
      final token = Preferences.token;

      List<Tarea> data = [];

      switch (tipo) {
        case "creadas":
          final res = await TareaService().getRangoCreadas(
            user,
            token,
            rangoIni,
            rangoFin,
          );
          if (res.succes) data = List<Tarea>.from(res.response);
          _tareasCreadas = data;
          break;
        case "asignadas":
          final res = await TareaService().getRangoAsignadas(
            user,
            token,
            rangoIni,
            rangoFin,
          );
          if (res.succes) data = List<Tarea>.from(res.response);
          _tareasAsignadas = data;
          break;
        case "invitadas":
          final res = await TareaService().getRangoInvitadas(
            user,
            token,
            rangoIni,
            rangoFin,
          );
          if (res.succes) data = List<Tarea>.from(res.response);
          _tareasInvitadas = data;
          break;
        default:
          final res = await TareaService().getTodas(
            user,
            token,
            rangoIni,
            rangoFin,
          );
          if (res.succes) data = List<Tarea>.from(res.response);
          _tareas = data;
      }

      await _filtrarTareas();
    } catch (e) {
      print("Error cargando $tipo: $e");
    } finally {
      _cargando = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================== FILTROS ==================
  Future<void> aplicarFiltroEstado(Estado? estado) async {
    _estadoFiltroSeleccionado = estado;
    await _filtrarTareas();
  }

  Future<void> aplicarFiltroTipo(TipoTarea? tipo) async {
    _tipoFiltroSeleccionado = tipo;
    await _filtrarTareas();
  }

  Future<void> aplicarFiltroPrioridad(Prioridad? prioridad) async {
    _prioridadFiltroSeleccionada = prioridad;
    await _filtrarTareas();
  }

  Future<void> aplicarFiltroReferencia(String? referencia) async {
    _referenciaFiltroSeleccionada = referencia;
    await _filtrarTareas();
  }

  Future<void> aplicarFiltroUsuario(Usuario? usuario) async {
    _usuarioSeleccionado = usuario;
    await _filtrarTareas();
  }

  Future<void> _filtrarTareas() async {
    List<Tarea> origen;
    switch (_pestanaSeleccionada) {
      case "creadas":
        origen = _tareasCreadas;
        break;
      case "asignadas":
        origen = _tareasAsignadas;
        break;
      case "invitadas":
        origen = _tareasInvitadas;
        break;
      default:
        origen = _tareas;
    }

    List<Tarea> filtradas = origen;

    if (_estadoFiltroSeleccionado != null) {
      filtradas = filtradas
          .where((t) => t.tareaEstado == _estadoFiltroSeleccionado!.descripcion)
          .toList();
    }
    if (_tipoFiltroSeleccionado != null) {
      filtradas = filtradas
          .where(
            (t) =>
                t.descripcionTipoTarea == _tipoFiltroSeleccionado!.descripcion,
          )
          .toList();
    }
    if (_prioridadFiltroSeleccionada != null) {
      final nombreFiltro = _prioridadFiltroSeleccionada!.nombre
          .toLowerCase()
          .trim();
      filtradas = filtradas.where((t) {
        final prioridadTarea = t.nomNivelPrioridad.toLowerCase().trim();
        return prioridadTarea == nombreFiltro;
      }).toList();
    }

    if (_referenciaFiltroSeleccionada != null &&
        _referenciaFiltroSeleccionada!.isNotEmpty) {
      filtradas = filtradas
          .where(
            (t) => t.referencia.toString() == _referenciaFiltroSeleccionada,
          )
          .toList();
    }
    if (_usuarioSeleccionado != null) {
      final usuarioFiltro = _usuarioSeleccionado!;
      List<Tarea> filtradasConInvitados = [];

      for (final tarea in filtradas) {
        final responsable = tarea.usuarioResponsable?.toLowerCase() ?? '';
        final creador = tarea.usuarioCreador.toLowerCase();
        final emailCreador = tarea.emailCreador?.toLowerCase() ?? '';
        final usuarioTarea = tarea.usuarioTarea.toLowerCase();

        final usuarioFiltroName = usuarioFiltro.name.toLowerCase();
        final usuarioFiltroUser = usuarioFiltro.userName.toLowerCase();
        final usuarioFiltroEmail = usuarioFiltro.email.toLowerCase();

        final coincideCreador =
            creador == usuarioFiltroName ||
            emailCreador == usuarioFiltroEmail ||
            usuarioTarea == usuarioFiltroUser ||
            responsable == usuarioFiltroUser ||
            responsable == usuarioFiltroName ||
            responsable == usuarioFiltroEmail;

        if (coincideCreador) {
          filtradasConInvitados.add(tarea);
          continue;
        }

        try {
          final invitados = await InvitadosService().obtenerInvitados(
            tarea.iDTarea,
          );
          final esInvitado = invitados.any((inv) {
            final email = inv.eMail.toLowerCase();
            final userName = inv.userName.toLowerCase();
            return email == usuarioFiltro.email.toLowerCase() ||
                userName == usuarioFiltro.userName.toLowerCase() ||
                userName == usuarioFiltro.name.toLowerCase();
          });

          if (esInvitado) {
            filtradasConInvitados.add(tarea);
          }
        } catch (e) {
          print("Error al verificar invitados en tarea ${tarea.iDTarea}: $e");
        }
      }

      filtradas = filtradasConInvitados;
    }

    _tareasFiltradasPorEstado = filtradas;
    notifyListeners();
  }

  void limpiarFiltros() {
    _estadoFiltroSeleccionado = null;
    _tipoFiltroSeleccionado = null;
    _prioridadFiltroSeleccionada = null;
    _filtrarTareas();
  }

  void limpiarFiltroUsuario() {
    _usuarioSeleccionado = null;
    notifyListeners();
    _filtrarTareas();
  }

  void limpiarFiltroReferencia() {
    _referenciaFiltroSeleccionada = null;
    notifyListeners();
    _filtrarTareas();
  }

  // ================== PAGINACIÓN ==================
  void cambiarPagina(int nuevaPagina) {
    _paginaActual = nuevaPagina;
    _cargarTareasPaginadas(_pestanaSeleccionada);
  }

  void siguientePagina() {
    _paginaActual++;
    _cargarTareasPaginadas(_pestanaSeleccionada);
  }

  void anteriorPagina() {
    if (_paginaActual > 0) {
      _paginaActual--;
      _cargarTareasPaginadas(_pestanaSeleccionada);
    }
  }

  void primeraPagina() {
    _paginaActual = 0;
    _cargarTareasPaginadas(_pestanaSeleccionada);
  }

  // ================== CAMBIO DE PESTAÑA ==================
  void cambiarPestana(String nuevaPestana) {
    _pestanaSeleccionada = nuevaPestana;
    _paginaActual = 0;
    _cargarTareasPaginadas(nuevaPestana);
  }

  // ================== UTILIDADES ==================
  List<Tarea> get tareasActuales {
    if (_tareasFiltradasPorEstado.isNotEmpty) {
      return _tareasFiltradasPorEstado;
    }

    switch (_pestanaSeleccionada) {
      case "creadas":
        return _tareasCreadas;
      case "asignadas":
        return _tareasAsignadas;
      case "invitadas":
        return _tareasInvitadas;
      default:
        return _tareas;
    }
  }

  bool get hayFiltrosActivos {
    return _estadoFiltroSeleccionado != null ||
        _tipoFiltroSeleccionado != null ||
        _prioridadFiltroSeleccionada != null ||
        (_referenciaFiltroSeleccionada?.isNotEmpty ?? false) ||
        _usuarioSeleccionado != null;
  }
}
