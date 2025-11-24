import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart';
import 'package:fl_business/displays/vehiculos/views/Items_Vehiculo_view.dart';
import 'package:fl_business/displays/vehiculos/views/datos_guardados_view.dart';
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
      context.read<InicioVehiculosViewModel>().cargarDatosIniciales();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InicioVehiculosViewModel>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Recepción de Vehículos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.white),
            tooltip: 'Guardar',
            onPressed: vm.guardar,
          ),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, color: Colors.white),
            tooltip: 'Cancelar',
            onPressed: vm.cancelar,
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            tooltip: 'Ver datos guardados',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DatosGuardadosScreen(vm: vm),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.car_repair_rounded, color: Colors.white),
            tooltip: 'Ver ítems de vehículo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ItemsVehiculoScreen(),
                ),
              );
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
                  _buildModernSection(
                    title: 'Datos del Cliente',
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField('NIT', vm.nitController),
                      _buildTextField('Nombre', vm.nombreController),
                      _buildTextField('Dirección', vm.direccionController),
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
                        label: 'Fecha salida',
                        fecha: vm.fechaSalida,
                        onFechaSeleccionada: vm.seleccionarFechaSalida,
                      ),
                    ],
                  ),
                ],
              ),
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
                      (v) {
                        vm.seleccionarColor(v);
                        ScaffoldMessenger.of(tabContext).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Datos del vehículo completos'),
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

  // 🔍 Selector con buscador
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
              final fechaSeleccionada = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
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
