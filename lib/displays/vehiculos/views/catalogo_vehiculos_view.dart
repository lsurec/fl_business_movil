import 'package:fl_business/displays/vehiculos/model_views/vehiculos_catalogo_viewmodel.dart';
import 'package:fl_business/models/elemento_asignado_model.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/elemento_asignado_view_model.dart';
import 'package:fl_business/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatalogoVehiculosView extends StatefulWidget {
  const CatalogoVehiculosView({super.key});

  @override
  State<CatalogoVehiculosView> createState() => _CatalogoVehiculosViewState();
}

class _CatalogoVehiculosViewState extends State<CatalogoVehiculosView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vehiculoVM = context.read<CatalogoVehiculosViewModel>();

      await vehiculoVM.cargarMarcas();

      final elemento = context.read<ElementoAsigandoViewModel>().elemento;
      if (elemento?.marca != null) {
        await vehiculoVM.cargarModelos(elemento!.marca!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ElementoAsigandoViewModel vm = Provider.of<ElementoAsigandoViewModel>(
      context,
    );

    final vehiculoVM = context.watch<CatalogoVehiculosViewModel>();

    final elemento = vm.elemento;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        title: const Text(
          'Catálogo de Vehículos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              context.read<CatalogoVehiculosViewModel>().limpiarSeleccion();
            },
          ),
        ],
      ),

      // 🔹 BARRA LATERAL DERECHA
      endDrawer: Drawer(
        child: Column(
          children: const [
            DrawerHeader(
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
          ],
        ),
      ),

      // 🔹 CONTENIDO PRINCIPAL
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 BUSCADOR
            TextFormField(
              controller: vm.buscarElementoAsignado,
              onFieldSubmitted: (_) => vm.getElementoAsignado(context),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.tareas, 'buscar'),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.grey),
                  onPressed: () => vm.getElementoAsignado(context),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔢 CONTADOR
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.translate(BlockTranslate.general, 'registro')} (${vm.elementos.length})",
                  style: StyleApp.normalBold,
                ),
              ],
            ),

            const Divider(),

            // 📋 LISTA DE ELEMENTOS
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: vm.elementos.length,
              itemBuilder: (context, index) {
                final ElementoAsignadoModel item = vm.elementos[index];

                return CardWidget(
                  raidus: 5,
                  borderColor: Colors.grey,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 2.5),
                  child: ListTile(
                    onTap: () => vm.selectRef(context, item, false),
                    title: Text(
                      "${item.descripcion} (${item.elementoAsignado})",
                      style: StyleApp.normal,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 🧾 HEADER
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xff134895),
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
                _buildTableRow('Descripcion', elemento?.descripcion ?? ''),
                _buildTableRow('Elemento ID', elemento?.elementoId ?? ''),
                _buildTableRow(
                  'Marca',
                  vehiculoVM.obtenerDescripcionMarca(elemento?.marca),
                ),

                // 🔹 Modelo con FutureBuilder
                if (elemento != null &&
                    elemento.marca != null &&
                    elemento.modelo != null)
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Modelo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FutureBuilder<String>(
                            future: vehiculoVM.obtenerDescripcionModeloPorId(
                              elemento.marca!,
                              elemento.modelo!,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Cargando...');
                              } else if (snapshot.hasError) {
                                return const Text('—');
                              } else {
                                final nombre = snapshot.data ?? '';
                                return Text(nombre.isEmpty ? '—' : nombre);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  _buildTableRow('Modelo', ''),

                _buildTableRow('Color', elemento?.color ?? ''),
                _buildTableRow('Placa', elemento?.placa ?? ''),
                _buildTableRow('Chasis', elemento?.elementoId ?? ''),
                _buildTableRow(
                  'Fecha y Hora',
                  elemento?.fechaHora != null
                      ? Utilities.formatearFechaHora(elemento!.fechaHora!)
                      : '',
                ),
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
