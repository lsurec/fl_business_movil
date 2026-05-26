import 'dart:io';

import 'package:fl_business/displays/vehiculos/view_models/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/view_models/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/views/datos_guardados_view.dart';
import 'package:fl_business/displays/vehiculos/views/vista_Imagenes_view.dart';
import 'package:fl_business/displays/vehiculos/views/widgets/CustomCheckSwitch.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemsVehiculoScreen extends StatefulWidget {
  const ItemsVehiculoScreen({super.key});

  @override
  State<ItemsVehiculoScreen> createState() => _ItemsVehiculoScreenState();
}

class _ItemsVehiculoScreenState extends State<ItemsVehiculoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ItemsVehiculoViewModel>().recuperarImagenPerdida();
    });
    // ✅ Cargamos los datos de manera segura al iniciar la pantalla
    final vm = context.read<ItemsVehiculoViewModel>();
    if (vm.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.loadItems(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ItemsVehiculoView();
  }
}

class _ItemsVehiculoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Escuchamos los cambios de este VM para redibujar la lista, fotos, etc.
    final vm = Provider.of<ItemsVehiculoViewModel>(context);

    // ✅ Usamos listen: false porque solo necesitamos invocar sus métodos al guardar
    final vmInicio = Provider.of<model.InicioVehiculosViewModel>(
      context,
      listen: false,
    );

    if (vm.error != null) {
      return Scaffold(
        body: Center(
          child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
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
            backgroundColor: const Color(0xff134895),
          ),
          body: ListView.builder(
            cacheExtent: 300,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
            itemCount: vm.items.length,
            itemBuilder: (context, index) {
              final item = vm.items[index];
              final idProducto = item.idProducto;
              final fotos = vm.fotosPorItem[idProducto] ?? [];
              final fotosVisibles = fotos.length > 3
                  ? fotos.sublist(0, 3)
                  : fotos;

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
                          const Icon(Icons.add_task, color: Color(0xff134895)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.desProducto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Producto: ${item.producto}   |   ID: $idProducto",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomCheckSwitch(
                            value: vm.isChecked[idProducto] ?? false,
                            onChanged: (nuevoValor) {
                              // Lógica simplificada: La vista solo avisa al VM del cambio.
                              vm.toggleCheck(idProducto, nuevoValor);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ------------ Campo de Texto ----------------
                      TextField(
                        controller: vm.controllers[idProducto],
                        decoration: InputDecoration(
                          labelText: t.translate(
                            BlockTranslate.vehiculos,
                            'itemsVehiculo_escribeDetalle',
                          ),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => vm.limpiarDetalle(idProducto),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),

                      // ------------ Sección de Fotos ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Imágenes: ",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${fotos.length}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff134895),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xff134895),
                            ),
                            onPressed: () => vm.tomarFoto(context, idProducto),
                          ),
                        ],
                      ),

                      if (fotos.isNotEmpty)
                        Column(
                          children: fotos.map((foto) {
                            return ListTile(
                              dense: true,

                              leading: const Icon(Icons.image),

                              title: Text(
                                foto.split('/').last,
                                overflow: TextOverflow.ellipsis,
                              ),

                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // VER IMAGEN
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VistaImagenScreen(
                                            imagePath: foto,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // ELIMINAR DE LA LISTA
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      vm.fotosPorItem[idProducto]?.remove(foto);

                                      vm.notifyListeners();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      // if (fotos.length > 3)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 4),
                      //     child: Text(
                      //       "+${fotos.length - 3} fotos más",
                      //       style: const TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ------------ Botón Guardar ----------------
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xff134895),
            icon: const Icon(Icons.save),
            label: Text(
              t.translate(
                BlockTranslate.vehiculos,
                'itemsVehiculo_guardarItems',
              ),
            ),
            onPressed: () async {
              // 1. Validar ítems pendientes
              if (!vm.todosLosItemsMarcados()) {
                final itemsFaltantes = vm.obtenerItemsSinCheck();
                _mostrarDialogoPendientes(context, itemsFaltantes);
                return;
              }

              // final fotosOk = await vm.subirTodasLasFotos(context);

              // if (!fotosOk) {
              //   NotificationService.showSnackbar("Error al subir imágenes");
              //   return;
              // }

              // 2. Si todo está correcto, procesar en el ViewModel de Inicio
              final itemsSeleccionados = vm.getItemsSeleccionados();
              vmInicio.limpiarItems();

              for (var itemData in itemsSeleccionados) {
                vmInicio.itemsAsignados.add(
                  model.ItemVehiculo(
                    idProducto: itemData['idProducto'],
                    desProducto: itemData['desProducto'],
                    detalle: itemData['detalle'] ?? '',
                    completado: itemData['completado'] ?? false,
                    fotos: List<String>.from(itemData['fotos'] ?? []),
                  ),
                );
              }

              vmInicio.notifyListeners();

              // 3. Feedback y Navegación
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${itemsSeleccionados.length} ítem(s) guardados correctamente',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatosGuardadosScreen()),
              );
            },
          ),
        ),

        // ------------ Capa de Carga (Loading) ----------------
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }

  Widget _construirIndicadorEstado(String? estado) {
    switch (estado) {
      case 'uploading':
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.orange,
          ),
        );
      case 'success':
        return const Icon(Icons.check_circle, size: 14, color: Colors.green);
      case 'error':
        return const Icon(Icons.error, size: 14, color: Colors.red);
      default:
        return const Icon(
          Icons.access_time_filled,
          size: 14,
          color: Colors.grey,
        ); // waiting
    }
  }

  // ✅ Extracción del Diálogo para mejorar legibilidad de la vista
  void _mostrarDialogoPendientes(
    BuildContext context,
    List<String> itemsFaltantes,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ítems pendientes de revisar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Debes Revisar todos los ítems antes de continuar:'),
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
  }
}
