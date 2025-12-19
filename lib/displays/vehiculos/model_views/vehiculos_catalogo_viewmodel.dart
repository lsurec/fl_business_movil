import 'package:flutter/material.dart';
import '../models/vehiculo_registrado_model.dart';

class CatalogoVehiculosViewModel extends ChangeNotifier {
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
  void seleccionarVehiculo(VehiculoRegistrado vehiculo) {
    vehiculoSeleccionado = vehiculo;
    notifyListeners();
  }
  void limpiarSeleccion() {
    vehiculoSeleccionado = null;
    notifyListeners();
  }
}
