import 'dart:convert';
import 'dart:math';

import 'package:fl_business/displays/prc_documento_3/models/amount_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/client_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/cuenta_correntista_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/doc_estructura_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/parametro_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/post_document_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/seller_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/serie_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/tipo_referencia_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/tipo_transaccion_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/tra_interna_model.dart';
import 'package:fl_business/displays/prc_documento_3/services/cuenta_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/document_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/fel_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/location_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/parametro_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/serie_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/tipo_referenci_service.dart';
import 'package:fl_business/displays/prc_documento_3/services/tipo_transaccion_service.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/details_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/document_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/payment_view_model.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/vehiculos/services/vehiculos_service.dart';
import 'package:fl_business/fel/models/credencial_model.dart';
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/elemento_asignado_view_model.dart';
import 'package:fl_business/view_models/home_view_model.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:fl_business/view_models/referencia_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// ============================================================================
///                               MODELO DEL ÍTEM
/// ============================================================================
/// Representa un ítem a revisar en el vehículo.
/// Cada ítem puede tener:
/// - ID y descripción
/// - Detalle adicional
/// - Estado de completado
/// - Varias fotos tomadas desde la cámara
class ItemVehiculo {
  final String idProducto;
  final String desProducto;

  String detalle;
  bool completado;

  // Lista de fotografías asociadas al ítem
  List<XFile> fotos = [];

  ItemVehiculo({
    required this.idProducto,
    required this.desProducto,
    this.detalle = '',
    this.completado = false,
    List<XFile>? fotos,
  }) : fotos = fotos ?? [];
}

/// ============================================================================
///                           VIEWMODEL PRINCIPAL
/// ============================================================================
/// Controla y almacena toda la información del formulario
/// de ingreso del vehículo, datos del cliente y los ítems revisados.
///
/// Provee métodos para:
/// - Cargar marcas, modelos, años y colores desde la API
/// - Seleccionar valores
/// - Guardar la información
/// - Limpiar todos los datos
class InicioVehiculosViewModel extends ChangeNotifier {
  /// Servicio que obtiene datos desde la API
  //Cliente selecciinado
  ClientModel? clienteSelect;
  //Key for form
  GlobalKey<FormState> formKeyClient = GlobalKey<FormState>();
  //Seleccionar consummidor final
  bool cf = false;

  //cinsecutivo para obtener plantilla (impresion)
  int consecutivoDoc = 0;
  DocEstructuraModel? docGlobal;
  // ============================================================================
  //                          ESTADO GENERAL Y ERRORES
  // ============================================================================
  bool isLoading = false;
  String? error;
  SerieModel? serieSelect;
  SellerModel? vendedorSelect;
  // ============================================================================
  //                          DATOS DEL CLIENTE
  // ============================================================================
  String nit = '';
  String nombre = '';
  String direccion = '';
  String celular = '';
  String email = '';

  // ============================================================================
  //                          OBSERVACIONES DEL VEHÍCULO
  // ============================================================================
  String detalleTrabajo = '';
  String kilometraje = '';
  String cc = '';
  String cil = '';

  // ============================================================================
  //                          CONTROLADORES DE INPUT
  // ============================================================================
  final TextEditingController detalleTrabajoController =
      TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController kilometrajeController = TextEditingController();
  final TextEditingController ccController = TextEditingController();
  final TextEditingController cilController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final List<SellerModel> cuentasCorrentistasRef = []; //cuenta correntisat ref
  final List<SerieModel> series = [];
  final List<ParametroModel> parametros = [];
  final List<TipoReferenciaModel> referencias = [];
  final List<TipoTransaccionModel> tiposTransaccion = [];
  //Controlador input buscar cliente
  final TextEditingController client = TextEditingController();
  final List<ClientModel> cuentasCorrentistas = []; //cunetas correntisat

  // ============================================================================
  //                          FECHAS
  // ============================================================================
  String fechaRecibido = '';
  String fechaSalida = '';

  // ============================================================================
  //                          LISTAS OBTENIDAS DE API
  // ============================================================================
  List<VehiculoModel> marcas = [];
  List<VehiculoModel> modelos = [];
  List<VehiculoYearModel> anios = [];
  List<VehiculoModel> colores = [];

