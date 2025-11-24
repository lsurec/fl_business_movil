import 'dart:convert';
import 'dart:math';

import 'package:fl_business/displays/prc_documento_3/models/doc_estructura_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/post_document_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/tra_interna_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/details_view_model.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// ============================================================================
///                               MODELO DEL ÍTEM
/// ============================================================================
/// Representa un ítem a revisar en el vehículo.
/// Cada ítem puede tener:
/// - ID y descripción
/// - Detalle adicional
/// - Estado de completado
/// - Varias fotos tomadas desde la cámara
class ItemVehiculo {
  final String idProducto;
  final String desProducto;

  String detalle;
  bool completado;

  // Lista de fotografías asociadas al ítem
  List<XFile> fotos = [];

  ItemVehiculo({
    required this.idProducto,
    required this.desProducto,
    this.detalle = '',
    this.completado = false,
    List<XFile>? fotos,
  }) : fotos = fotos ?? [];
}

/// ============================================================================
///                           VIEWMODEL PRINCIPAL
/// ============================================================================
/// Controla y almacena toda la información del formulario
/// de ingreso del vehículo, datos del cliente y los ítems revisados.
/// 
/// Provee métodos para:
/// - Cargar marcas, modelos, años y colores desde la API
/// - Seleccionar valores
/// - Guardar la información
/// - Limpiar todos los datos
class InicioVehiculosViewModel extends ChangeNotifier {
  /// Servicio que obtiene datos desde la API
 

  // ============================================================================
  //                          ESTADO GENERAL Y ERRORES
  // ============================================================================
  bool isLoading = false;
  String? error;

  // ============================================================================
  //                          DATOS DEL CLIENTE
  // ============================================================================
  String nit = '';
  String nombre = '';
  String direccion = '';
  String celular = '';
  String email = '';

  // ============================================================================
  //                          OBSERVACIONES DEL VEHÍCULO
  // ============================================================================
  String detalleTrabajo = '';
  String kilometraje = '';
  String cc = '';
  String cil = '';

  // ============================================================================
  //                          CONTROLADORES DE INPUT
  // ============================================================================
  final TextEditingController detalleTrabajoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kilometrajeController = TextEditingController();
  final TextEditingController ccController = TextEditingController();
  final TextEditingController cilController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  // ============================================================================
  //                          FECHAS
  // ============================================================================
  String fechaRecibido = '';
  String fechaSalida = '';

  // ============================================================================
  //                          LISTAS OBTENIDAS DE API
  // ============================================================================
  List<VehiculoModel> marcas = [];
  List<VehiculoModel> modelos = [];
  List<VehiculoYearModel> anios = [];
  List<VehiculoModel> colores = [];

  // ============================================================================
  //                          SELECCIONES DEL USUARIO
  // ============================================================================
  VehiculoModel? marcaSeleccionada;
  VehiculoModel? modeloSeleccionado;
  VehiculoYearModel? anioSeleccionado;
  VehiculoModel? colorSeleccionado;

  // ============================================================================
  //                          LISTA DE ÍTEMS DEL VEHÍCULO
  // ============================================================================
  List<ItemVehiculo> itemsAsignados = [];

  /// Reemplaza la lista completa de ítems
  void setItemsAsignados(List<ItemVehiculo> items) {
    itemsAsignados = items;
    notifyListeners();
  }

  /// Actualiza un ítem específico por ID
  void actualizarItem(
    String idProducto, {
    String? detalle,
    bool? completado,
  }) {
    final index = itemsAsignados.indexWhere((e) => e.idProducto == idProducto);
    if (index != -1) {
      final item = itemsAsignados[index];

      if (detalle != null) item.detalle = detalle;
      if (completado != null) item.completado = completado;

      notifyListeners();
    }
  }

  /// Elimina todos los ítems y limpia la pantalla
  void limpiarItems() {
    itemsAsignados.clear();
    notifyListeners();
  }

  // ============================================================================
  //                          CARGA INICIAL DESDE API
  // ============================================================================
  final VehiculoService _vehiculoService = VehiculoService();

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


  // ============================================================================
  //                               SELECCIÓN DE DATOS
  // ============================================================================
  /// Selecciona la marca y carga los modelos asociados
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


  /// Selecciona un modelo
  void seleccionarModelo(VehiculoModel modelo) {
    modeloSeleccionado = modelo;
    notifyListeners();
  }

  /// Selecciona el año
  void seleccionarAnio(VehiculoYearModel anio) {
    anioSeleccionado = anio;
    notifyListeners();
  }

  /// Selecciona el color
  void seleccionarColor(VehiculoModel color) {
    colorSeleccionado = color;
    notifyListeners();
  }

  /// Selecciona la fecha de recibido
  void seleccionarFechaRecibido(String fecha) {
    fechaRecibido = fecha;
    notifyListeners();
  }

