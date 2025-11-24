import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart'
    as api;

import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';

class ItemsVehiculoScreen extends StatefulWidget {
  const ItemsVehiculoScreen({Key? key}) : super(key: key);

  @override
  State<ItemsVehiculoScreen> createState() => _ItemsVehiculoScreenState();
}

class _ItemsVehiculoScreenState extends State<ItemsVehiculoScreen> {
  final ItemVehiculoService _service = ItemVehiculoService();
  late Future<List<api.ItemVehiculoApi>> _futureItems;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isChecked = {};
  List<api.ItemVehiculoApi> _items = [];
  final Map<String, List<XFile>> _fotosPorItem = {};

  @override
  void initState() {
    super.initState();
    _futureItems = _loadItems();
  }

  Future<List<api.ItemVehiculoApi>> _loadItems() async {
  final items = await _service.getItemsVehiculo(
    tipoDocumento: '28',
    serieDocumento: '1',
    empresa: '1',
    estacionTrabajo: '2',
  );

  _items = items;
  return items;
}


  void _moveItemToTop(String idProducto) {
    final index = _items.indexWhere((i) => i.idProducto == idProducto);
    if (index > 0) {
      final item = _items.removeAt(index);
      _items.insert(0, item);
      setState(() {});
    }
  }

  Future<void> _tomarFoto(String idProducto) async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.camera);

    if (foto != null) {
      setState(() {
        if (_fotosPorItem[idProducto] == null) {
          _fotosPorItem[idProducto] = [];
        }
        _fotosPorItem[idProducto]!.add(foto);
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<model.InicioVehiculosViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        title: const Text(
          'Ítems del Vehículo',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<api.ItemVehiculoApi>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                '❌ Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay ítems disponibles'));
          }

          if (_items.isEmpty) {
            _items = snapshot.data!;
          }

          return ListView.builder(
            itemCount: _items.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final item = _items[index];

              _controllers.putIfAbsent(
                item.idProducto,
                () => TextEditingController(),
              );
              _isChecked.putIfAbsent(item.idProducto, () => false);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_rounded,
                            color: Color(0xff134895),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.desProducto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Checkbox(
                            value: _isChecked[item.idProducto],
                            onChanged: (value) {
                              setState(() {
                                _isChecked[item.idProducto] = value ?? false;
                              });

                              if (value == true) {
                                final text =
                                    _controllers[item.idProducto]?.text
                                        .trim() ??
                                    '';
                                if (text.isNotEmpty) {
                                  vm.actualizarItem(
                                    item.idProducto,
                                    detalle: text,
                                    completado: true,
                                  );
                                  _moveItemToTop(item.idProducto);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '⚠️ Escribe un detalle antes de marcar como listo.',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    _isChecked[item.idProducto] = false;
                                  });
                                }
                              } else {
                                vm.actualizarItem(
                                  item.idProducto,
                                  completado: false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${item.idProducto}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Descripción: ${item.desProducto}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        'Código Producto: ${item.producto}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Color(0xff134895),
                            ),
                            onPressed: () => _tomarFoto(item.idProducto),
                          ),
                        ],
                      ),
                      if (_fotosPorItem[item.idProducto]?.isNotEmpty ?? false)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _fotosPorItem[item.idProducto]!.length,
                            itemBuilder: (context, fotoIndex) {
                              final foto =
                                  _fotosPorItem[item.idProducto]![fotoIndex];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Image.file(
                                  File(foto.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 10),
                      TextField(
                        controller: _controllers[item.idProducto],
                        decoration: InputDecoration(
                          labelText: 'Detalle o comentario',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controllers[item.idProducto]?.clear();
                              setState(() {
                                _isChecked[item.idProducto] = false;
                              });
                              vm.actualizarItem(
                                item.idProducto,
                                detalle: '',
                                completado: false,
                              );
                            },
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final itemsGuardados = _items.map((apiItem) {
            final detalle = _controllers[apiItem.idProducto]?.text.trim() ?? '';
            final fotos = _fotosPorItem[apiItem.idProducto] ?? [];


            return model.ItemVehiculo(
              idProducto: apiItem.idProducto,
              desProducto: apiItem.desProducto,
              detalle: detalle,
              completado: _isChecked[apiItem.idProducto] ?? false,
              fotos: fotos, // 👈 ahora sí guardamos las fotos
            );
          }).toList();

          vm.setItemsAsignados(itemsGuardados);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ítems guardados correctamente ✅')),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar ítems'),
        backgroundColor: const Color(0xff134895),
      ),
    );
  }
}
