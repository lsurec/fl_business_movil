import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/convert_doc_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/serie_model.dart';
import 'package:fl_business/displays/prc_documento_3/services/location_service.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/confirm_doc_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/model_views/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/views/Items_Vehiculo_view.dart';
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
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final vm = Provider.of<InicioVehiculosViewModel>(context);
    final vmFactura = Provider.of<DocumentoViewModel>(context);
    final vmConfirm = Provider.of<ConfirmDocViewModel>(context);
    final vmConvert = Provider.of<ConvertDocViewModel>(context);
    final vmLocation = Provider.of<LocationService>(context);
    final ReferenciaViewModel refVM = Provider.of<ReferenciaViewModel>(context);
    final vmTheme = Provider.of<ThemeViewModel>(context);
    final ElementoAsigandoViewModel elVM =
        Provider.of<ElementoAsigandoViewModel>(context);
    final inicioVM = context.read<InicioVehiculosViewModel>();

    final isDark = AppTheme.isDark();
    final backgroundColor = isDark
        ? AppTheme.darkBackroundColor
        : AppTheme.backroundColor;
    final cardColor = isDark ? AppTheme.backroundDarkSecondary : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.grey;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.primary,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.vehiculos, 'recepcionVehiculos'),
              style: const TextStyle(
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
                tooltip: AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.botones, 'guardar'),

                onPressed: vm.formularioValido
                    ? () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: context.read<ItemsVehiculoViewModel>(),
                              child: const ItemsVehiculoScreen(),
                            ),
                          ),
                        );

                        final ok = await vm.guardarVehiculoEnCatalogo();
                        if (!context.mounted) return;
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                tooltip: AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.botones, 'cancelar'),

                onPressed: () {
                  vm.cancelar();
                  elVM.cancelar();
                },
              ),
            ],
          ),
          body: Container(
            color: backgroundColor,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate(BlockTranslate.cotizacion, 'docIdRef'),
                      style: StyleApp.title.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vm.idDocumentoRef.toString(),
                      style: StyleApp.normal.copyWith(color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.general, 'serie'),
                  style: StyleApp.title.copyWith(color: textColor),
                ),
                if (vm.series.isEmpty && !vmFactura.editDoc)
                  NotFoundWidget(
                    text: AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.notificacion, 'sinElementos'),
                    icon: Icon(
                      Icons.browser_not_supported_outlined,
                      size: 50,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                if (vmFactura.editDoc)
                  Text(
                    "${vmConvert.docOriginSelect!.serie} (${vmConvert.docOriginSelect!.serieDocumento})",
                    style: StyleApp.normal.copyWith(color: textColor),
                  ),
                if (vm.series.isNotEmpty && !vmFactura.editDoc)
                  DropdownButton<SerieModel>(
                    isExpanded: true,
                    dropdownColor: cardColor,
                    hint: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate(BlockTranslate.factura, 'opcion'),
                      style: TextStyle(color: hintColor),
                    ),
                    value: vm.serieSelect,
                    onChanged: (value) => vm.changeSerie(value, context),
                    items: vm.series.map((serie) {
                      return DropdownMenuItem<SerieModel>(
                        value: serie,
                        child: Text(
                          serie.descripcion!,
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }).toList(),
                  ),
                if (vm.valueParametro(318))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: StyleApp.normal.copyWith(color: textColor),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.translate(BlockTranslate.tiket, 'latitud'),
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
                          style: StyleApp.normal.copyWith(color: textColor),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(
                                context,
                              )!.translate(BlockTranslate.tiket, 'longitud'),
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
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.general, 'referencia'),
                        style: StyleApp.title.copyWith(color: textColor),
                      ),

                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.ref),
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                refVM.referencia == null
                                    ? AppLocalizations.of(context)!.translate(
                                        BlockTranslate.general,
                                        'buscar',
                                      )
                                    : refVM.referencia!.descripcion,
                                style: StyleApp.normal.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const Text(" * ", style: StyleApp.obligatory),
                              const SizedBox(width: 30),
                            ],
                          ),
                          leading: Icon(
                            Icons.search,
                            color: vmTheme.colorPref(AppTheme.idColorTema),
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
                      Text(
                        AppLocalizations.of(context)!.translate(
                          BlockTranslate.vehiculos,
                          'elementoAsignado',
                        ),

                        style: StyleApp.title.copyWith(color: textColor),
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
                                    ? AppLocalizations.of(context)!.translate(
                                        BlockTranslate.general,
                                        'buscar',
                                      )
                                    : elVM.elemento!.descripcion,
                                style: StyleApp.normal.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                              const Text(" * ", style: StyleApp.obligatory),
                              const SizedBox(width: 30),
                            ],
                          ),
                          leading: Icon(
                            Icons.search,
                            color: vmTheme.colorPref(AppTheme.idColorTema),
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
                      style: StyleApp.title.copyWith(color: textColor),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.addClient),
                      icon: const Icon(Icons.person_add_outlined),
                      tooltip: AppLocalizations.of(
                        context,
                      )!.translate(BlockTranslate.cuenta, 'nueva'),
                    ),
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
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: vm.getTextCuenta(context),
                        hintStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor: cardColor,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => vm.performSearchClient(context),
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
                  activeColor: AppTheme.hexToColor(Preferences.valueColor),
                  contentPadding: EdgeInsets.zero,
                  value: vm.cf,
                  onChanged: (value) => vm.changeCF(context, value),
                  title: Text(
                    t.translate(BlockTranslate.factura, 'factura_cf'),
                    style: StyleApp.title.copyWith(color: textColor),
                  ),
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
                            style: StyleApp.titlegrey.copyWith(
                              color: textColor,
                            ),
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        vm.clienteSelect!.facturaNit,
                        style: StyleApp.normal.copyWith(color: textColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        vm.clienteSelect!.facturaNombre,
                        style: StyleApp.normal.copyWith(color: textColor),
                      ),
                      if (vm.clienteSelect!.facturaDireccion.isNotEmpty &&
                          vmFactura.editDoc)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              vm.clienteSelect!.facturaDireccion,
                              style: StyleApp.normal.copyWith(color: textColor),
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
                              style: StyleApp.greyText.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 15),

                // 🔹 Sección Identificación Vehículo 🔹
                _buildModernSection(
                  title: AppLocalizations.of(context)!.translate(
                    BlockTranslate.vehiculos,
                    'identificacionVehiculo',
                  ),

                  icon: Icons.confirmation_number_outlined,
                  children: [
                    // Búsqueda de vehículo
                    TextFormField(
                      controller: elVM.buscarElementoAsignado,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: t.translate(
                          BlockTranslate.vehiculos,
                          'buscarVehiculoPlaca',
                        ),

                        labelStyle: TextStyle(color: textColor),
                        filled: true,
                        fillColor: cardColor,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (elVM.buscarElementoAsignado.text.trim().isEmpty)
                              return;
                            await elVM.getElementoAsignado(context);
                            elVM.mostrarLista();
                          },
                        ),
                      ),
                    ),
                    if (elVM.mostrarResultados)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: cardColor,
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.grey.shade300,
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
                                style: TextStyle(color: textColor),
                              ),
                              onTap: () async {
                                elVM.buscarElementoAsignado.text = item.placa
                                    .toString();
                                elVM
                                    .buscarElementoAsignado
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset:
                                        elVM.buscarElementoAsignado.text.length,
                                  ),
                                );
                                elVM.selectRef(context, item, false);
                                elVM.ocultarLista();
                                await inicioVM.cargarDesdeElementoAsignado(
                                  context,
                                  item,
                                );
                                vm.notifyListeners();
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      t.translate(BlockTranslate.vehiculos, 'placa'),
                      vm.placaController,
                      fillColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      t.translate(BlockTranslate.vehiculos, 'chasis'),
                      vm.chasisController,
                      fillColor: cardColor,
                      textColor: textColor,
                    ),
                    if (vm.marcaSeleccionada != null ||
                        vm.modeloSeleccionado != null ||
                        vm.anioSeleccionado != null ||
                        vm.colorSeleccionado != null)
                      _buildVehiculoSeleccionado(vm),
                    _buildTipoVehiculoDropdown(context),
                  ],
                ),

                // 🔹 Sección Datos del Vehículo 🔹
                _buildModernSection(
                  title: t.translate(BlockTranslate.vehiculos, 'datosVehiculo'),
                  icon: Icons.directions_car_outlined,
                  children: [_buildTabsVehiculo(context, vm)],
                ),

                // 🔹 Sección Detalle del Trabajo 🔹
                _buildModernSection(
                  title: t.translate(
                    BlockTranslate.vehiculos,
                    'detalleTrabajo',
                  ),

                  icon: Icons.assignment_outlined,
                  children: [_buildDetalleTrabajo(context, vm)],
                ),

                // 🔹 Sección Fechas 🔹
                _buildModernSection(
                  title: t.translate(BlockTranslate.vehiculos, 'fechas'),

                  icon: Icons.calendar_today_outlined,
                  children: [
                    _buildDateSelector(
                      context,
                      label: t.translate(
                        BlockTranslate.vehiculos,
                        'fechaRecibido',
                      ),
                      fecha: vm.fechaRecibido,
                      onFechaSeleccionada: vm.seleccionarFechaRecibido,
                    ),
                    _buildDateSelector(
                      context,
                      label: t.translate(
                        BlockTranslate.vehiculos,
                        'fechaEstimadaEntrega',
                      ),
                      fecha: vm.fechaSalida,
                      onFechaSeleccionada: vm.seleccionarFechaSalida,
                    ),
                  ],
                ),
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

  Widget _buildTipoVehiculoDropdown(BuildContext context) {
    final vm = Provider.of<InicioVehiculosViewModel>(context);

    final t = AppLocalizations.of(context)!;

    if (vm.cargandoTiposVehiculo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.tiposVehiculo.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          t.translate(BlockTranslate.vehiculos, 'sinTiposVehiculo'),

          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Colores según modo oscuro
    final bgColor = AppTheme.isDark()
        ? AppTheme.backroundDarkSecondary
        : const Color(0xFFFEF5E7);
    final txtColor = AppTheme.isDark() ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField(
        isExpanded: true,
        value: vm.tipoVehiculoSeleccionado,
        decoration: InputDecoration(
          labelText: t.translate(BlockTranslate.vehiculos, 'tipoVehiculo'),

          labelStyle: TextStyle(color: txtColor),
          filled: true,
          fillColor: bgColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        dropdownColor: bgColor, // para el menú desplegable
        style: TextStyle(color: txtColor),
        items: vm.tiposVehiculo.map((tipo) {
          return DropdownMenuItem(
            value: tipo,
            child: Text(
              tipo.descripcion ?? '',
              style: TextStyle(color: txtColor),
            ),
          );
        }).toList(),
        onChanged: vm.seleccionarTipoVehiculo,
      ),
    );
  }

  Widget _buildVehiculoSeleccionado(InicioVehiculosViewModel vm) {
    final t = AppLocalizations.of(context)!;
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
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.isDark()
                      ? AppTheme.primaryDark
                      : const Color(0xff134895),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.isDark() ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bgColor = AppTheme.isDark()
        ? AppTheme.backroundDarkSecondary
        : const Color(0xFFF4F6F7);
    final borderColor = AppTheme.isDark()
        ? AppTheme.darkSeparador
        : const Color(0xFFD5DBDB);
    final titleColor = AppTheme.isDark()
        ? AppTheme.primaryDark
        : const Color(0xff134895);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate(BlockTranslate.vehiculos, 'vehiculoSeleccionado'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          Divider(color: borderColor),

          item(
            t.translate(BlockTranslate.vehiculos, 'marca'),
            vm.marcaSeleccionada?.descripcion ?? '',
          ),
          item(
            t.translate(BlockTranslate.vehiculos, 'linea'),
            vm.modeloSeleccionado?.descripcion ?? '',
          ),
          item(
            t.translate(BlockTranslate.vehiculos, 'modelo'),
            vm.anioSeleccionado?.anio.toString() ?? '',
          ),
          item(
            t.translate(BlockTranslate.vehiculos, 'color'),
            vm.colorSeleccionado?.descripcion ?? '',
          ),
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
    final isDark = AppTheme.isDark();
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.backroundDarkSecondary
            : const Color(0xFFFEF5E7), // ✔ correcto

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
              Icon(icon, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: isDark ? AppTheme.dividerDark : AppTheme.divider,
          ),
          ...children,
        ],
      ),
    );
  }

  // Campos modernos
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    Color? fillColor, // Nullable para calcular según tema
    Color? textColor, // Nullable para calcular según tema
  }) {
    // Colores calculados según modo oscuro si no se pasan
    final bgColor =
        fillColor ??
        (AppTheme.isDark()
            ? AppTheme.backroundDarkSecondary
            : const Color(0xFFFEF5E7));
    final txtColor =
        textColor ?? (AppTheme.isDark() ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: (_) {
          context.read<InicioVehiculosViewModel>().notifyListeners();
        },
        style: TextStyle(color: txtColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: txtColor),
          filled: true,
          fillColor: bgColor,
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
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Sección: Contacto
        Text(
          t.translate(BlockTranslate.vehiculos, 'contacto'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'celular'),
          vm.celularController,
        ),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'email'),
          vm.emailController,
        ),
        const SizedBox(height: 20),

        // 🔹 Sección: Datos técnicos
        Text(
          t.translate(BlockTranslate.vehiculos, 'datosTecnicos'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'kilometraje'),
          vm.kilometrajeController,
        ),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'cc'),
          vm.ccController,
        ),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'cil'),
          vm.cilController,
        ),
        const SizedBox(height: 20),

        // 🔹 Sección: Observaciones
        Text(
          t.translate(BlockTranslate.vehiculos, 'observaciones'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff134895),
          ),
        ),
        const Divider(thickness: 1, height: 20, color: Color(0xFFE0E0E0)),
        _buildTextField(
          t.translate(BlockTranslate.vehiculos, 'detallesTrabajo'),
          vm.detalleTrabajoController,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // 🚗 Tabs
  Widget _buildTabsVehiculo(BuildContext context, InicioVehiculosViewModel vm) {
    final t = AppLocalizations.of(context)!;

    final tabs = [
      t.translate(BlockTranslate.vehiculos, 'marca'),
      t.translate(BlockTranslate.vehiculos, 'linea'),
      t.translate(BlockTranslate.vehiculos, 'modelo'),
      t.translate(BlockTranslate.vehiculos, 'color'),
    ];
    final bool darkMode = AppTheme.isDark();
    final Color containerColor = darkMode
        ? AppTheme.backroundDarkSecondary
        : const Color(0xFFF8F9F9);
    final Color borderColor = darkMode
        ? AppTheme.darkSeparador
        : const Color(0xFFD6DBDF);
    final Color labelColor = darkMode
        ? AppTheme.primaryDark
        : const Color(0xff134895);
    final Color unselectedLabelColor = darkMode ? Colors.white60 : Colors.grey;
    final Color indicatorColor = darkMode
        ? AppTheme.primaryDark.withOpacity(0.3)
        : const Color(0xffD6EAF8);

    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (tabContext) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TabBar(
                  labelColor: labelColor,
                  unselectedLabelColor: unselectedLabelColor,
                  indicator: BoxDecoration(
                    color: indicatorColor,
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
                      t.translate(BlockTranslate.vehiculos, 'buscarMarca'),
                      vm.marcas,
                      vm.marcaSeleccionada,
                      (v) => v.descripcion,
                      (v) {
                        vm.seleccionarMarca(v, context);
                        DefaultTabController.of(tabContext).animateTo(1);
                      },
                    ),
                    _buildScrollableSelector(
                      tabContext,
                      t.translate(BlockTranslate.vehiculos, 'buscarLinea'),
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
                      t.translate(BlockTranslate.vehiculos, 'buscarModelo'),
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
                      t.translate(BlockTranslate.vehiculos, 'buscarColor'),
                      vm.colores,
                      vm.colorSeleccionado,
                      (v) => v.descripcion,
                      (v) async {
                        vm.seleccionarColor(v);
                        await vm.cargarTiposVehiculo(context);
                        ScaffoldMessenger.of(tabContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              t.translate(
                                BlockTranslate.vehiculos,
                                'datosCompletos',
                              ),
                            ),
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

    final bool darkMode = AppTheme.isDark();
    final Color fillColor = darkMode
        ? AppTheme.backroundDarkSecondary
        : const Color(0xFFF8F9F9);
    final Color cardSelectedColor = darkMode
        ? AppTheme.primaryDark.withOpacity(0.3)
        : const Color(0xffD6EAF8);
    final Color cardColor = darkMode
        ? AppTheme.darkBackroundColor
        : Colors.white;
    final Color textColor = darkMode ? Colors.white : Colors.black87;
    final Color searchIconColor = darkMode ? Colors.white70 : Colors.grey;

    return Column(
      children: [
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.search, color: searchIconColor),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: TextStyle(color: textColor),
          onChanged: (v) => filtro.value = v.toLowerCase(),
        ),
        const SizedBox(height: 10),
        // 🔹 Flexible en lugar de height fijo
        Flexible(
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
                    color: isSelected ? cardSelectedColor : cardColor,
                    child: ListTile(
                      title: Text(
                        displayText(item),
                        style: TextStyle(color: textColor),
                      ),
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
    Color? backgroundColor, // Nullable
    Color? textColor, // Nullable
  }) {
    final t = AppLocalizations.of(context)!;

    // Asignar colores dentro del método
    final bgColor =
        backgroundColor ??
        (AppTheme.isDark()
            ? AppTheme.backroundDarkSecondary
            : const Color(0xFFFEF5E7));
    final txtColor =
        textColor ?? (AppTheme.isDark() ? Colors.white : Colors.black87);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.isDark()
              ? AppTheme.darkSeparador
              : const Color(0xFFB0BEC5),
          width: 1,
        ),
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
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  fecha.isEmpty
                      ? t.translate(
                          BlockTranslate.vehiculos,
                          'seleccioneFechaHora',
                        )
                      : fecha,
                  style: TextStyle(color: txtColor, fontSize: 15),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.primary,
            ),
            onPressed: () async {
              // Abrir selector de fecha
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: fecha.isNotEmpty
                    ? DateTime.tryParse(fecha) ?? DateTime.now()
                    : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (selectedDate == null) return;

              // Abrir selector de hora
              TimeOfDay? selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );

              if (selectedTime == null) return;

              // Combinar fecha y hora
              final dateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              // Callback con fecha y hora
              onFechaSeleccionada(dateTime.toString());
            },
          ),
        ],
      ),
    );
  }
}
