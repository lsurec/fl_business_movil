import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/convert_doc_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/seller_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/serie_model.dart';
import 'package:fl_business/displays/prc_documento_3/services/location_service.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/confirm_doc_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart'
    as model;
import 'package:fl_business/displays/vehiculos/views/Items_Vehiculo_view.dart';
import 'package:fl_business/displays/vehiculos/views/catalogo_vehiculos_view.dart';
import 'package:fl_business/displays/vehiculos/views/datos_guardados_view.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/elemento_asignado_view_model.dart';
import 'package:fl_business/view_models/referencia_view_model.dart';
import 'package:fl_business/view_models/theme_view_model.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:fl_business/widgets/not_found_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InicioVehiculosView extends StatefulWidget {
  const InicioVehiculosView({super.key});

  @override
  State<InicioVehiculosView> createState() => _InicioVehiculosViewState();
}

class _InicioVehiculosViewState extends State<InicioVehiculosView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final vm = context.read<InicioVehiculosViewModel>(); // 👈 DEFINIR VM AQUÍ
      vm.cargarDatosIniciales(context);

      // Agregar listeners después de cargar datos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = context
            .read<InicioVehiculosViewModel>(); // 👈 OTRA VEZ AQUÍ (seguro)
        vm.placaController.addListener(_revalidar);
        vm.chasisController.addListener(_revalidar);
      });
    });
  }

  void _revalidar() {
    if (mounted) {
      final vm = context.read<InicioVehiculosViewModel>();
      vm.notifyListeners();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      final vm = context.read<InicioVehiculosViewModel>();
      vm.placaController.removeListener(_revalidar);
      vm.chasisController.removeListener(_revalidar);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InicioVehiculosViewModel>();
    final vmFactura = Provider.of<DocumentoViewModel>(context);
    final vmConfirm = Provider.of<ConfirmDocViewModel>(context);
    final vmConvert = Provider.of<ConvertDocViewModel>(context);
    final vmLocation = Provider.of<LocationService>(context);
    final ReferenciaViewModel refVM = Provider.of<ReferenciaViewModel>(context);
    final vmTheme = Provider.of<ThemeViewModel>(context);
    final ElementoAsigandoViewModel elVM =
        Provider.of<ElementoAsigandoViewModel>(context);
    final inicioVM = context.read<InicioVehiculosViewModel>();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff134895),
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Recepción de Vehículos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.save_rounded,
                  color: vm.formularioValido ? Colors.white : Colors.white54,
                ),
                tooltip: 'Guardar',
                onPressed: vm.formularioValido
                    ? () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ItemsVehiculoScreen(),
                          ),
                        );

                        final ok = await vm.guardarVehiculoEnCatalogo();

                        if (!context.mounted) return;
                      }
                    : null,
              ),

              IconButton(
                icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                tooltip: 'Cancelar',
                onPressed: () {
                  vm.cancelar();
                  elVM.cancelar();
                },
              ),
            ],
          ),

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEAF2F8), Color(0xFFFEF5E7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xff134895)),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    children: [
                      // _buildModernSection(
                      //   title: 'Datos del Cliente',
                      //   icon: Icons.person_outline,
                      //   children: [
                      //     _buildTextField('NIT', vm.nitController),
                      //     _buildTextField('Nombre', vm.nombreController),
                      //     _buildTextField('Dirección', vm.direccionController),
                      //   ],
                      // ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate(BlockTranslate.cotizacion, 'docIdRef'),
                            style: StyleApp.title,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            vm.idDocumentoRef.toString(),
                            style: StyleApp.normal,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.general, 'serie'),
                        style: StyleApp.title,
                      ),
                      if (vm.series.isEmpty && !vmFactura.editDoc)
                        NotFoundWidget(
                          text: AppLocalizations.of(context)!.translate(
                            BlockTranslate.notificacion,
                            'sinElementos',
                          ),
                          icon: const Icon(
                            Icons.browser_not_supported_outlined,
                            size: 50,
                          ),
                        ),
                      if (vmFactura.editDoc)
                        Text(
                          "${vmConvert.docOriginSelect!.serie} (${vmConvert.docOriginSelect!.serieDocumento})",
                          style: StyleApp.normal,
                        ),
                      if (vm.series.isNotEmpty && !vmFactura.editDoc)
                        DropdownButton<SerieModel>(
                          isExpanded: true,
                          dropdownColor: AppTheme.isDark()
                              ? AppTheme.darkBackroundColor
                              : AppTheme.backroundColor,
                          hint: Text(
                            AppLocalizations.of(
                              context,
                            )!.translate(BlockTranslate.factura, 'opcion'),
                          ),
                          value: vm.serieSelect,
                          onChanged: (value) => vm.changeSerie(value, context),
                          items: vm.series.map((serie) {
                            return DropdownMenuItem<SerieModel>(
                              value: serie,
                              child: Text(serie.descripcion!),
                            );
                          }).toList(),
                        ),
                      if (vm.valueParametro(318))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: StyleApp.normal.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .translate(
                                          BlockTranslate.tiket,
                                          'latitud',
                                        ),
                                    style: StyleApp.normalBold,
                                  ),
                                  TextSpan(
                                    text: vmLocation.latitutd,
                                    style: StyleApp.normal,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                style: StyleApp.normal.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .translate(
                                          BlockTranslate.tiket,
                                          'longitud',
                                        ),
                                    style: StyleApp.normalBold,
                                  ),
                                  TextSpan(
                                    text: vmLocation.longitud,
                                    style: StyleApp.normal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      if (vm.valueParametro(58))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Referencia", //TODO:Translate
                              style: StyleApp.title,
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.ref),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      refVM.referencia == null
                                          ? "Buscar..."
                                          : refVM.referencia!.descripcion,
                                      style: StyleApp.normal.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const Text(
                                      " * ",
                                      style: StyleApp.obligatory,
                                    ),
                                    const SizedBox(width: 30),
                                  ],
                                ),
                                leading: Icon(
                                  Icons.search,
                                  color: vmTheme.colorPref(
                                    AppTheme.idColorTema,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(0),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      if (vm.valueParametro(259))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Elemento Asignado", //TODO:Translate
                              style: StyleApp.title,
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.elementoAsignado,
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(
                                      elVM.elemento == null
                                          ? "Buscar..."
                                          : elVM.elemento!.descripcion,
                                      style: StyleApp.normal.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const Text(
                                      " * ",
                                      style: StyleApp.obligatory,
                                    ),
                                    const SizedBox(width: 30),
                                  ],
                                ),
                                leading: Icon(
                                  Icons.search,
                                  color: vmTheme.colorPref(
                                    AppTheme.idColorTema,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(0),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            vm.getTextCuenta(context),
                            style: StyleApp.title,
                          ),
                          IconButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.addClient,
                            ),
                            icon: const Icon(Icons.person_add_outlined),
                            tooltip: AppLocalizations.of(
                              context,
                            )!.translate(BlockTranslate.cuenta, 'nueva'),
                          ),
                          // IconButton(
                          //   onPressed: () => vm.restaurarFechas(),
                          //   icon: const Icon(
                          //     Icons.refresh,
                          //   ),
                          // )
                        ],
                      ),
                      if (vm.clienteSelect == null) const SizedBox(height: 20),
                      if (vm.clienteSelect == null)
                        Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          key: vm.formKeyClient,
                          child: TextFormField(
                            controller: vm.client,
                            onFieldSubmitted: (value) =>
                                vm.performSearchClient(context),
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: vm.getTextCuenta(context),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () =>
                                    vm.performSearchClient(context),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.translate(
                                  BlockTranslate.notificacion,
                                  'requerido',
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        activeColor: AppTheme.hexToColor(
                          Preferences.valueColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                        value: vm.cf,
                        onChanged: (value) => vm.changeCF(context, value),
                        title: const Text("C/F", style: StyleApp.title),
                      ),
                      if (vm.clienteSelect != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vm.getTextCuenta(context),
                                  style: StyleApp.titlegrey,
                                ),
                                if (!vm.cf)
                                  IconButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.updateClient,
                                      arguments: vm.clienteSelect,
                                    ),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: AppTheme.grey,
                                    ),
                                    tooltip: AppLocalizations.of(context)!
                                        .translate(
                                          BlockTranslate.cuenta,
                                          'editar',
                                        ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              vm.clienteSelect!.facturaNit,
                              style: StyleApp.normal,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              vm.clienteSelect!.facturaNombre,
                              style: StyleApp.normal,
                            ),
                            if (vm.clienteSelect!.facturaDireccion.isNotEmpty &&
                                vmFactura.editDoc)
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    vm.clienteSelect!.facturaDireccion,
                                    style: StyleApp.normal,
                                  ),
                                ],
                              ),
                            if (vm.clienteSelect!.desCuentaCta.isNotEmpty &&
                                vmFactura.editDoc)
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "(${vm.clienteSelect!.desCuentaCta})",
                                    style: StyleApp.greyText,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      if (vm.cuentasCorrentistasRef.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.translate(BlockTranslate.factura, 'vendedor'),
                              style: StyleApp.title,
                            ),
                            DropdownButton<SellerModel>(
                              isExpanded: true,
                              dropdownColor: AppTheme.isDark()
                                  ? AppTheme.darkBackroundColor
                                  : AppTheme.backroundColor,
                              hint: Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate(BlockTranslate.factura, 'opcion'),
                              ),
                              value: vm.vendedorSelect,
                              onChanged: (value) => vm.changeSeller(value),
                              items: vm.cuentasCorrentistasRef.map((seller) {
                                return DropdownMenuItem<SellerModel>(
                                  value: seller,
                                  child: Text(seller.nomCuentaCorrentista),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      const SizedBox(height: 15),

                      _buildModernSection(
                        title: 'Identificación del Vehículo',
                        icon: Icons.confirmation_number_outlined,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔍 CAMPO DE BÚSQUEDA (para buscar por placa)
                              TextFormField(
                                controller: elVM.buscarElementoAsignado,
                                decoration: InputDecoration(
                                  labelText: 'Buscar vehículo por placa',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if (elVM.buscarElementoAsignado.text
                                          .trim()
                                          .isEmpty)
                                        return;
                                      await elVM.getElementoAsignado(context);
                                      elVM.mostrarLista();
                                    },
                                  ),
                                ),
                              ),

                              // 📋 RESULTADOS DE BÚSQUEDA
                              if (elVM.mostrarResultados)
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 250,
                                  ),
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: elVM.elementos.length,
                                    itemBuilder: (_, index) {
                                      final item = elVM.elementos[index];
                                      return ListTile(
                                        title: Text(
                                          "${item.descripcion} (${item.elementoAsignado})",
                                        ),
                                        onTap: () async {
                                          // 1. Escribir la placa en el input de búsqueda
                                          elVM.buscarElementoAsignado.text =
                                              item.placa.toString();

                                          // 2. Mover cursor al final
                                          elVM
                                                  .buscarElementoAsignado
                                                  .selection =
                                              TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: elVM
                                                      .buscarElementoAsignado
                                                      .text
                                                      .length,
                                                ),
                                              );

                                          // 3. Guardar selección
                                          elVM.selectRef(context, item, false);

                                          // 4. Ocultar resultados
                                          elVM.ocultarLista();

                                          // 5. Cargar datos relacionados (ESTO YA ACTUALIZA vm.placaController)
                                          await inicioVM
                                              .cargarDesdeElementoAsignado(
                                                context,
                                                item,
                                              );

                                          // 6. Forzar revalidación
                                          vm.notifyListeners();
                                        },
                                      );
                                    },
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // 🟢🟢🟢 NUEVO: CAMPO DE PLACA MANUAL (conectado a vm.placaController) 🟢🟢🟢
                              _buildTextField('Placa', vm.placaController),

                              const SizedBox(height: 8),

                              _buildTextField('Chasis', vm.chasisController),

                              if (vm.marcaSeleccionada != null ||
                                  vm.modeloSeleccionado != null ||
                                  vm.anioSeleccionado != null ||
                                  vm.colorSeleccionado != null)
                                _buildVehiculoSeleccionado(vm),

                              _buildTipoVehiculoDropdown(vm),
                            ],
                          ),
                        ],
                      ),

                      _buildModernSection(
                        title: 'Datos del Vehículo',
                        icon: Icons.directions_car_outlined,
                        children: [_buildTabsVehiculo(context, vm)],
                      ),
                      _buildModernSection(
                        title: 'Detalle del Trabajo',
                        icon: Icons.assignment_outlined,
                        children: [_buildDetalleTrabajo(context, vm)],
                      ),
                      _buildModernSection(
                        title: 'Fechas',
                        icon: Icons.calendar_today_outlined,
                        children: [
                          _buildDateSelector(
                            context,
                            label: 'Fecha recibido',
                            fecha: vm.fechaRecibido,
                            onFechaSeleccionada: vm.seleccionarFechaRecibido,
                          ),
                          _buildDateSelector(
                            context,
                            label: 'Fecha Estimada de Entrega',
                            fecha: vm.fechaSalida,
                            onFechaSeleccionada: vm.seleccionarFechaSalida,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 24),
                    ],
                  ),
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

  Widget _buildTipoVehiculoDropdown(InicioVehiculosViewModel vm) {
    if (vm.cargandoTiposVehiculo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.tiposVehiculo.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No se encontraron tipos de vehículo',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField(
        isExpanded: true,
        value: vm.tipoVehiculoSeleccionado,
        decoration: InputDecoration(
          labelText: 'Tipo de vehículo',
          filled: true,
          fillColor: const Color(0xFFF8F9F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: vm.tiposVehiculo.map((tipo) {
          return DropdownMenuItem(
            value: tipo,
            child: Text(tipo.descripcion ?? ''),
          );
        }).toList(),
        onChanged: vm.seleccionarTipoVehiculo,
      ),
    );
  }

  Widget _buildVehiculoSeleccionado(InicioVehiculosViewModel vm) {
    Widget item(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5DBDB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehículo seleccionado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff134895),
            ),
          ),
          const Divider(),

          item('Marca', vm.marcaSeleccionada?.descripcion ?? ''),
          item('Línea', vm.modeloSeleccionado?.descripcion ?? ''),
          item('Modelo', vm.anioSeleccionado?.anio.toString() ?? ''),
          item('Color', vm.colorSeleccionado?.descripcion ?? ''),
        ],
      ),
    );
  }

  // Sección con diseño moderno
  Widget _buildModernSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xff134895)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff134895),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFE0E0E0)),
          ...children,
        ],
      ),
    );
  }

  // Campos modernos
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: (_) {
          // 👇 FORZAR REVALIDACIÓN EN CADA TECLA
          context.read<InicioVehiculosViewModel>().notifyListeners();
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8F9F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // Detalle del trabajo

  Widget _buildDetalleTrabajo(
    BuildContext context,
    InicioVehiculosViewModel vm,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Sección: Contacto
        const Text(
          '📞 Contacto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField('Celular', vm.celularController),
        _buildTextField('Email', vm.emailController),
        const SizedBox(height: 20),

        // 🔹 Sección: Datos técnicos
        const Text(
          '⚙️ Datos Técnicos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField('Kilometraje', vm.kilometrajeController),
        _buildTextField('CC', vm.ccController),
        _buildTextField('CIL', vm.cilController),
        const SizedBox(height: 20),

        // 🔹 Sección: Observaciones
        const Text(
          '📝 Observaciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField('Detalles del trabajo', vm.detalleTrabajoController),
        const SizedBox(height: 20),
      ],
    );
  }

  // 🚗 Tabs
  Widget _buildTabsVehiculo(BuildContext context, InicioVehiculosViewModel vm) {
    final tabs = ['Marca', 'Línea', 'Modelo', 'Color'];

    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        // 👈 Builder para obtener el contexto correcto
        builder: (tabContext) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD6DBDF)),
                ),
                child: TabBar(
                  labelColor: const Color(0xff134895),
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: const Color(0xffD6EAF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: tabs.map((t) => Tab(text: t)).toList(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildScrollableSelector(
                      tabContext,
                      'Buscar marca',
                      vm.marcas,
                      vm.marcaSeleccionada,
                      (v) => v.descripcion,
                      (v) {
                        vm.seleccionarMarca(v);
                        DefaultTabController.of(tabContext).animateTo(1);
                      },
                    ),
                    _buildScrollableSelector(
                      tabContext,
                      'Buscar línea',
                      vm.modelos,
                      vm.modeloSeleccionado,
                      (v) => v.descripcion,
                      (v) {
                        vm.seleccionarModelo(v);
                        DefaultTabController.of(tabContext).animateTo(2);
                      },
                    ),
                    _buildScrollableSelector(
                      tabContext,
                      'Buscar modelo (año)',
                      vm.anios,
                      vm.anioSeleccionado,
                      (v) => v.anio.toString(),
                      (v) {
                        vm.seleccionarAnio(v);
                        DefaultTabController.of(tabContext).animateTo(3);
                      },
                    ),
                    _buildScrollableSelector(
                      tabContext,
                      'Buscar color',
                      vm.colores,
                      vm.colorSeleccionado,
                      (v) => v.descripcion,
                      (v) async {
                        vm.seleccionarColor(v);
                        await vm.cargarTiposVehiculo(); // 👈 AQUÍ
                        ScaffoldMessenger.of(tabContext).showSnackBar(
                          const SnackBar(
                            content: Text('Datos del vehículo completos'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollableSelector<T>(
    BuildContext context,
    String label,
    List<T> items,
    T? selected,
    String Function(T) displayText,
    Function(T) onSelected,
  ) {
    final searchController = TextEditingController();
    final filtro = ValueNotifier('');

    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF8F9F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => filtro.value = v.toLowerCase(),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: filtro,
            builder: (_, texto, __) {
              final filtrados = items
                  .where((e) => displayText(e).toLowerCase().contains(texto))
                  .toList();
              return ListView.builder(
                itemCount: filtrados.length,
                itemBuilder: (_, i) {
                  final item = filtrados[i];
                  final isSelected = item == selected;
                  return Card(
                    color: isSelected ? const Color(0xffD6EAF8) : Colors.white,
                    child: ListTile(
                      title: Text(displayText(item)),
                      onTap: () => onSelected(item),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 📅 Selector de fecha y hora moderno
  Widget _buildDateSelector(
    BuildContext context, {
    required String label,
    required String fecha,
    required Function(String) onFechaSeleccionada,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB0BEC5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fecha.isEmpty ? 'Seleccione una fecha y hora' : fecha,
                  style: TextStyle(
                    color: fecha.isEmpty
                        ? Colors.grey[500]
                        : const Color(0xFF212121),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF0D47A1),
            ),
            onPressed: () async {
              final now = DateTime.now();
              final hoy = DateTime(now.year, now.month, now.day);

              final fechaSeleccionada = await showDatePicker(
                context: context,
                initialDate: hoy,
                firstDate: hoy, // ⛔ NO permite fechas anteriores a hoy
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF0D47A1),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF212121),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (fechaSeleccionada != null) {
                final horaSeleccionada = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF0D47A1),
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (horaSeleccionada != null) {
                  final fechaHora = DateTime(
                    fechaSeleccionada.year,
                    fechaSeleccionada.month,
                    fechaSeleccionada.day,
                    horaSeleccionada.hour,
                    horaSeleccionada.minute,
                  );

                  final fechaFormateada =
                      '${fechaHora.year}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.day.toString().padLeft(2, '0')} '
                      '${horaSeleccionada.format(context)}';

                  onFechaSeleccionada(fechaFormateada);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