  /// Selecciona la fecha de salida
  void seleccionarFechaSalida(String fecha) {
    fechaSalida = fecha;
    notifyListeners();
  }

  // ============================================================================
  //                           GUARDAR INFORMACIÓN
  // ============================================================================
  /// Carga los valores de los TextControllers a las variables reales
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
    debugPrint('Marca: ${marcaSeleccionada?.descripcion}, Modelo: ${modeloSeleccionado?.descripcion}');
    debugPrint('Año: ${anioSeleccionado?.anio}, Color: ${colorSeleccionado?.descripcion}');
    debugPrint('Detalle: $detalleTrabajo, Celular: $celular, Email: $email');
    debugPrint('KM: $kilometraje, CC: $cc, CIL: $cil');
    debugPrint('Fecha recibido: $fechaRecibido, Fecha salida: $fechaSalida');

    notifyListeners();
  }

  // ============================================================================
  //                           LIMPIAR FORMULARIO COMPLETO
  // ============================================================================
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

    // Limpiar controladores
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


int idDocumentoRef = 0;

  void setIdDocumentoRef() {
    DateTime date = DateTime.now();

    final random = Random();
    int numeroAleatorio = 100 + random.nextInt(900); // 100 a 999

    // Combinar los dos números para formar uno de 14 dígitos
    String combinedStr =
        numeroAleatorio.toString() +
        date.day.toString().padLeft(2, '0') +
        date.month.toString().padLeft(2, '0') +
        date.year.toString() +
        date.hour.toString().padLeft(2, '0') +
        date.minute.toString().padLeft(2, '0') +
        date.second.toString().padLeft(2, '0');

    // ref id
    idDocumentoRef = int.parse(combinedStr);
    notifyListeners();
  }

 //Doc Estructura sin items ni imágenes

Future<void> generarDocumento(BuildContext context) async {
  

 var random = Random();

    // Generar dos números aleatorios de 7 dígitos cada uno
    int firstPart = random.nextInt(10000000);
setIdDocumentoRef();

DateTime myDateTime = DateTime.now();
    String serializedDateTime = myDateTime.toIso8601String();
final menuVM = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

     int tipoDocumento = menuVM.documento!;
final localVM = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    );

int empresa = localVM.selectedEmpresa!.empresa;


int estacion = localVM.selectedEstacion!.estacionTrabajo;
final loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );
final detailsVM = Provider.of<DetailsViewModel>(
      context,
      listen: false,
    );

  String user = loginVM.user;

  
// List<TraInternaModel> products = detailsVM.traInternas;

// final List<DocTransaccion> transacciones = [];
// List<TraInternaModel> operaciones;

// int consectivo = 1;
//     //Objeto transaccion documento para estructura documento
//     for (var transaction in itemsAsignados) {
//       int padre = consectivo;
//       final List<DocTransaccion> cargos = [];
//       final List<DocTransaccion> descuentos = [];

//       for (var operacion in transaction.operaciones) {
//         //Cargo
//         if (operacion.cargo != 0) {
//           consectivo++;
//           cargos.add(
//             DocTransaccion(
//               traMontoDias: null,
//               traObservacion: null,
//               dConsecutivoInterno: firstPart,
//               traConsecutivoInterno: consectivo,
//               traConsecutivoInternoPadre: padre,
//               traBodega: transaction.bodega!.bodega,
//               traProducto: transaction.producto.producto,
//               traUnidadMedida: transaction.producto.unidadMedida,
//               traCantidad: 0,
//               traTipoCambio: menuVM.tipoCambio,
//               traMoneda: transaction.precio!.moneda,
//               traTipoPrecio: transaction.precio!.precio
//                   ? transaction.precio!.id
//                   : null,
//               traFactorConversion: !transaction.precio!.precio
//                   ? transaction.precio!.id
//                   : null,
//               traTipoTransaccion: resolveTipoTransaccion(
//                 4,
//                 scaffoldKey.currentContext!,
//               ),
//               traMonto: operacion.cargo,
//             ),
//           );
//         }

//         //Descuento
//         if (operacion.descuento != 0) {
//           consectivo++;

//           descuentos.add(
//             DocTransaccion(
//               traMontoDias: null,
//               traObservacion: null,
//               dConsecutivoInterno: firstPart,
//               traConsecutivoInterno: consectivo,
//               traConsecutivoInternoPadre: padre,
//               traBodega: transaction.bodega!.bodega,
//               traProducto: transaction.producto.producto,
//               traUnidadMedida: transaction.producto.unidadMedida,
//               traCantidad: 0,
//               traTipoCambio: menuVM.tipoCambio,
//               traMoneda: transaction.precio!.moneda,
//               traTipoPrecio: transaction.precio!.precio
//                   ? transaction.precio!.id
//                   : null,
//               traFactorConversion: !transaction.precio!.precio
//                   ? transaction.precio!.id
//                   : null,
//               traTipoTransaccion: resolveTipoTransaccion(
//                 3,
//                 scaffoldKey.currentContext!,
//               ),
//               traMonto: operacion.descuento,
//             ),
//           );
//         }
//       }

