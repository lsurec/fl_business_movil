import 'package:flutter/material.dart';
import 'package:fl_business/displays/tablero_kanban/models/estado_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/prioridad_model.dart';
import 'package:fl_business/displays/tablero_kanban/models/tipo_tarea_model.dart';

import 'package:fl_business/displays/tablero_kanban/views/kanban_pageview.dart';
import 'package:fl_business/displays/tablero_kanban/views/referencia_search_widget.dart';
import 'package:fl_business/displays/tablero_kanban/views/usuario_searchview.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:provider/provider.dart';
import 'package:fl_business/displays/tareas/view_models/tareas_view_model.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:fl_business/widgets/load_widget.dart';
import '../view_models/tablero_view_model.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({Key? key}) : super(key: key);

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final vm = Provider.of<PrincipalViewModel>(context, listen: false);
    await vm.init();
    if (mounted) {
      setState(() {
        _initialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PrincipalViewModel>(context);
    final vmTarea = Provider.of<TareasViewModel>(context);
    final vmMenu = Provider.of<MenuViewModel>(context);
    final bool isDark = AppTheme.isDark();

    return Stack(
      children: [
        DefaultTabController(
          length: 4,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
            appBar: AppBar(
              backgroundColor: AppTheme.isDark()
                  ? AppTheme.darkBackroundColor
                  : AppTheme.backroundColor,
              title: Text(
                vmMenu.name,
                style: StyleApp.title.copyWith(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => vmTarea.crearTarea(context),
                  icon: const Icon(Icons.add, size: 28),
                  tooltip: AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.botones, 'nueva'),
                  color: AppTheme.isDark() ? Colors.white : Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.tablero, 'Nueva'),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.translate(BlockTranslate.tablero, 'Nueva'),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.isDark() ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // Botón mostrar filtros
                    _buildBotonFiltros(vm, isDark),

                    if (vm.mostrarFiltros) _buildPanelFiltros(vm, isDark),

                    const SizedBox(height: 10),

                    // Pestañas
                    _buildPestanas(vm, isDark),

                    const SizedBox(height: 10),

                    // Contenido principal
                    _buildContenidoPrincipal(vm, isDark),

                    // Paginación
                    _buildPaginacion(vm, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Loading para inicialización y operaciones posteriores
        if (_initialLoading || vm.isLoading || vmTarea.isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),

          const LoadWidget(),
        ],
      ],
    );
  }

  Widget _buildBotonFiltros(PrincipalViewModel vm, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xFF1F1F1F)
              : const Color(0xffFEF5E7),
          foregroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        onPressed: () => vm.mostrarFiltros = !vm.mostrarFiltros,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tablero, 'Filtros'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelFiltros(PrincipalViewModel vm, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButton<Estado>(
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                hint: Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.tablero, 'SelecEstado'),
                ),
                value: vm.estadoFiltroSeleccionado,
                isExpanded: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                items: vm.estados
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.descripcion),
                      ),
                    )
                    .toList(),
                onChanged: (nuevo) => vm.aplicarFiltroEstado(nuevo),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<TipoTarea>(
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                hint: Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.tablero, 'SelecTipo'),
                ),
                value: vm.tipoFiltroSeleccionado,
                isExpanded: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                items: vm.tiposTarea
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.descripcion),
                      ),
                    )
                    .toList(),
                onChanged: (nuevo) => vm.aplicarFiltroTipo(nuevo),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButton<Prioridad>(
                dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                hint: Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.tablero, 'SelectPrioridad'),
                ),
                value: vm.prioridadFiltroSeleccionada,
                isExpanded: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                items: vm.prioridades
                    .map(
                      (p) => DropdownMenuItem(value: p, child: Text(p.nombre)),
                    )
                    .toList(),
                onChanged: (nuevo) => vm.aplicarFiltroPrioridad(nuevo),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: vm.limpiarFiltros,
              icon: const Icon(Icons.clear, color: Colors.white),
              label: Text(
                AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.tablero, 'BtFiltro'),
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF2D6BE6)
                    : const Color(0xff134895),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tablero, 'BuscReferencia'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: ReferenciaSearchWidget(
                    empresa: "1",
                    controller: _referenciaController,
                    onSeleccionar: (ref) {
                      vm.aplicarFiltroReferencia(ref?.referencia.toString());
                    },
                  ),
                ),
                // 🔹 BOTÓN PARA LIMPIAR REFERENCIA
                if (_referenciaController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                    onPressed: () {
                      _referenciaController.clear();
                      vm.limpiarFiltroReferencia();
                    },
                    tooltip: 'Limpiar referencia',
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tablero, 'BuscUsuario'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: UsuarioSearchWidget(
                    controller: _usuarioController,
                    onSeleccionar: (usuario) {
                      _usuarioController.text = usuario?.name ?? '';
                      vm.aplicarFiltroUsuario(usuario);
                    },
                  ),
                ),
                // 🔹 BOTÓN PARA LIMPIAR USUARIO
                if (_usuarioController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                    onPressed: () {
                      _usuarioController.clear();
                      vm.limpiarFiltroUsuario();
                    },
                    tooltip: 'Limpiar usuario',
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPestanas(PrincipalViewModel vm, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPestanaBoton(
            vm,
            "todas",
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'Todas'),
            isDark,
          ),
          _buildPestanaBoton(
            vm,
            "creadas",
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'Creadas'),
            isDark,
          ),
          _buildPestanaBoton(
            vm,
            "asignadas",
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'Asignadas'),
            isDark,
          ),
          _buildPestanaBoton(
            vm,
            "invitadas",
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.tablero, 'Invitadas'),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPestanaBoton(
    PrincipalViewModel vm,
    String key,
    String texto,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SizedBox(
        width: 125,
        child: ElevatedButton(
          onPressed: () => vm.cambiarPestana(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: vm.pestanaSeleccionada == key
                ? (isDark ? Colors.grey[700] : Colors.grey)
                : (isDark ? const Color(0xFF2D6BE6) : const Color(0xff134895)),
          ),
          child: Text(texto, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildContenidoPrincipal(PrincipalViewModel vm, bool isDark) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.71,
      child: vm.cargando
          ? const Center(child: CircularProgressIndicator())
          : _buildContenidoSegunFiltros(vm, isDark),
    );
  }

  Widget _buildContenidoSegunFiltros(PrincipalViewModel vm, bool isDark) {
    if (vm.hayFiltrosActivos && vm.tareasFiltradasPorEstado.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.tablero, 'NoHayTareas'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black,
          ),
        ),
      );
    }

    return KanbanPageView(tareas: vm.tareasActuales);
  }

  Widget _buildPaginacion(PrincipalViewModel vm, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: vm.paginaActual > 0 ? () => vm.primeraPagina() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF2D6BE6)
                    : const Color(0xff134895),
              ),
              child: const Text("1", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: vm.paginaActual > 0 ? () => vm.anteriorPagina() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF2D6BE6)
                    : const Color(0xff134895),
              ),
              child: const Text("<<", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Text(
              "Pg. ${vm.paginaActual + 1}",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => vm.siguientePagina(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF2D6BE6)
                    : const Color(0xff134895),
              ),
              child: const Text(">>", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }
}
