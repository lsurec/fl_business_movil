import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:flutter/material.dart';
import '../models/vehiculo_registrado_model.dart';

class CatalogoVehiculosViewModel extends ChangeNotifier {
  // Buscar marca y modelo
  final VehiculoService _vehiculoService = VehiculoService();

  List<VehiculoModel> marcas = [];
  List<VehiculoModel> modelos = [];
bool cargandoModelos = false;

Future<String> obtenerDescripcionModeloPorId(int marcaId, int modeloId) async {
  try {
    final modelos = await _vehiculoService.obtenerModelos(marcaId);
    final modelo = modelos.firstWhere(
      (m) => m.id == modeloId,
      orElse: () => VehiculoModel(id: 0, descripcion: ''),
    );
    return modelo.descripcion;
  } catch (_) {
    return '';
  }
}

  Future<void> cargarMarcas() async {
    marcas = await _vehiculoService.obtenerMarcas();
    notifyListeners();
  }

  Future<void> cargarModelos(int marcaId) async {
  cargandoModelos = true;
  notifyListeners();


  modelos = await _vehiculoService.obtenerModelos(marcaId);

  for (final m in modelos) {
    
  }

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
 Future<void> seleccionarVehiculo(VehiculoRegistrado vehiculo) async {
  vehiculoSeleccionado = vehiculo;

  // ⚠️ aquí está la diferencia
  final marcaId = marcas
      .firstWhere((m) => m.descripcion == vehiculo.marca)
      .id;

  await cargarModelos(marcaId);

  notifyListeners();
}



  void limpiarSeleccion() {
    vehiculoSeleccionado = null;
    notifyListeners();
  }
}
