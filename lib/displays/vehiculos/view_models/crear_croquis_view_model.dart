import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/models/elemento_asignado_croquis_model.dart';
import 'package:fl_business/displays/vehiculos/services/elemento_asignado_croquis_service.dart';
import 'package:fl_business/displays/vehiculos/services/upload_service.dart';
import 'package:fl_business/displays/vehiculos/view_models/inicio_model_view.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CrearCroquisViewModel extends ChangeNotifier {
  final TextEditingController nombreController = TextEditingController();

  List<CroquisModel> croquisActualizar = [];
  String? imagenSeleccionada;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _modoActualizar = false;
  bool get modoActualizar => _modoActualizar;
  bool estadoSeleccionado = true;
  bool get tieneCroquisSeleccionado => croquisSeleccionado != null;

  final UploadService _uploadService = UploadService();

  final CroquisService _croquisService = CroquisService();

  void seleccionarImagen(String path) {
    imagenSeleccionada = path;

    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void abrirActualizar() {
    _modoActualizar = true;

    notifyListeners();
  }

  void volverCrear() {
    _modoActualizar = false;

    notifyListeners();
  }

  Future<void> cargarPantalla() async {
    try {
      isLoading = true;

      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print("ERROR CARGANDO PANTALLA: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<void> crearCroquis(BuildContext context) async {
    final vm = Provider.of<InicioVehiculosViewModel>(context, listen: false);

    if (nombreController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ingrese nombre")));

      return;
    }

    if (imagenSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Seleccione imagen")));

      return;
    }

    try {
      // mostrar pantalla cargando
      isLoading = true;

      final login = Provider.of<LoginViewModel>(context, listen: false);

      final empresaVM = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      );

      final estacionTrabajo = empresaVM.selectedEstacion!.estacionTrabajo;

      final token = login.token;

      final user = login.user;

      final empresa = empresaVM.selectedEmpresa!.empresa;

      String? imagenUrl;

      // SUBIR IMAGEN

      final archivos = await _uploadService.uploadImages(
        imagePaths: [imagenSeleccionada!],

        token: token,

        user: user,

        urlCarpeta: "E:/LUBRITEC/PO/UploadFile",
      );

      if (archivos.isNotEmpty) {
        final nombreArchivo = archivos.first.system;

        imagenUrl =
            "https://po.proyect1.com/cl/lubritec/PO/UploadFile/$nombreArchivo";
      }

      // CREAR CROQUIS

      final model = CrearCroquisModel(
        descripcion: nombreController.text,

        imagenUrl: imagenUrl,

        empresa: empresa,

        estacionTrabajo: estacionTrabajo,

        userName: user,
      );

      final response = await _croquisService.crearCroquis(model, token);

      print(response.message);

      // LIMPIAR CAMPOS

      nombreController.clear();

      imagenSeleccionada = null;

      notifyListeners();
      await vm.cargarCroquis(context);
      // mensaje de éxito

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Elemento creado correctamente"),

          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("ERROR CREANDO CROQUIS: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creando elemento: $e")));
    } finally {
      // quitar pantalla cargando siempre

      isLoading = false;
    }
  }

  Future<void> cargarCroquisActualizar(BuildContext context) async {
    try {
      isLoading = true;

      final login = Provider.of<LoginViewModel>(context, listen: false);

      final empresaVM = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      );

      final response = await _croquisService.obtenerCroquisTodos(
        empresaVM.selectedEmpresa!.empresa,
        login.token,
      );

      if (response.status) {
        croquisActualizar = response.data as List<CroquisModel>;

        notifyListeners();
      }
    } catch (e) {
      print("ERROR CARGANDO CROQUIS ACTUALIZAR: $e");
    } finally {
      isLoading = false;
    }
  }

  CroquisModel? croquisSeleccionado;

  void seleccionarCroquis(CroquisModel item) {
    croquisSeleccionado = item;

    nombreController.text = item.descripcion ?? "";

    imagenSeleccionada = item.imagenUrl;

    estadoSeleccionado = item.estado == 1;

    notifyListeners();
  }

  void cambiarEstado(bool valor) {
    estadoSeleccionado = valor;

    notifyListeners();
  }

  Future<void> actualizarCroquis(BuildContext context) async {
    if (croquisSeleccionado == null) {
      return;
    }

    try {
      isLoading = true;

      final login = Provider.of<LoginViewModel>(context, listen: false);

      final empresaVM = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      );

      String? nuevaImagen;

      // Si cambió imagen subirla
      if (imagenSeleccionada != null &&
          !imagenSeleccionada!.startsWith("http")) {
        final archivos = await _uploadService.uploadImages(
          imagePaths: [imagenSeleccionada!],

          token: login.token,

          user: login.user,

          urlCarpeta: "E:/LUBRITEC/PO/UploadFile",
        );

        if (archivos.isNotEmpty) {
          nuevaImagen =
              "https://po.proyect1.com/cl/lubritec/PO/UploadFile/${archivos.first.system}";
        }
      }

      final model = ActualizarCroquisModel(
        consecutivoInterno: croquisSeleccionado!.consecutivoInterno,

        descripcion: nombreController.text,

        imagenUrl: nuevaImagen ?? croquisSeleccionado!.imagenUrl,

        estado: estadoSeleccionado ? 1 : 0,

        mUserName: login.user,
      );

      final response = await _croquisService.actualizarCroquis(
        model,
        login.token,
      );

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Croquis actualizado correctamente"),

            backgroundColor: Colors.green,
          ),
        );

        croquisSeleccionado = null;

        nombreController.clear();

        imagenSeleccionada = null;

        await cargarCroquisActualizar(context);
      }
    } catch (e) {
      print("ERROR ACTUALIZANDO CROQUIS: $e");
    } finally {
      isLoading = false;
    }
  }
}
