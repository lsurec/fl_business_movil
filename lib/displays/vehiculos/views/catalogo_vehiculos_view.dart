import 'package:fl_business/displays/vehiculos/model_views/vehiculos_catalogo_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatalogoVehiculosView extends StatelessWidget {
  const CatalogoVehiculosView({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogoVM = context.watch<CatalogoVehiculosViewModel>();
    final vehiculo = catalogoVM.vehiculoSeleccionado;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
  title: const Text('Catálogo de Vehículos',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white) ),
  actions: [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        context.read<CatalogoVehiculosViewModel>().limpiarSeleccion();
      },
    ),
  ],
),


      // 🔹 BARRA LATERAL DERECHA (PLACAS)
      endDrawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xff134895)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Vehículos registrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: catalogoVM.vehiculos.isEmpty
                  ? const Center(
                      child: Text('No hay vehículos registrados'),
                    )
                  : ListView.builder(
                      itemCount: catalogoVM.vehiculos.length,
                      itemBuilder: (_, index) {
                        final v = catalogoVM.vehiculos[index];
                        return ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text(v.placa),
                          subtitle: Text('${v.marca} ${v.modelo}'),
                          onTap: () {
                            catalogoVM.seleccionarVehiculo(v);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // 🔹 CONTENIDO PRINCIPAL
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Color(0xff134895),
              width: double.infinity,
              child: const Text(
                'DATOS DEL VEHÍCULO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Table(
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(300),
              },
              children: [
                _buildTableRow('Descripcion', ''),
                _buildTableRow('ID', ''),
                _buildTableRow('Estado', 'Activo'),
                _buildTableRow('Pagina', '1'),
                _buildTableRow('Secuencia', '1'),
                _buildTableRow('Orden', '1'),
                _buildTableRow('Marca', vehiculo?.marca ?? ''),
                _buildTableRow('Modelo', vehiculo?.modelo ?? ''),
                _buildTableRow('Año', vehiculo?.anio.toString() ?? ''),
                _buildTableRow('Seccion', ''),
                _buildTableRow('Color', vehiculo?.color ?? ''),
                _buildTableRow('Placa', vehiculo?.placa ?? ''),
                _buildTableRow('Chasis', vehiculo?.chasis ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(value.isEmpty ? '—' : value),
          ),
        ),
      ],
    );
  }
}
