import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart';
import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';
import 'package:flutter/material.dart';

class ItemsVehiculoScreen extends StatefulWidget {
  const ItemsVehiculoScreen({Key? key}) : super(key: key);

  @override
  State<ItemsVehiculoScreen> createState() => _ItemsVehiculoScreenState();
}

class _ItemsVehiculoScreenState extends State<ItemsVehiculoScreen> {
  final ItemVehiculoService _service = ItemVehiculoService();
  late Future<List<ItemVehiculo>> _futureItems;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isChecked = {}; // 🔹 Control del “check”
  List<ItemVehiculo> _items = [];

  @override
  void initState() {
    super.initState();
    _futureItems = _loadItems();
  }

  Future<List<ItemVehiculo>> _loadItems() async {
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJhZG1pbiIsIm5iZiI6MTc2MTE3MDU3NywiZXhwIjoxNzkyMjc0NTc3LCJpYXQiOjE3NjExNzA1Nzd9.3BXM8Usk7wUHvsV4LX3S7pOl3Hvr_Z9LenkH4vgvOek'; // tu token aquí
    final items = await _service.getItemsVehiculo(
      token: token,
      userName: 'sa',
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

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        title: const Text('Ítems del Vehículo', style: TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<List<ItemVehiculo>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('❌ Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
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

              _controllers.putIfAbsent(item.idProducto, () => TextEditingController());
              _isChecked.putIfAbsent(item.idProducto, () => false);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_rounded, color: Color(0xff134895)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.desProducto,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Checkbox(
                            value: _isChecked[item.idProducto],
                            onChanged: (value) {
                              setState(() {
                                _isChecked[item.idProducto] = value ?? false;
                              });

                              // Solo mover cuando el usuario marca el check
                              if (value == true) {
                                final text = _controllers[item.idProducto]?.text.trim() ?? '';
                                if (text.isNotEmpty) {
                                  _moveItemToTop(item.idProducto);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('⚠️ Escribe un detalle antes de marcar como listo.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  setState(() {
                                    _isChecked[item.idProducto] = false;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('ID: ${item.idProducto}', style: const TextStyle(color: Colors.black54)),
                      Text('Precio: ${item.precioUnidad.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 10),

                      // Campo de detalle
                      TextField(
                        controller: _controllers[item.idProducto],
                        decoration: InputDecoration(
                          labelText: 'Detalle o comentario',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controllers[item.idProducto]?.clear();
                              setState(() {
                                _isChecked[item.idProducto] = false;
                              });
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
        onPressed: _mostrarDetallesGuardados,
        icon: const Icon(Icons.save_alt),
        label: const Text('Ver detalles escritos'),
        backgroundColor: const Color(0xff134895),
      ),
    );
  }

  void _mostrarDetallesGuardados() {
    final detalles = _controllers.entries
        .where((e) => e.value.text.trim().isNotEmpty)
        .map((e) => '${e.key}: ${e.value.text}')
        .join('\n\n');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detalles escritos'),
        content: Text(detalles.isEmpty ? 'No hay detalles ingresados.' : detalles),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
