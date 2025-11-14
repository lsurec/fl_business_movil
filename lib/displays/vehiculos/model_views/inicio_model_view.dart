import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:flutter/material.dart';

/// Modelo de un ítem del vehículo
import 'package:image_picker/image_picker.dart';

/// Modelo de un ítem del vehículo
class ItemVehiculo {
  final String idProducto;
  final String desProducto;
  String detalle;
  bool completado;

  // 👇 Nueva propiedad para almacenar fotos del item
  List<XFile> fotos = [];


  ItemVehiculo({
    required this.idProducto,
    required this.desProducto,
    this.detalle = '',
    this.completado = false,
    List<XFile>? fotos, // 👈 nuevo parámetro opcional
  }) : fotos = fotos ?? [];
}


/// ViewModel general
class InicioVehiculosViewModel extends ChangeNotifier {
  final VehiculoService _vehiculoService = VehiculoService(
    token:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJhZG1pbiIsIm5iZiI6MTc2MTE3MDU3NywiZXhwIjoxNzkyMjc0NTc3LCJpYXQiOjE3NjExNzA1Nzd9.3BXM8Usk7wUHvsV4LX3S7pOl3Hvr_Z9LenkH4vgvOek",
  );

  // Estado general
  bool isLoading = false;
  String? error;

  // Datos del cliente
  String nit = '';
  String nombre = '';
  String direccion = '';
  String celular = '';
  String email = '';

  // Observaciones
  String detalleTrabajo = '';
  String kilometraje = '';
  String cc = '';
  String cil = '';

  // Controladores
  final TextEditingController detalleTrabajoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kilometrajeController = TextEditingController();
  final TextEditingController ccController = TextEditingController();
  final TextEditingController cilController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  String fechaRecibido = '';
  String fechaSalida = '';

  // Listas dinámicas
  List<VehiculoModel> marcas = [];
  List<VehiculoModel> modelos = [];
  List<VehiculoYearModel> anios = [];
  List<VehiculoModel> colores = [];

  // Selecciones
  VehiculoModel? marcaSeleccionada;
  VehiculoModel? modeloSeleccionado;
  VehiculoYearModel? anioSeleccionado;
  VehiculoModel? colorSeleccionado;

  // --- 🧩 Nueva sección: ÍTEMS DEL VEHÍCULO ---
  List<ItemVehiculo> itemsAsignados = [];

  void setItemsAsignados(List<ItemVehiculo> items) {
    itemsAsignados = items;
    notifyListeners();
  }

  void actualizarItem(String idProducto, {String? detalle, bool? completado}) {
    final index = itemsAsignados.indexWhere((e) => e.idProducto == idProducto);
    if (index != -1) {
      final item = itemsAsignados[index];
      if (detalle != null) item.detalle = detalle;
      if (completado != null) item.completado = completado;
      notifyListeners();
    }
  }

  void limpiarItems() {
    itemsAsignados.clear();
    notifyListeners();
  }

  // --- Carga inicial ---
  Future<void> cargarDatosIniciales() async {
    try {
      isLoading = true;
      notifyListeners();

      marcas = await _vehiculoService.obtenerMarcas();
      anios = await _vehiculoService.obtenerAnios();
      colores = await _vehiculoService.obtenerColores();
    } catch (e) {
      error = 'Error al cargar datos: $e';
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Métodos de selección ---
  Future<void> seleccionarMarca(VehiculoModel marca) async {
    marcaSeleccionada = marca;
    modeloSeleccionado = null;
    modelos = [];
    notifyListeners();

    try {
      modelos = await _vehiculoService.obtenerModelos(marca.id);
      notifyListeners();
    } catch (e) {
      error = 'Error al cargar modelos: $e';
      notifyListeners();
    }
  }

  void seleccionarModelo(VehiculoModel modelo) {
    modeloSeleccionado = modelo;
    notifyListeners();
  }

  void seleccionarAnio(VehiculoYearModel anio) {
    anioSeleccionado = anio;
    notifyListeners();
  }

  void seleccionarColor(VehiculoModel color) {
    colorSeleccionado = color;
    notifyListeners();
  }

  void seleccionarFechaRecibido(String fecha) {
    fechaRecibido = fecha;
    notifyListeners();
  }

  void seleccionarFechaSalida(String fecha) {
    fechaSalida = fecha;
    notifyListeners();
  }

  // --- Guardado general ---
  void guardar() {
    nit = nitController.text;
    nombre = nombreController.text;
    direccion = direccionController.text;
    detalleTrabajo = detalleTrabajoController.text;
    celular = celularController.text;
    email = emailController.text;
    kilometraje = kilometrajeController.text;
    cc = ccController.text;
    cil = cilController.text;

    debugPrint('Guardando datos del vehículo y cliente...');
    debugPrint('NIT: $nit, Nombre: $nombre, Dirección: $direccion');
    debugPrint(
      'Marca: ${marcaSeleccionada?.descripcion}, Modelo: ${modeloSeleccionado?.descripcion}, Año: ${anioSeleccionado?.anio}, Color: ${colorSeleccionado?.descripcion}',
    );
    debugPrint(
      'Detalle: $detalleTrabajo, Celular: $celular, Email: $email, KM: $kilometraje, CC: $cc, CIL: $cil',
    );
    debugPrint('Fecha recibido: $fechaRecibido, Fecha salida: $fechaSalida');

    notifyListeners();
  }

  void cancelar() {
    nit = '';
    nombre = '';
    direccion = '';
    detalleTrabajo = '';
    celular = '';
    email = '';
    kilometraje = '';
    cc = '';
    cil = '';
    marcaSeleccionada = null;
    modeloSeleccionado = null;
    anioSeleccionado = null;
    colorSeleccionado = null;
    fechaRecibido = '';
    fechaSalida = '';
    limpiarItems();

    detalleTrabajoController.clear();
    celularController.clear();
    emailController.clear();
    kilometrajeController.clear();
    ccController.clear();
    cilController.clear();
    nitController.clear();
    nombreController.clear();
    direccionController.clear();

    notifyListeners();
  }
}
