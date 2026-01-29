import 'dart:io';

import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/model_views/items_model_view.dart';
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

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.error != null) {
      return Scaffold(
        body: Center(
          child: Text(vm.error!, style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
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
                          vm.toggleCheck(item.idProducto, value ?? false);

                          if (value == true) {
                            final text = vm.controllers[item.idProducto]!.text
                                .trim();

                            if (text.isNotEmpty) {
                              vmInicio.actualizarItem(
                                item.idProducto,
                                detalle: text,
                                completado: true,
                              );
                              vm.moveItemToTop(item.idProducto);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Escribe un detalle antes"),
                                ),
                              );

                              vm.toggleCheck(item.idProducto, false);
                            }
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
                        icon: Icon(Icons.camera_alt, color: Color(0xff134895)),
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
                                      borderRadius: BorderRadius.circular(8),
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
        backgroundColor: Color(0xff134895),
        icon: Icon(Icons.save),
        label: Text("Guardar ítems"),
        onPressed: () {
          final itemsGuardados = vm.items.map((i) {
            final detalle = vm.controllers[i.idProducto]!.text.trim();
            final fotos = vm.fotosPorItem[i.idProducto]!;

            return model.ItemVehiculo(
              idProducto: i.idProducto,
              desProducto: i.desProducto,
              detalle: detalle,
              completado: vm.isChecked[i.idProducto] ?? false,
              fotos: fotos,
            );
          }).toList();

          vmInicio.setItemsAsignados(itemsGuardados);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Ítems guardados")));
        },
      ),
    );
  }
}
