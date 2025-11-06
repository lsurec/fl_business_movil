import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:flutter/material.dart';

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

  void actualizarNit(String v) {
    nit = v;
    notifyListeners();
  }

  void actualizarNombre(String v) {
    nombre = v;
    notifyListeners();
  }

  void actualizarDireccion(String v) {
    direccion = v;
    notifyListeners();
  }

  void actualizarCelular(String v) {
    celular = v;
    notifyListeners();
  }

  void actualizarEmail(String v) {
    email = v;
    notifyListeners();
  }

  void actualizarDetalleTrabajo(String v) {
    detalleTrabajo = v;
    notifyListeners();
  }

  void actualizarKilometraje(String v) {
    kilometraje = v;
    notifyListeners();
  }

  void actualizarCC(String v) {
    cc = v;
    notifyListeners();
  }

  void actualizarCil(String v) {
    cil = v;
    notifyListeners();
  }

  final TextEditingController detalleTrabajoController =
      TextEditingController();
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

  // Inicialización
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
  // Actualiza las variables con lo que el usuario escribió en los inputs
  nit = nitController.text;
  nombre = nombreController.text;
  direccion = direccionController.text;
  detalleTrabajo = detalleTrabajoController.text;
  celular = celularController.text;
  email = emailController.text;
  kilometraje = kilometrajeController.text;
  cc = ccController.text;
  cil = cilController.text;

  // Muestra en consola (puedes quitarlo luego)
  debugPrint('Guardando datos del vehículo y cliente...');
  debugPrint('NIT: $nit, Nombre: $nombre, Dirección: $direccion');
  debugPrint(
    'Marca: ${marcaSeleccionada?.descripcion}, Modelo: ${modeloSeleccionado?.descripcion}, Año: ${anioSeleccionado?.anio}, Color: ${colorSeleccionado?.descripcion}',
  );
  debugPrint(
    'Detalle: $detalleTrabajo, Celular: $celular, Email: $email, KM: $kilometraje, CC: $cc, CIL: $cil',
  );
  debugPrint('Fecha recibido: $fechaRecibido, Fecha salida: $fechaSalida');

  // Notifica cambios si hay algo que actualizar visualmente
  notifyListeners();

  // Muestra un mensaje de confirmación en pantalla
 
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

    // Limpieza de controladores
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