  // ============================================================================
  //                          SELECCIONES DEL USUARIO
  // ============================================================================
  VehiculoModel? marcaSeleccionada;
  VehiculoModel? modeloSeleccionado;
  VehiculoYearModel? anioSeleccionado;
  VehiculoModel? colorSeleccionado;

  // ============================================================================
  //                          LISTA DE ÍTEMS DEL VEHÍCULO
  // ============================================================================
  List<ItemVehiculo> itemsAsignados = [];

  /// Reemplaza la lista completa de ítems
  void setItemsAsignados(List<ItemVehiculo> items) {
    itemsAsignados = items;
    notifyListeners();
  }

  /// Actualiza un ítem específico por ID
  void actualizarItem(String idProducto, {String? detalle, bool? completado}) {
    final index = itemsAsignados.indexWhere((e) => e.idProducto == idProducto);
    if (index != -1) {
      final item = itemsAsignados[index];

      if (detalle != null) item.detalle = detalle;
      if (completado != null) item.completado = completado;

      notifyListeners();
    }
  }

  /// Elimina todos los ítems y limpia la pantalla
  void limpiarItems() {
    itemsAsignados.clear();
    notifyListeners();
  }

  // ============================================================================
  //                          CARGA INICIAL DESDE API
  // ============================================================================
  final VehiculoService _vehiculoService = VehiculoService();

  Future<void> cargarDatosIniciales(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      setIdDocumentoRef();

      final MenuViewModel vmMenu = Provider.of<MenuViewModel>(
        context,
        listen: false,
      );

      loadSeries(context, vmMenu.documento!);

      marcas = await _vehiculoService.obtenerMarcas();
      anios = await _vehiculoService.obtenerAnios();
      colores = await _vehiculoService.obtenerColores();
    } catch (e) {
      error = 'Error al cargar datos: $e';
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================================
  //                               SELECCIÓN DE DATOS
  // ============================================================================
  /// Selecciona la marca y carga los modelos asociados
  Future<void> seleccionarMarca(VehiculoModel marca) async {
    marcaSeleccionada = marca;
    modeloSeleccionado = null;
    modelos = [];
    notifyListeners();

    try {
      modelos = await _vehiculoService.obtenerModelos(marca.id);
      notifyListeners();
    } catch (e) {
      error = 'Error al cargar modelos: $e';
      notifyListeners();
    }
  }

  /// Selecciona un modelo
  void seleccionarModelo(VehiculoModel modelo) {
    modeloSeleccionado = modelo;
    notifyListeners();
  }

  /// Selecciona el año
  void seleccionarAnio(VehiculoYearModel anio) {
    anioSeleccionado = anio;
    notifyListeners();
  }

  /// Selecciona el color
  void seleccionarColor(VehiculoModel color) {
    colorSeleccionado = color;
    notifyListeners();
  }

  /// Selecciona la fecha de recibido
  void seleccionarFechaRecibido(String fecha) {
    fechaRecibido = fecha;
    notifyListeners();
  }

  /// Selecciona la fecha de salida
  void seleccionarFechaSalida(String fecha) {
    fechaSalida = fecha;
    notifyListeners();
  }

  // ============================================================================
  //                           GUARDAR INFORMACIÓN
  // ============================================================================
  /// Carga los valores de los TextControllers a las variables reales
  void guardar() {
    nit = nitController.text;
    nombre = nombreController.text;
    direccion = direccionController.text;
    detalleTrabajo = detalleTrabajoController.text;
    celular = celularController.text;
    email = emailController.text;
    kilometraje = kilometrajeController.text;
    cc = ccController.text;
    cil = cilController.text;

    debugPrint('Guardando datos del vehículo y cliente...');
    debugPrint('NIT: $nit, Nombre: $nombre, Dirección: $direccion');
    debugPrint(
      'Marca: ${marcaSeleccionada?.descripcion}, Modelo: ${modeloSeleccionado?.descripcion}',
    );
    debugPrint(
      'Año: ${anioSeleccionado?.anio}, Color: ${colorSeleccionado?.descripcion}',
    );
    debugPrint('Detalle: $detalleTrabajo, Celular: $celular, Email: $email');
    debugPrint('KM: $kilometraje, CC: $cc, CIL: $cil');
    debugPrint('Fecha recibido: $fechaRecibido, Fecha salida: $fechaSalida');

    notifyListeners();
  }

  // ============================================================================
  //                           LIMPIAR FORMULARIO COMPLETO
  // ============================================================================
  void cancelar() {
    nit = '';
    nombre = '';
    direccion = '';
    detalleTrabajo = '';
    celular = '';
    email = '';
    kilometraje = '';
    cc = '';
    cil = '';
    marcaSeleccionada = null;
    modeloSeleccionado = null;
    anioSeleccionado = null;
    colorSeleccionado = null;
    fechaRecibido = '';
    fechaSalida = '';

    limpiarItems();

    // Limpiar controladores
    detalleTrabajoController.clear();
    celularController.clear();
    emailController.clear();
    kilometrajeController.clear();
    ccController.clear();
    cilController.clear();
    nitController.clear();
    nombreController.clear();
    direccionController.clear();

    notifyListeners();
  }

  int idDocumentoRef = 0;

  void setIdDocumentoRef() {
    DateTime date = DateTime.now();

    final random = Random();
    int numeroAleatorio = 100 + random.nextInt(900); // 100 a 999

    // Combinar los dos números para formar uno de 14 dígitos
    String combinedStr =
        numeroAleatorio.toString() +
        date.day.toString().padLeft(2, '0') +
        date.month.toString().padLeft(2, '0') +
        date.year.toString() +
        date.hour.toString().padLeft(2, '0') +
        date.minute.toString().padLeft(2, '0') +
        date.second.toString().padLeft(2, '0');

    // ref id
    idDocumentoRef = int.parse(combinedStr);
    notifyListeners();
  }

  //agregar consumidor final
  changeCF(BuildContext context, bool value) {
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);

    cf = value;

    //si cf es verdadero
    if (cf) {
      //seleccionar consumidor final
      clienteSelect = ClientModel(
        cuentaCorrentista: 1,
        cuentaCta: "1",
        facturaNombre: "CONSUMIDOR FINAL",
        facturaNit: "C/F",
        facturaDireccion: "CIUDAD",
        cCDireccion: "Ciudad",
        desCuentaCta: "C/F",
        direccion1CuentaCta: "Ciudad",
        eMail: "",
        telefono: "",
        limiteCredito: 0,
        permitirCxC: false,
        celular: null,
        desGrupoCuenta: null,
        grupoCuenta: 0,
      );
      //Mensaje de confirmacion
      NotificationService.showSnackbar(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'clienteSelec'),
      );

      if (!vmFactura.editDoc) {
        DocumentService.saveDocumentLocal(context);
      }
    } else {
      //no seleccionar
      clienteSelect = null;
      if (!vmFactura.editDoc) {
        DocumentService.saveDocumentLocal(context);
      }
    }

