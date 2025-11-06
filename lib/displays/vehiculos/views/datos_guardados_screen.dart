import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart';
import 'package:fl_business/displays/vehiculos/services/ItemsVehiculo_service.dart';
import 'package:flutter/material.dart';

class DatosGuardadosScreen extends StatefulWidget {
  final InicioVehiculosViewModel vm;

  const DatosGuardadosScreen({Key? key, required this.vm}) : super(key: key);

  @override
  State<DatosGuardadosScreen> createState() => _DatosGuardadosScreenState();
}

class _DatosGuardadosScreenState extends State<DatosGuardadosScreen> {
  final ItemVehiculoService _service = ItemVehiculoService();
  late Future<List<ItemVehiculo>> _futureItems;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isChecked = {}; // Para marcar los ítems con detalle
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

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        title: const Text('Datos guardados', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------
            //  Datos del Cliente
            // ---------------------------
            const Text('Datos del Cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _dato('NIT', vm.nit),
            _dato('Nombre', vm.nombre),
            _dato('Dirección', vm.direccion),
            _dato('Celular', vm.celular),
            _dato('Email', vm.email),
            const SizedBox(height: 16),

            // ---------------------------
            //  Datos del Vehículo
            // ---------------------------
            const Text('Datos del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _dato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
            _dato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
            _dato('Modelo (Año)', vm.anioSeleccionado?.anio.toString() ?? '—'),
            _dato('Color', vm.colorSeleccionado?.descripcion ?? '—'),
            const SizedBox(height: 16),

            // ---------------------------
            //  Fechas
            // ---------------------------
            const Text('📅 Fechas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _dato('Fecha recibido', vm.fechaRecibido.isEmpty ? '—' : vm.fechaRecibido),
            _dato('Fecha salida', vm.fechaSalida.isEmpty ? '—' : vm.fechaSalida),
            const SizedBox(height: 16),

            // ---------------------------
            //  Observaciones
            // ---------------------------
            const Text('Observaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _dato('Detalle del trabajo', vm.detalleTrabajo),
            _dato('Kilometraje', vm.kilometraje),
            _dato('CC', vm.cc),
            _dato('CIL', vm.cil),
            const SizedBox(height: 32),

            // ---------------------------
            //  Ítems del vehículo
            // ---------------------------
            const Text('Ítems del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            FutureBuilder<List<ItemVehiculo>>(
              future: _futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay ítems disponibles.');
                }

                _items = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    _controllers.putIfAbsent(item.idProducto, () => TextEditingController());
                    _isChecked.putIfAbsent(item.idProducto, () => false);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('ID: ${item.idProducto}', style: const TextStyle(color: Colors.black54)),
                            TextField(
                              controller: _controllers[item.idProducto],
                              decoration: InputDecoration(
                                labelText: 'Detalle o comentario',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text('$titulo:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(valor.isEmpty ? '—' : valor)),
        ],
      ),
    );
  }
}
