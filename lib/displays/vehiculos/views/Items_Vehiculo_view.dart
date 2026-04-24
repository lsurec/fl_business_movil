import 'dart:io';

import 'package:fl_business/displays/vehiculos/view_models/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/view_models/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/views/datos_guardados_view.dart';
import 'package:fl_business/displays/vehiculos/views/widgets/CustomCheckSwitch.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsVehiculoScreen extends StatelessWidget {
  const ItemsVehiculoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ItemsVehiculoViewModel>();

    // Solo cargar si está vacío
    if (vm.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadItems(context);
      });
    }

    return _ItemsVehiculoView();
  }
}

class _ItemsVehiculoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
            title: Text(
              '${t.translate(BlockTranslate.vehiculos, 'itemsVehiculo_titulo')}  (${vm.items.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xff134895),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
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
                          Icon(Icons.add_task, color: Color(0xff134895)),
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

                          CustomCheckSwitch(
                            value: vm.isChecked[item.idProducto] ?? false,
                            onChanged: (nuevoValor) {
                              // 1. Actualizar estado local
                              vm.toggleCheck(item.idProducto, nuevoValor);

                              // 2. Obtener el texto actual (puede estar vacío)
                              final text =
                                  vm.controllers[item.idProducto]?.text
                                      .trim() ??
                                  '';

                              if (nuevoValor) {
                                // ✅ MARCAR COMO COMPLETADO
                                final index = vmInicio.itemsAsignados
                                    .indexWhere(
                                      (i) => i.idProducto == item.idProducto,
                                    );

                                if (index != -1) {
                                  vmInicio.itemsAsignados[index].completado =
                                      true;
                                  vmInicio.itemsAsignados[index].detalle = text;
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
                              } else {
                                // ❌ MARCAR COMO NO COMPLETADO
                                final index = vmInicio.itemsAsignados
                                    .indexWhere(
                                      (i) => i.idProducto == item.idProducto,
                                    );

                                if (index != -1) {
                                  vmInicio.itemsAsignados[index].completado =
                                      false;
                                }
                              }

                              vmInicio.notifyListeners();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: vm.controllers[item.idProducto],
                        decoration: InputDecoration(
                          labelText: t.translate(
                            BlockTranslate.vehiculos,
                            'itemsVehiculo_escribeDetalle',
                          ),

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
            label: Text(
              t.translate(
                BlockTranslate.vehiculos,
                'itemsVehiculo_guardarItems',
              ),
            ),

            onPressed: () {
              // 1. Validar si todos los ítems están marcados
              if (!vm.todosLosItemsMarcados()) {
                final itemsFaltantes = vm.obtenerItemsSinCheck();

                // Mostrar mensaje con los ítems faltantes
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Ítems pendientes De Revisar'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            const Text(
                              'Debes Revisar todos los ítems antes de continuar:',
                            ),
                            const SizedBox(height: 10),
                            ...itemsFaltantes.map((item) => Text('• $item')),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Aceptar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
                return; // ❌ No continuar con el guardado ni la navegación
              }

              // 2. Si todos están marcados, proceder con el guardado
              final itemsSeleccionados = vm.getItemsSeleccionados();

              // print('=== GUARDANDO ÍTEMS ===');
              // print('Total items en VM: ${vm.items.length}');
              // print('Items seleccionados: ${itemsSeleccionados.length}');

              // 3. Limpiar items anteriores
              vmInicio.limpiarItems();

              // 4. Agregar los ítems seleccionados
              for (var itemData in itemsSeleccionados) {
                vmInicio.itemsAsignados.add(
                  model.ItemVehiculo(
                    idProducto: itemData['idProducto'],
                    desProducto: itemData['desProducto'],
                    detalle: itemData['detalle'],
                    completado: itemData['completado'],
                    fotos: List<String>.from(itemData['fotos']),
                  ),
                );
              }

              vmInicio.notifyListeners();

              // 5. Mostrar confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${itemsSeleccionados.length} ítem(s) guardados correctamente',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              // 6. Navegar a la siguiente pantalla
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