//       transactions.add(
//         DocTransaccion(
//           traObservacion: transaction.observacion,
//           dConsecutivoInterno: firstPart,
//           traConsecutivoInterno: padre,
//           traConsecutivoInternoPadre: null,
//           traBodega: transaction.bodega!.bodega,
//           traProducto: transaction.producto.producto,
//           traUnidadMedida: transaction.producto.unidadMedida,
//           traCantidad: transaction.cantidad,
//           traTipoCambio: menuVM.tipoCambio,
//           traMoneda: transaction.precio!.moneda,
//           traTipoPrecio: transaction.precio!.precio
//               ? transaction.precio!.id
//               : null,
//           traFactorConversion: !transaction.precio!.precio
//               ? transaction.precio!.id
//               : null,
//           traTipoTransaccion: resolveTipoTransaccion(
//             transaction.producto.tipoProducto,
//             scaffoldKey.currentContext!,
//           ),
//           traMonto: transaction.total,
//           traMontoDias: transaction.precioDia,
//         ),
//       );

//       for (var cargo in cargos) {
//         transactions.add(cargo);
//       }

//       for (var descuento in descuentos) {
//         transactions.add(descuento);
//       }

//       consectivo++;
//     }

// final docGlobal = DocEstructuraModel(
//       docVersionApp: SplashViewModel.versionLocal,
//       docConfirmarOrden:  false, //TODO:parametrizar segun valor si es cotiacion de ALfa y Omega
//       docComanda: null,
//       docMesa: null,
//       docUbicacion: null,
//       docLatitud: null,
//       docLongitud: null,
//       consecutivoInterno: firstPart,
//       docTraMonto: 0,
//       docCaMonto: 0,
//       docIdCertificador: 1, //TODO: Agrgar certificador
//       docCuentaVendedor: null,
//       docIdDocumentoRef: idDocumentoRef,
//       docFelNumeroDocumento: null,
//       docFelSerie: null,
//       docFelUUID: null,
//       docFelFechaCertificacion: null,
//       docCuentaCorrentista: 1,// incorporar cuenta correntista del cliente
//       docCuentaCta: "1",
//       docFechaDocumento: serializedDateTime,
//       docTipoDocumento: tipoDocumento,
//       docSerieDocumento: "1",// hay que hacerlo al igual que cc
//       docEmpresa: empresa,
//       docEstacionTrabajo: estacion,
//       docUserName: user,
//       docObservacion1: "",//si se quisiera colocar una observacion
//       docTipoPago: 1, //TODO: preguntar
//       docElementoAsignado: null,
//       docTransaccion: transactions,
//       docCargoAbono: payments,
//       docRefTipoReferencia: docVM.valueParametro(58)
//           ? docVM.referenciaSelect?.tipoReferencia
//           : null, //TODO:Si es ilgua buscar en otra parte
//       docFechaIni: docVM.valueParametro(44) ? docVM.fechaInicial : null,
//       docFechaFin: docVM.valueParametro(44) ? docVM.fechaFinal : null,
//       docRefFechaIni: docVM.valueParametro(381) ? docVM.fechaRefIni : null,
//       docRefFechaFin: docVM.valueParametro(382) ? docVM.fechaRefFin : null,
//       docRefObservacion: docVM.valueParametro(383)
//           ? docVM.refObservacionParam384.text
//           : null,
//       docRefDescripcion: docVM.valueParametro(384)
//           ? docVM.refDescripcionParam383.text
//           : null,
//       docRefObservacion2: docVM.valueParametro(385)
//           ? docVM.refContactoParam385.text
//           : null,
//       docRefObservacion3: docVM.valueParametro(386)
//           ? docVM.refDirecEntregaParam386.text
//           : null,
//       docReferencia: docVM.valueParametro(58)
//           ? refVM.referencia!.referencia
//           : null,
//     );
// }


// String generarEstructuraString() {
//   final mapa = generarDocumentoJson();
//   return jsonEncode(mapa);
// }


// Future<int?> guardarDocumento() async {
//   try {
//     final documento = generarDocumentoParaEnviar();

//     final respuesta = await _vehiculoService.enviarDocumento(documento);

//     print("Respuesta API: $respuesta");

//     if (respuesta["status"] == true) {
//       return respuesta["numeroDocumento"];
//     }

//     return null;
//   } catch (e) {
//     print("ERROR guardando documento: $e");
//     return null;
//   }
// }




// PostDocumentModel generarDocumentoParaEnviar() {
//   final structureString = generarEstructuraString();

//   return PostDocumentModel(
//     estructura: structureString,
//     user: "admin", // luego vendrá del login
//     estado: 1,     // estado inicial = creado
//   );
// }






}
}