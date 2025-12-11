import 'dart:io';

import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart'
    as api;

class ItemsVehiculoViewModel extends ChangeNotifier {
  final ItemVehiculoService _service = ItemVehiculoService();

  List<api.ItemVehiculoApi> items = [];
  bool isLoading = false;
  String? error;

  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isChecked = {};
  final Map<String, List<XFile>> fotosPorItem = {};

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
                  desUnidadMedida: '',
                  tipoProducto: 1,
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
                  nombre: '',
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

    // Obtener objeto transacción según idProducto
    final index = transaciciones.indexWhere(
      (t) => t.producto.productoId == idProducto,
    );

    if (index == -1) return;

    // Ruta original de la foto
    final String originalPath = foto.path;

    // Crear un nombre único para almacenar el path
    final String newPath = "${originalPath}_ref";

    // Guardar solo el path dentro del modelo
    transaciciones[index].files ??= [];
    transaciciones[index].files!.add(newPath);

    // Borrar archivo original
    final file = File(originalPath);
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
