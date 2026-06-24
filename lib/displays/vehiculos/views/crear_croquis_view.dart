import 'dart:io';

import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../view_models/crear_croquis_view_model.dart';

class CrearCroquisView extends StatelessWidget {
  const CrearCroquisView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CrearCroquisViewModel()..cargarPantalla(),

      child: const _CrearCroquisBody(),
    );
  }
}

class _CrearCroquisBody extends StatelessWidget {
  const _CrearCroquisBody();
  Future<void> seleccionarImagen(
    BuildContext context,
    CrearCroquisViewModel vm,
  ) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      vm.seleccionarImagen(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CrearCroquisViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Nuevo Croquis")),

          body: vm.modoActualizar
              ? const _ActualizarCroquisBody()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Nombre del croquis",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: vm.nombreController,

                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          hintText: "Ingrese nombre",
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Imagen",

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          seleccionarImagen(context, vm);
                        },

                        child: Container(
                          height: 180,

                          width: double.infinity,

                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: vm.imagenSeleccionada == null
                              ? const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    size: 60,
                                  ),
                                )
                              : Image.file(
                                  File(vm.imagenSeleccionada!),

                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () {
                            vm.crearCroquis(context);
                          },

                          child: const Text(
                            "Crear",

                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed: () async {
                            vm.abrirActualizar();
                            await vm.cargarCroquisActualizar(context);
                          },

                          icon: const Icon(Icons.edit, color: Colors.white),

                          label: const Text(
                            "Actualizar croquis",

                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }
}

///////////////Widget para actualizar croquis
class _ActualizarCroquisBody extends StatelessWidget {
  const _ActualizarCroquisBody();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CrearCroquisViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(20),

      child: vm.tieneCroquisSeleccionado
          ? const _FormularioActualizarCroquis()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.arrow_back),

                    //   onPressed: () {
                    //     vm.volverCrear();
                    //   },
                    // ),
                    const Text(
                      "Actualizar croquis",

                      style: TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: vm.croquisActualizar.length,

                    itemBuilder: (context, index) {
                      final item = vm.croquisActualizar[index];

                      return Card(
                        child: ListTile(
                          leading: item.imagenUrl != null
                              ? Image.network(
                                  item.imagenUrl!,

                                  width: 60,

                                  height: 60,

                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),

                          title: Text(item.descripcion ?? ""),

                          subtitle: Text(
                            item.estado == 1 ? "Activo" : "Inactivo",
                          ),

                          onTap: () {
                            vm.seleccionarCroquis(item);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _FormularioActualizarCroquis extends StatelessWidget {
  const _FormularioActualizarCroquis();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CrearCroquisViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            // IconButton(
            //   icon: const Icon(Icons.arrow_back),

            //   onPressed: () {
            //     vm.croquisSeleccionado = null;

            //     vm.notifyListeners();
            //   },
            // ),
            const Text(
              "Editar croquis",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 20),

        TextField(
          controller: vm.nombreController,

          decoration: const InputDecoration(
            labelText: "Nombre",

            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        GestureDetector(
          onTap: () {
            seleccionarImagen(context, vm);
          },

          child: Container(
            height: 180,

            width: double.infinity,

            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),

              borderRadius: BorderRadius.circular(12),
            ),

            child: vm.imagenSeleccionada != null
                ? vm.imagenSeleccionada!.startsWith("http")
                      ? Image.network(vm.imagenSeleccionada!, fit: BoxFit.cover)
                      : Image.file(
                          File(vm.imagenSeleccionada!),

                          fit: BoxFit.cover,
                        )
                : const Center(
                    child: Icon(Icons.add_photo_alternate, size: 60),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text("Activo"),

            Switch(value: vm.estadoSeleccionado, onChanged: vm.cambiarEstado),
          ],
        ),
        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,

          child: ElevatedButton(
            onPressed: () {
              vm.actualizarCroquis(context);
            },

            child: const Text(
              "Guardar cambios",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> seleccionarImagen(
    BuildContext context,
    CrearCroquisViewModel vm,
  ) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      vm.seleccionarImagen(image.path);
    }
  }
}
