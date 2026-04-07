import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehiculo_registrado_model.dart';

class CatalogoVehiculosViewModel extends ChangeNotifier {
  // Buscar marca y modelo
  final VehiculoService _vehiculoService = VehiculoService();

  List<VehiculoModel> marcas = [];
  List<VehiculoModel> modelos = [];
  bool cargandoModelos = false;

  Future<String> obtenerDescripcionModeloPorId(
    int marcaId,
    int modeloId,
    BuildContext context,
  ) async {
    try {
      final String token = Provider.of<LoginViewModel>(
        context,
        listen: false,
      ).token;

      final modelos = await _vehiculoService.obtenerModelos(marcaId, token);
      final modelo = modelos.firstWhere(
        (m) => m.id == modeloId,
        orElse: () => VehiculoModel(id: 0, descripcion: ''),
      );
      return modelo.descripcion;
    } catch (_) {
      return '';
    }
  }

  Future<void> cargarMarcas(BuildContext context) async {
    final String token = Provider.of<LoginViewModel>(
      context,
      listen: false,
    ).token;
    marcas = await _vehiculoService.obtenerMarcas(token);
    notifyListeners();
  }

  Future<void> cargarModelos(int marcaId, BuildContext context) async {
    cargandoModelos = true;
    notifyListeners();

    final String token = Provider.of<LoginViewModel>(
      context,
      listen: false,
    ).token;

    modelos = await _vehiculoService.obtenerModelos(marcaId, token);

    for (final m in modelos) {}

    cargandoModelos = false;
    notifyListeners();
  }

  String obtenerDescripcionMarca(int? id) {
    if (id == null) return '';
    return marcas
        .firstWhere(
          (m) => m.id == id,
          orElse: () => VehiculoModel(id: 0, descripcion: ''),
        )
        .descripcion;
  }

  String obtenerDescripcionModelo(int? id) {
    if (id == null) return '';

    if (cargandoModelos || modelos.isEmpty) {
      return ''; // o 'Cargando...'
    }

    return modelos
        .firstWhere(
          (m) => m.id == id,
          orElse: () => VehiculoModel(id: 0, descripcion: ''),
        )
        .descripcion;
  }

  // 🔹 Lista de vehículos guardados
  final List<VehiculoRegistrado> _vehiculos = [];

  // 🔹 Vehículo seleccionado
  VehiculoRegistrado? vehiculoSeleccionado;

  List<VehiculoRegistrado> get vehiculos => _vehiculos;

  // 🔹 Agregar desde Recepción
  void agregarVehiculo(VehiculoRegistrado vehiculo) {
    _vehiculos.add(vehiculo);
    notifyListeners();
  }

  // 🔹 Seleccionar desde el Drawer
  Future<void> seleccionarVehiculo(
    VehiculoRegistrado vehiculo,
    BuildContext context,
  ) async {
    vehiculoSeleccionado = vehiculo;

    // ⚠️ aquí está la diferencia
    final marcaId = marcas
        .firstWhere((m) => m.descripcion == vehiculo.marca)
        .id;

    await cargarModelos(marcaId, context);

    notifyListeners();
  }

  void limpiarSeleccion() {
    vehiculoSeleccionado = null;
    modelos.clear(); // limpia modelos seleccionados
    cargandoModelos = false; // resetea estado de carga
    notifyListeners();
  }
}
