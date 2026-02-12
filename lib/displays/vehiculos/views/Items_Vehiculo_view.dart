import 'dart:io';

import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/model_views/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/views/datos_guardados_view.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsVehiculoScreen extends StatelessWidget {
  const ItemsVehiculoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemsVehiculoViewModel()..loadItems(),
      child: _ItemsVehiculoView(),
    );
  }
}

class _ItemsVehiculoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ItemsVehiculoViewModel>(context);
    final vmInicio = Provider.of<model.InicioVehiculosViewModel>(
      context,
      listen: false,
    );

    // if (vm.isLoading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    if (vm.error != null) {
      return Scaffold(
        body: Center(
          child: Text(vm.error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Ítems del Vehículo"),
            backgroundColor: Color(0xff134895),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index];

              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------ Título + Check ----------------
                      Row(
                        children: [
                          Icon(Icons.inventory_2, color: Color(0xff134895)),
                          SizedBox(width: 8),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.desProducto,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Producto: ${item.producto}   |   ID: ${item.idProducto}",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Checkbox(
                            value: vm.isChecked[item.idProducto] ?? false,
                            onChanged: (value) {
                              // 1. Actualizar estado local
                              vm.toggleCheck(item.idProducto, value ?? false);

                              // 2. Obtener el texto actual
                              final text = vm.controllers[item.idProducto]!.text
                                  .trim();

                              if (value == true) {
                                // ✅ MARCAR CHECKBOX
                                if (text.isNotEmpty) {
                                  // Actualizar o crear ítem en InicioVehiculosViewModel
                                  final index = vmInicio.itemsAsignados
                                      .indexWhere(
                                        (item) =>
                                            item.idProducto == item.idProducto,
                                      );

                                  if (index != -1) {
                                    vmInicio.itemsAsignados[index].completado =
                                        true;
                                    vmInicio.itemsAsignados[index].detalle =
                                        text;
                                  } else {
                                    vmInicio.itemsAsignados.add(
                                      model.ItemVehiculo(
                                        idProducto: item.idProducto,
                                        desProducto: item.desProducto,
                                        detalle: text,
                                        completado: true,
                                        fotos:
                                            vm.fotosPorItem[item.idProducto] ??
                                            [],
                                      ),
                                    );
                                  }

                                  vm.moveItemToTop(item.idProducto);
                                  vmInicio.notifyListeners();
                                } else {
                                  // No puede marcar sin detalle
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Escribe un detalle antes"),
                                    ),
                                  );
                                  vm.toggleCheck(item.idProducto, false);
                                }
                              } else {
                                // ✅ DESMARCAR CHECKBOX
                                final index = vmInicio.itemsAsignados
                                    .indexWhere(
                                      (i) => i.idProducto == item.idProducto,
                                    );

                                if (index != -1) {
                                  // Opción 1: Marcar como NO completado (conserva detalle y fotos)
                                  vmInicio.itemsAsignados[index].completado =
                                      false;

                                  // Opción 2: Eliminar el ítem completamente (si prefieres)
                                  // vmInicio.itemsAsignados.removeAt(index);
                                }

                                vmInicio.notifyListeners();
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: vm.controllers[item.idProducto],
                        decoration: InputDecoration(
                          labelText: 'Detalle',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () => vm.limpiarDetalle(item.idProducto),
                          ),
                        ),
                        maxLines: 2,
                      ),

                      // ------------ Fotos ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              color: Color(0xff134895),
                            ),
                            onPressed: () => vm.tomarFoto(item.idProducto),
                          ),
                        ],
                      ),

                      if ((vm.fotosPorItem[item.idProducto] ?? []).isNotEmpty)
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: vm.fotosPorItem[item.idProducto]!
                                .map(
                                  (foto) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(foto),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              vm.eliminarFoto(
                                                item.idProducto,
                                                foto,
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xff134895),
            icon: const Icon(Icons.save),
            label: const Text("Guardar ítems"),
            onPressed: () {
              // 1. Usar getItemsSeleccionados en lugar de TODOS los items
              final itemsSeleccionados = vm.getItemsSeleccionados();

              print('=== GUARDANDO ÍTEMS ===');
              print('Total items en VM: ${vm.items.length}');
              print('Items seleccionados: ${itemsSeleccionados.length}');

              // 2. Limpiar items anteriores
              vmInicio.limpiarItems();

              // 3. Agregar SOLO los seleccionados
              for (var itemData in itemsSeleccionados) {
                print(
                  '  - ${itemData['idProducto']}: completado=${itemData['completado']}',
                );

                vmInicio.itemsAsignados.add(
                  model.ItemVehiculo(
                    idProducto: itemData['idProducto'],
                    desProducto: itemData['desProducto'],
                    detalle: itemData['detalle'],
                    completado:
                        itemData['completado'], // ← USA EL VALOR DEL CHECKBOX
                    fotos: List<String>.from(itemData['fotos']),
                  ),
                );
              }

              vmInicio.notifyListeners();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${itemsSeleccionados.length} ítem(s) guardados',
                  ),
                ),
              );

              // 4. Navegar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatosGuardadosScreen()),
              );
            },
          ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }

  
}
