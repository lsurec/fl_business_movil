import 'package:fl_business/displays/vehiculos/model_views/vehiculos_catalogo_viewmodel.dart';
import 'package:fl_business/displays/vehiculos/views/inicioRecepci%C3%B3n.view.dart';
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
              context.read<ElementoAsigandoViewModel>().limpiarElemento();
            },
          ),
        ],
      ),

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
                labelText: AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.tareas, 'buscar'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppTheme.grey),
                  onPressed: () => vm.getElementoAsignado(context),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppTheme.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

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

            // 📋 LISTA
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: vm.elementos.length,
              itemBuilder: (context, index) {
                final item = vm.elementos[index];
                return CardWidget(
                  raidus: 6,
                  borderColor: Colors.grey,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 3),
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

            const SizedBox(height: 24),

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

            if (elemento != null) ...[
              _buildVehiculoCard(context, elemento, vehiculoVM),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Aceptar', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff134895),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InicioVehiculosView(),
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Text('Seleccione un vehículo'),
          ],
        ),
      ),
    );
  }

  // 🚗 CARD MODERNA DEL VEHÍCULO
  Widget _buildVehiculoCard(
    BuildContext context,
    ElementoAsignadoModel elemento,
    CatalogoVehiculosViewModel vehiculoVM,
  ) {
    Widget item(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xff134895),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              elemento.descripcion ?? 'Vehículo',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff134895),
              ),
            ),
            const Divider(),

            item('Marca', vehiculoVM.obtenerDescripcionMarca(elemento.marca)),

            // 🔹 MODELO (async)
            FutureBuilder<String>(
              future: (elemento.marca != null && elemento.modelo != null)
                  ? vehiculoVM.obtenerDescripcionModeloPorId(
                      elemento.marca!,
                      elemento.modelo!,
                    )
                  : Future.value(''),
              builder: (_, snap) => item('Modelo', snap.data ?? ''),
            ),

            item('Color', elemento.color ?? ''),
            item('Placa', elemento.placa ?? ''),
            item('Chasis', elemento.chasis ?? ''),
            item(
              'Fecha',
              elemento.fechaHora != null
                  ? Utilities.formatearFechaHora(elemento.fechaHora!)
                  : '',
            ),
          ],
        ),
      ),
    );
  }
}