    notifyListeners();
  }

  //Cliente

  String getTextCuenta(BuildContext context) {
    String fileName = AppLocalizations.of(
      context,
    )!.translate(BlockTranslate.factura, 'cuenta');

    for (var i = 0; i < parametros.length; i++) {
      final ParametroModel param = parametros[i];

      //buscar nombre del campo en el parametro 57
      if (param.parametro == 57) {
        fileName =
            param.paCaracter ??
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.factura, 'cuenta');
        break;
      }
    }

    fileName = capitalizeFirstLetter(fileName);

    return fileName;
  }

  String capitalizeFirstLetter(String text) {
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  bool isValidFormClient() {
    return formKeyClient.currentState?.validate() ?? false;
  }

  setText(String value) {
    client.text = value;
    notifyListeners();
  }

  //Buscar clientes
  Future<void> performSearchClient(BuildContext context) async {
    //ocultar cliente
    FocusScope.of(context).unfocus();

    //Validar formualarios
    if (!isValidFormClient()) return;

    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final MenuViewModel menuVM = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

    //Datos necesarios
    int empresa = localVM.selectedEmpresa!.empresa;
    int estacion = localVM.selectedEstacion!.estacionTrabajo;
    String user = loginVM.user;
    String token = loginVM.token;
    int app = menuVM.app;

    //limpiar lista clientes
    cuentasCorrentistas.clear();

    //intancia del servicio
    CuentaService cuentaService = CuentaService();

    //load prosses
    vmFactura.isLoading = true;

    //Consumo del api
    ApiResModel res = await cuentaService.getCuentaCorrentista(
      empresa, // empresa,
      client.text, // filter,
      user, // user,
      token, // token,
      app,
    );

    //Stop process

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta
      vmFactura.isLoading = false;

      await NotificationService.showErrorView(context, res);
      return;
    }

    //agregar clientes seleccionados
    cuentasCorrentistas.addAll(res.response);

    // si no se encontró nada mostrar mensaje
    if (cuentasCorrentistas.isEmpty) {
      //buscar nit cui en sat

      final docVM = Provider.of<DocumentViewModel>(context, listen: false);

      if (!docVM.printFel()) {
        vmFactura.isLoading = false;

        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'sinRegistros'),
        );
        return;
      }

      final FelService felService = FelService();

      final ApiResModel resCredenciales = await felService.getCredenciales(
        1, //TODO:Parametrizar certificador
        empresa,
        user,
        token,
      );

      if (!resCredenciales.succes) {
        //si algo salio mal mostrar alerta
        vmFactura.isLoading = false;

        NotificationService.showErrorView(context, resCredenciales);
        return;
      }

      final List<CredencialModel> credenciales = resCredenciales.response;

      String llaveApi = "";
      String usuarioApi = "";

      for (var credencial in credenciales) {
        switch (credencial.campoNombre) {
          case "LlaveApi":
            llaveApi = credencial.campoValor;

            break;
          case "UsuarioApi":
            usuarioApi = credencial.campoValor;
            break;
          default:
            break;
        }
      }

      //elimar guines
      final receptor = client.text.replaceAll(RegExp(r'[\s\-]'), '');

      final ApiResModel resRecpetor = await felService.getReceptor(
        token,
        llaveApi,
        usuarioApi,
        receptor,
      );

      if (!resRecpetor.succes) {
        //si algo salio mal mostrar alerta
        vmFactura.isLoading = false;

        NotificationService.showErrorView(context, resRecpetor);
        return;
      }

      if (resRecpetor.response.toString().isEmpty) {
        vmFactura.isLoading = false;

        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'sinRegistros'),
        );
        return;
      }

      CuentaCorrentistaModel cuenta = CuentaCorrentistaModel(
        cuentaCuenta: "",
        grupoCuenta: 0,
        cuenta: 0,
        nombre: resRecpetor.response,
        direccion: "",
        telefono: "",
        correo: "",
        nit: client.text,
      );

      ApiResModel resNewAccount = await cuentaService.postCuenta(
        user,
        empresa,
        token,
        cuenta,
        estacion,
      );

      //validar respuesta del servico, si es incorrecta
      if (!resNewAccount.succes) {
        //si algo salio mal mostrar alerta
        vmFactura.isLoading = false;

        NotificationService.showErrorView(context, resNewAccount);
        return;
      }

      ApiResModel resClient = await cuentaService.getCuentaCorrentista(
        empresa,
        cuenta.nit,
        user,
        token,
        app,
      );

      //validar respuesta del servico, si es incorrecta
      if (!resClient.succes) {
        vmFactura.isLoading = false;

        await NotificationService.showErrorView(context, resClient);

        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'cuentaCreadaNoSelec'),
        );
        return;
      }

      final List<ClientModel> clients = resClient.response;

      if (clients.isEmpty) {
        vmFactura.isLoading = false;

        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'cuentaCreadaNoSelec'),
        );
        return;
      }

      if (clients.length == 1) {
        vmFactura.isLoading = false;

        selectClient(false, clients.first, context);
        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'cuentaCreadaSelec'),
        );

        if (!vmFactura.editDoc) {
          DocumentService.saveDocumentLocal(context);
        }

        return;
      }

      for (var i = 0; i < clients.length; i++) {
        final ClientModel client = clients[i];
        if (client.facturaNit == cuenta.nit) {
          selectClient(false, client, context);
          break;
        }
      }

      setText(clienteSelect?.facturaNombre ?? "");

      //mapear respuesta servicio
      NotificationService.showSnackbar(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'cuentaCreadaSelec'),
      );
    }

    //Si solo hay un cliente seleccionarlo por defecto
    if (cuentasCorrentistas.length == 1) {
      vmFactura.isLoading = false;

      clienteSelect = cuentasCorrentistas.first;
      notifyListeners();
      return;
    }

    vmFactura.isLoading = false;

    //si son varias coicidencias navegar a pantalla seleccionar cliente
    Navigator.pushNamed(
      context,
      "selectClient",
      arguments: cuentasCorrentistas,
    );
  }

  //Seleccionar clinte
  void selectClient(bool back, ClientModel client, BuildContext context) {
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);

    clienteSelect = client;

    if (!vmFactura.editDoc) {
      DocumentService.saveDocumentLocal(context);
    }

    notifyListeners();
    if (back) Navigator.pop(context);
  }

  //numero de serie

  bool valueParametro(int param) {
    bool value = false;

    //sino existe serie, retornar false
    if (serieSelect == null) return false;

    //validar que exista el parametro

    for (var i = 0; i < parametros.length; i++) {
      final ParametroModel parametro = parametros[i];

      if (parametro.parametro == param) {
        value = true;
        break;
      }
    }

    return value;
  }

  TipoReferenciaModel? referenciaSelect;

  obtenerReferencias(BuildContext context) async {
    final vmLogin = Provider.of<LoginViewModel>(context, listen: false);

    final vmHome = Provider.of<HomeViewModel>(context, listen: false);

    final String user = vmLogin.user;
    final String token = vmLogin.token;

    //evaluar el parametro 58
    TipoReferenciaService referenciaService = TipoReferenciaService();

    if (valueParametro(58)) {
      referencias.clear();
      referenciaSelect = null;

      //Consumo del servicio
      ApiResModel resTiposRef = await referenciaService.getTiposReferencia(
        user, //user
        token, // token,
      );

      //valid succes response
      if (!resTiposRef.succes) {
        //si algo salio mal mostrar alerta
        await NotificationService.showErrorView(context, resTiposRef);
        return;
      }

      //agregar formas de pago encontradas
      referencias.addAll(resTiposRef.response);
      notifyListeners();

      vmHome.isLoading = false;
    }
  }

  bool valueTransaccion(int tipoTra) {
    bool value = false;

    //sino existe serie, retornar false
    if (serieSelect == null) return false;

    //validar que exista el parametro

    for (var i = 0; i < tiposTransaccion.length; i++) {
      final TipoTransaccionModel transaccion = tiposTransaccion[i];

      if (transaccion.tipo == tipoTra) {
        value = true;
        break;
      }
    }

    return value;
  }

  Future<void> loadParametros(BuildContext context) async {
    parametros.clear();
    ParametroService parametroService = ParametroService();

    final menuVM = Provider.of<MenuViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    String user = loginVM.user;
    String token = loginVM.token;
    int tipoDoc = menuVM.documento!;
    String serie = serieSelect!.serieDocumento!;
    int empresa = localVM.selectedEmpresa!.empresa;
    int estacion = localVM.selectedEstacion!.estacionTrabajo;

    ApiResModel res = await parametroService.getParametro(
      user,
      tipoDoc,
      serie,
      empresa,
      estacion,
      token,
    );

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //Agregar series encontradas
    parametros.addAll(res.response);

    viewCargo = valueTransaccion(4);
    viewDescuento = valueTransaccion(3);

    notifyListeners();
  }

  bool viewCargo = false;
  bool viewDescuento = false;

  Future<void> loadTipoTransaccion(BuildContext context) async {
    //instancia del servicio
    tiposTransaccion.clear();
    TipoTransaccionService tipoTransaccionService = TipoTransaccionService();

    final menuVM = Provider.of<MenuViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    //consumo del api
    ApiResModel res = await tipoTransaccionService.getTipoTransaccion(
      menuVM.documento!, // documento,
      serieSelect!.serieDocumento!, // serie,
      localVM.selectedEmpresa!.empresa, // empresa,
      loginVM.token, // token,
      loginVM.user, // user,
    );

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //Agregar series encontradas
    tiposTransaccion.addAll(res.response);
  }

  //Cargar series
  Future<void> loadSeries(BuildContext context, int tipoDocumento) async {
    //View models externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);

    //Datos necesarios
    int empresa = localVM.selectedEmpresa!.empresa;
    int estacion = localVM.selectedEstacion!.estacionTrabajo;
    String user = loginVM.user;
    String token = loginVM.token;

    //limpiar serie seleccionada
    serieSelect = null;
    //simpiar lista serie
    series.clear();

    //instancia del servicio
    SerieService serieService = SerieService();

    //consumo del api
    ApiResModel res = await serieService.getSerie(
      tipoDocumento, // documento,
      empresa, // empresa,
      estacion, // estacion,
      user, // user,
      token, // token,
    );

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //Agregar series encontradas
    series.addAll(res.response);

    //Para realizar pruebas con una sola serie
    // if (series.length > 1) {
    //   if (series.length > 1) {
    //     series.removeRange(
    //       1,
    //       series.length,
    //     ); // Borra todos los elementos excepto el primero
    //   }
    //   serieSelect = series.first;
    // }

    // si sololo hay una serie seleccionarla por defecto
    if (series.length == 1) {
      serieSelect = series.first;

      //cargar las referencias si solo hay una serie y está seleccionada
      await obtenerReferencias(context);
    }

    notifyListeners();
  }

  Future<void> changeSerie(SerieModel? value, BuildContext context) async {
    //Seleccionar serie
    serieSelect = value;

    //view model externo
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);
    final vmMenu = Provider.of<MenuViewModel>(context, listen: false);
    final vmPayment = Provider.of<PaymentViewModel>(context, listen: false);
    final vmDoc = Provider.of<DocumentViewModel>(context, listen: false);

    //niciar proceso
    vmFactura.isLoading = true;

    //Buscar vendedores de la serie
    await loadSellers(context, serieSelect!.serieDocumento!, vmMenu.documento!);
    await loadTipoTransaccion(context);
    await loadParametros(context);
    await obtenerReferencias(context); //cargar las referencias
    await vmPayment.loadPayments(context);
    vmDoc.restaurarFechas();
    //finalizar proceso
    vmFactura.isLoading = false;

    if (valueParametro(318)) {
      Provider.of<LocationService>(context, listen: false).getLocation(context);
    }

    if (!vmFactura.editDoc) {
      DocumentService.saveDocumentLocal(context);
    }

    notifyListeners();
  }

  //Seccion de serie
  Future<void> loadSellers(
    BuildContext context,
    String serie,
    int tipoDocumento,
  ) async {
    //limpiar vendedor seleccionado
    vendedorSelect = null;

    //limmpiar lista vendedor
    cuentasCorrentistasRef.clear();

    //View models externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);

    //Datos necesarios
    int empresa = localVM.selectedEmpresa!.empresa;
    String user = loginVM.user;
    String token = loginVM.token;

    //instancia del servicio
    CuentaService cuentaService = CuentaService();

    //Consummo del api
    ApiResModel res = await cuentaService.getCeuntaCorrentistaRef(
      user, // user,
      tipoDocumento, // doc,
      serie, // serie,
      empresa, // empresa,
      token, // token,
    );
  }

  //devuelve el tipo de transaccion que se va a usar
  int resolveTipoTransaccion(int tipo, BuildContext context) {
    final docVM = Provider.of<DocumentViewModel>(context, listen: false);

    for (var i = 0; i < docVM.tiposTransaccion.length; i++) {
      final TipoTransaccionModel tipoTra = docVM.tiposTransaccion[i];

      if (tipo == tipoTra.tipo) {
        return tipoTra.tipoTransaccion;
      }
    }

    //si no encunetra el tipo
    return 0;
  }

  void changeSeller(SellerModel? value) {
    vendedorSelect = value;
    notifyListeners();
  }

  //Docestructura/////////////////////////////////////////////////////////
  //enviar el odcumento
  Future<ApiResModel> sendDocument(BuildContext context) async {
    //view models ecternos

    final LocationService vmLocation = Provider.of<LocationService>(
      context,
      listen: false,
    );

    final docVM = Provider.of<DocumentViewModel>(context, listen: false);

    final elVM = Provider.of<ElementoAsigandoViewModel>(context, listen: false);

    final menuVM = Provider.of<MenuViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final detailsVM = Provider.of<DetailsViewModel>(context, listen: false);
    final paymentVM = Provider.of<PaymentViewModel>(context, listen: false);

    final ReferenciaViewModel refVM = Provider.of<ReferenciaViewModel>(
      context,
      listen: false,
    );

    //usuario token y cadena de conexion
    String user = loginVM.user;
    String tokenUser = loginVM.token;

    //valores necesarios para el docuemento
    int? cuentaVendedor = docVM.cuentasCorrentistasRef.isEmpty
        ? null
        : docVM.vendedorSelect!.cuentaCorrentista;
    int cuentaCorrentisata = clienteSelect!.cuentaCorrentista;
    String cuentaCta = clienteSelect!.cuentaCta;
    int tipoDocumento = menuVM.documento!;
    String serieDocumento = serieSelect!.serieDocumento!;
    int empresa = localVM.selectedEmpresa!.empresa;
    int estacion = localVM.selectedEstacion!.estacionTrabajo;
    List<AmountModel> amounts = paymentVM.amounts;
    List<TraInternaModel> products = detailsVM.traInternas;

    //pagos agregados
    final List<DocCargoAbono> payments = [];
    //transaciciones agregadas
    final List<DocTransaccion> transactions = [];

    var random = Random();

    // Generar dos números aleatorios de 7 dígitos cada uno
    int firstPart = random.nextInt(10000000);

    int consectivo = 1;
    //Objeto transaccion documento para estructura documento
    for (var transaction in products) {
      int padre = consectivo;
      final List<DocTransaccion> cargos = [];
      final List<DocTransaccion> descuentos = [];

      for (var operacion in transaction.operaciones) {
        //Cargo
        if (operacion.cargo != 0) {
          consectivo++;
          cargos.add(
            DocTransaccion(
              traMontoDias: null,
              traObservacion: null,
              dConsecutivoInterno: firstPart,
              traConsecutivoInterno: consectivo,
              traConsecutivoInternoPadre: padre,
              traBodega: transaction.bodega!.bodega,
              traProducto: transaction.producto.producto,
              traUnidadMedida: transaction.producto.unidadMedida,
              traCantidad: 0,
              traTipoCambio: menuVM.tipoCambio,
              traMoneda: transaction.precio!.moneda,
              traTipoPrecio: transaction.precio!.precio
                  ? transaction.precio!.id
                  : null,
              traFactorConversion: !transaction.precio!.precio
                  ? transaction.precio!.id
                  : null,
              traTipoTransaccion: resolveTipoTransaccion(4, context),
              traMonto: operacion.cargo,
            ),
          );
        }

        //Descuento
        if (operacion.descuento != 0) {
          consectivo++;

          descuentos.add(
            DocTransaccion(
              traMontoDias: null,
              traObservacion: null,
              dConsecutivoInterno: firstPart,
              traConsecutivoInterno: consectivo,
              traConsecutivoInternoPadre: padre,
              traBodega: transaction.bodega!.bodega,
              traProducto: transaction.producto.producto,
              traUnidadMedida: transaction.producto.unidadMedida,
              traCantidad: 0,
              traTipoCambio: menuVM.tipoCambio,
              traMoneda: transaction.precio!.moneda,
              traTipoPrecio: transaction.precio!.precio
                  ? transaction.precio!.id
                  : null,
              traFactorConversion: !transaction.precio!.precio
                  ? transaction.precio!.id
                  : null,
              traTipoTransaccion: resolveTipoTransaccion(3, context),
              traMonto: operacion.descuento,
            ),
          );
        }
      }

      transactions.add(
        DocTransaccion(
          traObservacion: transaction.observacion,
          dConsecutivoInterno: firstPart,
          traConsecutivoInterno: padre,
          traConsecutivoInternoPadre: null,
          traBodega: transaction.bodega!.bodega,
          traProducto: transaction.producto.producto,
          traUnidadMedida: transaction.producto.unidadMedida,
          traCantidad: transaction.cantidad,
          traTipoCambio: menuVM.tipoCambio,
          traMoneda: transaction.precio!.moneda,
          traTipoPrecio: transaction.precio!.precio
              ? transaction.precio!.id
              : null,
          traFactorConversion: !transaction.precio!.precio
              ? transaction.precio!.id
              : null,
          traTipoTransaccion: resolveTipoTransaccion(
            transaction.producto.tipoProducto,
            context,
          ),
          traMonto: transaction.total,
          traMontoDias: transaction.precioDia,
        ),
      );

      for (var cargo in cargos) {
        transactions.add(cargo);
      }

      for (var descuento in descuentos) {
        transactions.add(descuento);
      }

      consectivo++;
    }

    int consecutivoPago = 1;
    //objeto cargo abono para documento cargo abono
    for (var payment in amounts) {
      payments.add(
        DocCargoAbono(
          dConsecutivoInterno: firstPart,
          consecutivoInterno: consecutivoPago,
          tipoCargoAbono: payment.payment.tipoCargoAbono,
          monto: payment.amount,
          cambio: payment.diference,
          tipoCambio: menuVM.tipoCambio,
          moneda: transactions[0].traMoneda,
          montoMoneda: payment.amount / menuVM.tipoCambio,
          referencia: payment.reference,
          autorizacion: payment.authorization,
          banco: payment.bank?.banco,
          cuentaBancaria: payment.account?.idCuentaBancaria,
        ),
      );

      consecutivoPago++;
    }

    double totalCA = 0;

    for (var amount in amounts) {
      totalCA += amount.amount;
    }

    DateTime myDateTime = DateTime.now();
    String serializedDateTime = myDateTime.toIso8601String();
    //Objeto documento estrucutra
    docGlobal = DocEstructuraModel(
      docVersionApp: SplashViewModel.versionLocal,
      docConfirmarOrden:
          false, //TODO:parametrizar segun valor si es cotiacion de ALfa y Omega
      docComanda: null,
      docMesa: null,
      docUbicacion: null,
      docLatitud: null,
      docLongitud: null,
      consecutivoInterno: firstPart,
      docTraMonto: 0,
      docCaMonto: 0,
      docIdCertificador: 1, //TODO: Agrgar certificador
      docCuentaVendedor: null,
      docIdDocumentoRef: idDocumentoRef,
      docFelNumeroDocumento: null,
      docFelSerie: null,
      docFelUUID: null,
      docFelFechaCertificacion: null,
      docCuentaCorrentista: cuentaCorrentisata,
      docCuentaCta: cuentaCta,
      docFechaDocumento: docVM.valueParametro(173)
          ? docVM.dateDocument.toIso8601String()
          : serializedDateTime,
      docTipoDocumento: tipoDocumento,
      docSerieDocumento: serieDocumento,
      docEmpresa: empresa,
      docEstacionTrabajo: estacion,
      docUserName: user,
      docObservacion1: "",
      docTipoPago: 1, //TODO: preguntar
      docElementoAsignado: docVM.valueParametro(259)
          ? elVM.elemento!.elementoAsignado
          : null,
      docTransaccion: transactions,
      docCargoAbono: payments,
      docRefTipoReferencia: docVM.valueParametro(58)
          ? docVM.referenciaSelect?.tipoReferencia
          : null, //TODO:Si es ilgua buscar en otra parte
      docFechaIni: docVM.valueParametro(44) ? docVM.fechaInicial : null,
      docFechaFin: docVM.valueParametro(44) ? docVM.fechaFinal : null,
      docRefFechaIni: docVM.valueParametro(381) ? docVM.fechaRefIni : null,
      docRefFechaFin: docVM.valueParametro(382) ? docVM.fechaRefFin : null,
      docRefObservacion: docVM.valueParametro(383)
          ? docVM.refObservacionParam384.text
          : null,
      docRefDescripcion: docVM.valueParametro(384)
          ? docVM.refDescripcionParam383.text
          : null,
      docRefObservacion2: docVM.valueParametro(385)
          ? docVM.refContactoParam385.text
          : null,
      docRefObservacion3: docVM.valueParametro(386)
          ? docVM.refDirecEntregaParam386.text
          : null,
      docReferencia: docVM.valueParametro(58)
          ? refVM.referencia!.referencia
          : null,
    );

    //objeto enviar documento
    PostDocumentModel document = PostDocumentModel(
      estructura: docGlobal!.toJson(),
      user: user,
      estado: docVM.printFel() ? 1 : 11,
    );

    //instancia del servicio
    DocumentService documentService = DocumentService();

    //consumo del api
    ApiResModel res = await documentService.postDocument(document, tokenUser);

    return res;
  }
}
