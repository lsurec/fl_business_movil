import 'dart:io';

import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/view_models/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/models/FotosporItemModel.dart';
import 'package:fl_business/displays/vehiculos/services/upload_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart'
    as api;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ItemsVehiculoViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ImagePicker _picker = ImagePicker();

  final ItemVehiculoService _service = ItemVehiculoService();
  final UploadService _uploadService = UploadService();

  List<api.ItemVehiculoApi> items = [];
  String? error;

  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isChecked = {};
  final Map<String, List<String>> fotosPorItem = {};
  final Map<String, String> estadoFotos = {};
  final List<TraInternaModel> transaciciones = [];

  Future<void> recuperarImagenPerdida() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) return;
    if (response.files != null) {
      for (final file in response.files!) {
        print("Imagen recuperada: ${file.path}");
      }
    }
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ================================
  //   CARGAR ÍTEMS
  // ================================
  Future<void> loadItems(BuildContext context) async {
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final settingsVM = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    );
    final inicioVM = Provider.of<InicioVehiculosViewModel>(
      context,
      listen: false,
    );
    final vmMenu = Provider.of<MenuViewModel>(context, listen: false);

    final user = loginVM.user;
    final token = loginVM.token;
    final empresa = settingsVM.selectedEmpresa!.empresa;
    final estacionTrabajo = settingsVM.selectedEstacion!.estacionTrabajo;
    final serie = inicioVM.serieSelect!.serieDocumento;

    if (transaciciones.isNotEmpty) {
      print("loadItems cancelado - ya existen transacciones");
      return;
    }

    try {
      isLoading = true;

      items = await _service.getItemsVehiculo(
        tipoDocumento: vmMenu.documento.toString(),
        serieDocumento: serie!,
        empresa: empresa.toString(),
        estacionTrabajo: estacionTrabajo.toString(),
        token: token,
        user: user,
      );

      final Map<String, List<String>> fotosGuardadas = {};
      for (var t in transaciciones) {
        fotosGuardadas[t.producto.productoId] = t.files ?? [];
      }

      transaciciones.clear();
      transaciciones.addAll(
        items
            .map(
              (item) => TraInternaModel(
                isChecked: false,
                producto: ProductModel(
                  id: item.producto,
                  producto: item.producto,
                  unidadMedida: item.unidadMedida,
                  productoId: item.idProducto,
                  desProducto: item.desProducto,
                  desUnidadMedida: item.desUnidadMedida,
                  tipoProducto: item.tipoProducto,
                  orden: 0,
                  rows: 0,
                ),
                precio: UnitarioModel(
                  id: item.tipoPrecio,
                  precioU: item.precioUnidad,
                  descripcion: '',
                  precio: true,
                  moneda: item.moneda,
                  orden: 0,
                ),
                cantidad: 1,
                total: item.precioUnidad * 1,
                descuento: 0,
                cargo: 0,
                operaciones: [],
                bodega: BodegaProductoModel(
                  bodega: item.bodega,
                  nombre: item.nomBodega,
                  existencia: 1,
                  poseeComponente: false,
                  orden: 1,
                ),
                cantidadDias: 0,
                precioDia: 0,
                precioCantidad: 0,
                consecutivo: 0,
                estadoTra: 1,
                observacion: '',
                files: fotosGuardadas[item.idProducto] ?? [],
              ),
            )
            .toList(),
      );

      for (var item in items) {
        controllers[item.idProducto] = TextEditingController();
        isChecked[item.idProducto] = false;
        fotosPorItem[item.idProducto] = [];
      }

      error = null;
    } catch (e) {
      error = "Error: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  //   TOMAR FOTO (OPTIMIZADO PARA EVITAR PANTALLA NEGRA)
  // ================================
  Future<void> tomarFoto(BuildContext context, String idProducto) async {
    try {
      // 1. Bajamos sutilmente las dimensiones para un alivio drástico de RAM gráfica
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,

        // calidad alta
        imageQuality: 90,

        // tamaño razonable
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (foto == null) return;

      final destinoImagenes = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      ).selectedEmpresa!.uploadLocal;

      if (destinoImagenes == null || destinoImagenes.isEmpty) {
        NotificationService.showSnackbar("No se configuró uploadLocal");
        return;
      }

      // 2. Ruta persistente local
      final appDir = await getApplicationDocumentsDirectory();
      final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String savedPath = "${appDir.path}/$fileName";

      //  OPTIMIZACIÓN CLAVE: Mover el archivo en vez de copiarlo evita duplicar la RAM de la foto actual
      final File savedImage = await File(foto.path).copy(savedPath);

      // 4. Actualizar colecciones de inmediato
      fotosPorItem[idProducto] ??= [];
      fotosPorItem[idProducto]!.add(savedImage.path);
      estadoFotos[savedImage.path] = "waiting";

      final index = transaciciones.indexWhere(
        (t) => t.producto.productoId == idProducto,
      );
      if (index != -1) {
        transaciciones[index].files ??= [];
        transaciciones[index].files!.add(savedImage.path);

        // Auto-marcar el ítem al tomarle una foto si no está checkeado
        if (!(isChecked[idProducto] ?? false)) {
          isChecked[idProducto] = true;
          transaciciones[index].isChecked = true;
        }
      }

      // 5.  LIMPIEZA INMEDIATA DE CACHÉ GRÁFICA NATIVA

      Future.microtask(() {
        notifyListeners();
      });
      _subirFotoIndividual(
        context: context,
        idProducto: idProducto,
        imagePath: savedImage.path,
      );
    } catch (e, stack) {
      print("ERROR CRÍTICO AL TOMAR FOTO: $e");
      print(stack);
      NotificationService.showSnackbar("Error crítico en la cámara");
    }
  }

  // ==========================================
  //   LÓGICA INTERNA DE LA COLA DE SUBIDA
  // ==========================================
  // void _enconlarSubida({
  //   required String idProducto,
  //   required String imagePath,
  //   required String token,
  //   required String user,
  //   required String destinoImagenes,
  // }) {
  //   _uploadQueue.add({
  //     'idProducto': idProducto,
  //     'imagePath': imagePath,
  //     'token': token,
  //     'user': user,
  //     'destinoImagenes': destinoImagenes,
  //   });

  //   _procesarCola();
  // }

  // Future<void> _procesarCola() async {
  //   if (_isProcessingQueue) return;
  //   _isProcessingQueue = true;

  //   while (_uploadQueue.isNotEmpty) {
  //     final tarea = _uploadQueue.removeAt(0);
  //     final String currentPath = tarea['imagePath'];
  //     final String currentId = tarea['idProducto'];

  //     try {
  //       estadoFotos[currentPath] = "uploading";
  //       notifyListeners();

  //       final uploadedFiles = await _uploadService.uploadImages(
  //         imagePaths: [currentPath],
  //         token: tarea['token'],
  //         user: tarea['user'],
  //         urlCarpeta: tarea['destinoImagenes'],
  //       );

  //       final index = transaciciones.indexWhere(
  //         (t) => t.producto.productoId == currentId,
  //       );
  //       if (index != -1 && uploadedFiles.isNotEmpty) {
  //         transaciciones[index].filesUpload ??= [];
  //         transaciciones[index].filesUpload!.addAll(
  //           uploadedFiles.map(
  //             (e) => TraFileUploadModel(system: e.system, original: e.original),
  //           ),
  //         );
  //       }

  //       estadoFotos[currentPath] = "success";
  //     } catch (e) {
  //       print("Error en cola al subir imagen: $e");
  //       estadoFotos[currentPath] = "error";
  //     } finally {
  //       notifyListeners();
  //     }
  //   }

  //   _isProcessingQueue = false;
  // }

  Future<void> _subirFotoIndividual({
    required BuildContext context,
    required String idProducto,
    required String imagePath,
  }) async {
    try {
      estadoFotos[imagePath] = "uploading";
      notifyListeners();

      final user = Provider.of<LoginViewModel>(context, listen: false).user;

      final token = Provider.of<LoginViewModel>(context, listen: false).token;

      final destinoImagenes = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      ).selectedEmpresa!.uploadLocal;
      print("urlCarpeta: $destinoImagenes");
      final uploadedFiles = await _uploadService.uploadImages(
        imagePaths: [imagePath],
        token: token,
        user: user,
        urlCarpeta: destinoImagenes!,
      );

      if (uploadedFiles.isEmpty) {
        estadoFotos[imagePath] = "error";
        notifyListeners();
        return;
      }

      final index = transaciciones.indexWhere(
        (t) => t.producto.productoId == idProducto,
      );

      if (index != -1) {
        transaciciones[index].filesUpload ??= [];

        transaciciones[index].filesUpload!.addAll(
          uploadedFiles.map(
            (e) => TraFileUploadModel(system: e.system, original: e.original),
          ),
        );
      }

      estadoFotos[imagePath] = "success";

      // OPCIONAL:
      // borrar foto local luego de subir
      // final file = File(imagePath);

      // if (await file.exists()) {
      //   await file.delete();
      // }
    } catch (e) {
      print("ERROR SUBIENDO FOTO: $e");

      estadoFotos[imagePath] = "error";
    }

    notifyListeners();
  }

  // ================================
  //   REINTENTAR SUBIDA
  // ================================
  Future<void> reintentarSubida(
    BuildContext context,
    String idProducto,
    String imagePath,
  ) async {
    try {
      estadoFotos[imagePath] = "uploading";
      notifyListeners();

      final user = Provider.of<LoginViewModel>(context, listen: false).user;
      final token = Provider.of<LoginViewModel>(context, listen: false).token;
      final destinoImagenes = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      ).selectedEmpresa!.uploadLocal;

      final uploadedFiles = await _uploadService.uploadImages(
        imagePaths: [imagePath],
        token: token,
        user: user,
        urlCarpeta: destinoImagenes!,
      );

      final index = transaciciones.indexWhere(
        (t) => t.producto.productoId == idProducto,
      );
      if (index != -1) {
        transaciciones[index].filesUpload ??= [];
        transaciciones[index].filesUpload!.addAll(
          uploadedFiles.map(
            (e) => TraFileUploadModel(system: e.system, original: e.original),
          ),
        );
      }

      estadoFotos[imagePath] = "success";
    } catch (e) {
      estadoFotos[imagePath] = "error";
    }
    notifyListeners();
  }

  // ================================
  //   ELIMINAR FOTO
  // ================================
  Future<void> eliminarFoto(String idProducto, String pathFoto) async {
    fotosPorItem[idProducto]?.remove(pathFoto);
    estadoFotos.remove(pathFoto); // Limpiar rastro de estados

    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );
    if (index != -1) {
      transaciciones[index].files?.remove(pathFoto);
    }

    final file = File(pathFoto);
    if (await file.exists()) {
      await file.delete();
    }

    notifyListeners();
  }

  // ================================
  //   ACTUALIZAR OBSERVACIONES Y CHECKS
  // ================================
  void toggleCheck(String idProducto, bool value) {
    isChecked[idProducto] = value;
    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );
    if (index != -1) {
      transaciciones[index].isChecked = value;
      transaciciones[index].observacion =
          controllers[idProducto]?.text.trim() ?? '';
    }
    notifyListeners();
  }

  void actualizarObservacion(String idProducto, String texto) {
    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );
    if (index != -1) {
      transaciciones[index].observacion = texto;
      if (texto.isNotEmpty && !isChecked[idProducto]!) {
        isChecked[idProducto] = true;
        transaciciones[index].isChecked = true;
      }
    }
    notifyListeners();
  }

  void limpiarDetalle(String idProducto) {
    controllers[idProducto]?.clear();
    isChecked[idProducto] = false;
    fotosPorItem[idProducto]?.clear();

    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );
    if (index != -1) {
      transaciciones[index].isChecked = false;
      transaciciones[index].observacion = '';
      transaciciones[index].files?.clear();
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> getItemsSeleccionados() {
    List<Map<String, dynamic>> seleccionados = [];
    for (var item in items) {
      final detalle = controllers[item.idProducto]?.text.trim() ?? '';
      final checkeado = isChecked[item.idProducto] ?? false;
      final fotos = fotosPorItem[item.idProducto] ?? [];

      if (checkeado || detalle.isNotEmpty || fotos.isNotEmpty) {
        seleccionados.add({
          'idProducto': item.idProducto,
          'desProducto': item.desProducto,
          'detalle': detalle,
          'completado': checkeado,
          'fotos': fotos,
        });
      }
    }
    return seleccionados;
  }

  List<String> obtenerItemsSinCheck() {
    return items
        .where((item) => !(isChecked[item.idProducto] ?? false))
        .map((item) => item.desProducto)
        .toList();
  }

  bool todosLosItemsMarcados() {
    return items.every((item) => isChecked[item.idProducto] ?? false);
  }

  Future<void> limpiarDatosItems() async {
    for (var idProducto in controllers.keys) {
      controllers[idProducto]?.clear();
      isChecked[idProducto] = false;
    }

    for (var fotos in fotosPorItem.values) {
      for (var path in fotos) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    fotosPorItem.clear();
    estadoFotos.clear();

    for (var tra in transaciciones) {
      tra.isChecked = false;
      tra.observacion = '';
      tra.files?.clear();
      tra.filesUpload?.clear();
    }
    transaciciones.clear();
    items.clear();
    error = null;
    notifyListeners();
  }
}
