import 'dart:io';

import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/view_models/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/models/FotosporItemModel.dart';
import 'package:fl_business/displays/vehiculos/services/upload_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
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

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  final ItemVehiculoService _service = ItemVehiculoService();

  List<api.ItemVehiculoApi> items = [];
  String? error;

  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isChecked = {};
  final Map<String, List<String>> fotosPorItem = {};

  final List<TraInternaModel> transaciciones = [];
  final UploadService _uploadService = UploadService();

  // ================================
  //   CARGAR ÍTEMS
  // ================================
  Future<void> loadItems(BuildContext context) async {
    final user = Provider.of<LoginViewModel>(context, listen: false).user;
    final token = Provider.of<LoginViewModel>(context, listen: false).token;

    final empresa = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEmpresa!.empresa;

    final estacionTrabajo = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEstacion!.estacionTrabajo;
    final serie = Provider.of<InicioVehiculosViewModel>(
      context,
      listen: false,
    ).serieSelect!.serieDocumento;

    final MenuViewModel vmMenu = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

    if (transaciciones.isNotEmpty) {
      print("⚠️ loadItems cancelado - ya existen transacciones");
      return;
    }

    print("LOAD ITEMS EJECUTADO");

    try {
      isLoading = true;
      notifyListeners();

      items = await _service.getItemsVehiculo(
        tipoDocumento: vmMenu.documento.toString(),
        serieDocumento: serie!, // Viene de la pantalla de Inicio
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

  Future<void> subirFotosItem({
    required String idProducto,
    required String token,
    required String user,
    context,
  }) async {
    final destinoImagenes = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEmpresa!.uploadLocal;

    try {
      isLoading = true;

      final fotosLocales = fotosPorItem[idProducto] ?? [];

      if (fotosLocales.isEmpty) return;

      final uploadedFiles = await _uploadService.uploadImages(
        imagePaths: fotosLocales,
        token: token,
        user: user,
        urlCarpeta: destinoImagenes, // tu ruta real del server
      );

      //  Guardar nombres SYSTEM en la transacción
      final index = transaciciones.indexWhere(
        (t) => t.producto.productoId == idProducto,
      );

      if (index != -1) {
        transaciciones[index].filesUpload = uploadedFiles.map((e) {
          return TraFileUploadModel(system: e.system, original: e.original);
        }).toList();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  //   MOVER ÍTEM ARRIBA
  // ================================
  void moveItemToTop(String idProducto) {
    final index = items.indexWhere((i) => i.idProducto == idProducto);
    if (index > 0) {
      final item = items.removeAt(index);
      items.insert(0, item);
      notifyListeners();
    }
  }

  // ================================
  //   TOMAR FOTO
  // ================================
  Future<void> tomarFoto(String idProducto) async {
    final picker = ImagePicker();

    /// Aqui Se toma la foto
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    //  Directorio persistente de la app
    final appDir = await getApplicationDocumentsDirectory();

    //  Crear nombre único
    final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final String savedPath = "${appDir.path}/$fileName";

    //  Copiar la foto al directorio persistente
    // Se guarda Localmente
    final File newImage = await File(foto.path).copy(savedPath);

    //  Guardar el path REAL en fotosPorItem
    fotosPorItem[idProducto] ??= [];
    fotosPorItem[idProducto]!.add(newImage.path);

    //  Guardarlo también en la transacción (si lo necesitas después)
    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );

    if (index != -1) {
      transaciciones[index].files ??= [];
      transaciciones[index].files!.add(newImage.path);
    }

    notifyListeners();
  }

  // ================================
  //   ELIMINAR FOTO
  // ================================
  Future<void> eliminarFoto(String idProducto, String pathFoto) async {
    // Quitar del mapa principal
    fotosPorItem[idProducto]?.remove(pathFoto);

    // Quitar de la transacción
    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );

    if (index != -1) {
      transaciciones[index].files?.remove(pathFoto);
    }

    // Borrar archivo físico (si existe)
    final file = File(pathFoto);
    if (await file.exists()) {
      await file.delete();
    }

    notifyListeners();
  }

  // Se sube la foto con el api
  Future<void> subirTodasLasFotos(BuildContext context) async {
    final user = Provider.of<LoginViewModel>(context, listen: false).user;
    final token = Provider.of<LoginViewModel>(context, listen: false).token;
    for (var t in transaciciones) {
      print("Producto: ${t.producto.productoId} | files: ${t.files}");
    }

    try {
      isLoading = true;

      for (var tra in transaciciones.where((t) => t.isChecked == true)) {
        if (tra.files == null || tra.files!.isEmpty) continue;

        final fotosLocales = tra.files!.where((f) => f.contains("/")).toList();

        if (fotosLocales.isEmpty) continue;

        final uploadedFiles = await _uploadService.uploadImages(
          imagePaths: fotosLocales,
          token: token,
          user: user,
          urlCarpeta: r"C:\Archivos\Uploads",
        );
        for (var file in uploadedFiles) {
          print("📸 ORIGINAL: ${file.original}");
          print("🗂 SYSTEM: ${file.system}");
        }
        //Aqui se guarda
        tra.filesUpload = uploadedFiles
            .map(
              (e) => TraFileUploadModel(original: e.original, system: e.system),
            )
            .toList();
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  //   ACTUALIZAR CHECKBOX
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
      // Si tiene texto, sugerir marcar automáticamente (opcional)
      if (texto.isNotEmpty && !isChecked[idProducto]!) {
        isChecked[idProducto] = true;
        transaciciones[index].isChecked = true;
      }
    }

    notifyListeners();
  }

  // ================================
  //   LIMPIAR TEXTO
  // ================================
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

      // Solo incluir si está checkeado O tiene detalle O tiene fotos
      if (checkeado || detalle.isNotEmpty || fotos.isNotEmpty) {
        seleccionados.add({
          'idProducto': item.idProducto,
          'desProducto': item.desProducto,
          'detalle': detalle,
          'completado': checkeado, // ← ¡CRÍTICO!
          'fotos': fotos,
        });
      }
    }

    return seleccionados;
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  ////// Asegurarse que todos los items esten seleccionados
  List<String> obtenerItemsSinCheck() {
    return items
        .where((item) => !(isChecked[item.idProducto] ?? false))
        .map((item) => item.desProducto)
        .toList();
  }

  bool todosLosItemsMarcados() {
    return items.every((item) => isChecked[item.idProducto] ?? false);
  }
}
