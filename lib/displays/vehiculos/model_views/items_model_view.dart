import 'dart:io';

import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart'
    as api;
import 'package:path_provider/path_provider.dart';

class ItemsVehiculoViewModel extends ChangeNotifier {
  final ItemVehiculoService _service = ItemVehiculoService();

  List<api.ItemVehiculoApi> items = [];
  bool isLoading = false;
  String? error;

  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isChecked = {};
  final Map<String, List<String>> fotosPorItem = {};

  final List<TraInternaModel> transaciciones = [];

  // ================================
  //   CARGAR ÍTEMS
  // ================================
  Future<void> loadItems() async {
    try {
      isLoading = true;
      notifyListeners();

      items = await _service.getItemsVehiculo(
        tipoDocumento: '28',
        serieDocumento: '1',
        empresa: '1',
        estacionTrabajo: '2',
      );

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
                files: [],
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
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto == null) return;

    // 📌 Directorio persistente de la app
    final appDir = await getApplicationDocumentsDirectory();

    // 📌 Crear nombre único
    final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final String savedPath = "${appDir.path}/$fileName";

    // 📌 Copiar la foto al directorio persistente
    final File newImage = await File(foto.path).copy(savedPath);

    // 📌 Guardar el path REAL en fotosPorItem
    fotosPorItem[idProducto] ??= [];
    fotosPorItem[idProducto]!.add(newImage.path);

    // 📌 Guardarlo también en la transacción (si lo necesitas después)
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
    }

    notifyListeners();
  }

  // ================================
  //   LIMPIAR TEXTO
  // ================================
  void limpiarDetalle(String idProducto) {
    controllers[idProducto]?.clear();
    isChecked[idProducto] = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
