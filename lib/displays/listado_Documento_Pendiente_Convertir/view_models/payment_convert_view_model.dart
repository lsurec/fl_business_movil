// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/destination_doc_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/origin_detail_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/origin_doc_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/amount_convert_view_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/convert_doc_view_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/views/views.dart';
import 'package:fl_business/displays/prc_documento_3/models/mensaje_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/services/services.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/report/reports/factura/tmu.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/fel/models/credencial_model.dart';
import 'package:fl_business/fel/models/data_infile_model.dart';
import 'package:fl_business/fel/models/doc_xml_model.dart';
import 'package:fl_business/fel/models/post_doc_xml_model.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentConvertViewModel extends ChangeNotifier {
  DestinationDocModel? destino;
  OriginDocModel? origen;

  //controlar el proceso
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Totales globales
  double saldo = 0;
  double cambio = 0;
  double pagado = 0;
  double total = 0;

  //Seleccionar todas las formas de pago
  bool selectAllAmounts = false;

  //Formas de pago agregadas
  final List<AmountModel> amounts = [];

  //Formas de pago disponibles
  final List<PaymentModel> paymentList = [];

  //Bancos disponibles
  final List<SelectBankModel> banks = [];

  //Cuentas bancarias disponibles
  final List<SelectAccountModel> accounts = [];

  //cargar formas de pago
  Future<void> loadPayments(BuildContext context) async {
    //limpiar lista
    paymentList.clear();
    amounts.clear();

    //view models exxternos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    //instancia del servicio
    PagoService pagoService = PagoService();

    //load prosses
    isLoading = true;

    //Consumo del servicio
    ApiResModel res = await pagoService.getFormas(
      destino!.fTipoDocumento, // doc,
      destino!.fSerieDocumento, // serie,
      destino!.fEmpresa, // empresa,
      loginVM.token, // token,
    );

    //stop process
    isLoading = false;

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //agregar formas de pago encontradas
    paymentList.addAll(res.response);

    calculateTotales(context);

    notifyListeners();
  }

  //cargar cuentas bancarias
  Future<void> loadCuentasBanco(BuildContext context, int banco) async {
    //limipiar lista
    accounts.clear();

    //view model externo
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);

    //instancia del servico
    PagoService pagoService = PagoService();

    //load prosses
    isLoading = true;

    ApiResModel res = await pagoService.getCuentas(
      loginVM.user, // user,
      localVM.selectedEmpresa!.empresa, // empresa,
      banco, // banco,
      loginVM.token, // token,
    );

    //stop process
    isLoading = false;

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //agreagar cuenta banccaria a un modelo nuevo
    for (var account in res.response as List<AccountModel>) {
      accounts.add(SelectAccountModel(account: account, isSelected: false));
    }

    //Si solo hay una cuenta bancaria seleccioanrlo por defecto
    if (accounts.length == 1) {
      accounts.first.isSelected = true;
    }
    notifyListeners();
  }

  //cargar bancos disponibñes
  Future<void> loadBancos(BuildContext context) async {
    //limpiar lista
    banks.clear();

    //View models externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final vmFactura = Provider.of<DocumentoViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);

    //instancia del servicio
    PagoService pagoService = PagoService();

    //load prosses
    vmFactura.isLoading = true;
    //call service obtener Informacion de usuario

    ApiResModel res = await pagoService.getBancos(
      loginVM.user, //usuario
      localVM.selectedEmpresa!.empresa, //empresa
      loginVM.token, //token
    );

    //stop process
    vmFactura.isLoading = false;

    //valid succes response
    if (!res.succes) {
      //si algo salio mal mostrar alerta

      await NotificationService.showErrorView(context, res);
      return;
    }

    //Agregar bancos a un modelo nuevo
    for (var bank in res.response as List<BankModel>) {
      banks.add(SelectBankModel(bank: bank, isSelected: false));
    }

    //si solo hay un banco seleccionarlo por defecto
    if (banks.length == 1) {
      banks.first.isSelected = true;
    }

    notifyListeners();
  }

  //cambiar cuenta bancaria seleccionada
  void changeAccountSelect(int? value, BuildContext context) {
    //Maracr todos en falso
    for (var account in accounts) {
      account.isSelected = false;
    }
    //marcar el seleccionado en verdadero
    accounts[value!].isSelected = true;

    notifyListeners();
  }

  //cambiar banco seleccionado
  void changeBankSelect(
    int? value,
    BuildContext context,
    PaymentModel payment,
  ) {
    //TODO:Revisar cambio de banco no obtiene cuentas bancaria
    //Maracr todos en falso
    for (var bank in banks) {
      bank.isSelected = false;
    }

    //marcar el selecccionado en verdadero
    banks[value!].isSelected = true;

    //Buscar el seleccionado
    SelectBankModel selectedBank = banks.firstWhere((bank) => bank.isSelected);

    //verificar si cuenta bancario es null conevrtirlo en false
    payment.reqCuentaBancaria ??= false;

    //si la cuenta bancaria es requerida buscar cuenta bancaria
    if (payment.reqCuentaBancaria) {
      loadCuentasBanco(context, selectedBank.bank.banco);
    }

    notifyListeners();
  }

  //limpiar campos de la vista del usuario
  void clearView(BuildContext context) {
    amounts.clear(); //limpiar formas de o¿pago agrefadas
    calculateTotales(context); //calcular totales
  }

  //eliminar formas de pago seleccioandas
  void deleteAmounts(BuildContext context) async {
    int numSelected = 0;

    //contar formas de pago seleccionadas
    for (var element in amounts) {
      if (element.checked) {
        numSelected += 1;
      }
    }

    //si no hay formas de pago seleccionadas mmostrar mensaje
    if (numSelected == 0) {
      NotificationService.showSnackbar(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'seleccionaTrans'),
      );
      return;
    }

    //si no estan seleccioandos todos
    if (numSelected < amounts.length) {
      //montos seleccionados
      List<AmountModel> checkedAmounts = amounts
          .where((amount) => amount.checked)
          .toList();

      //montos con diferencias
      List<AmountModel> diferencesAmounts = amounts
          .where((amount) => amount.diference > 0)
          .toList();

      //montos con diferencias selecccionados
      List<AmountModel> diferencesChecked = checkedAmounts
          .where((amount) => amount.diference > 0)
          .toList();

      //si el total de montos con diferencias y el total seekccionado con diferencias es distitnto
      if (diferencesAmounts.length != diferencesChecked.length) {
        //mostar mensaje
        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'eliminaTransConDife'),
        );
        return;
      }
    }

    //mostrar dialogo de confirmacion
    bool result =
        await showDialog(
          context: context,
          builder: (context) => AlertWidget(
            title: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.notificacion, 'confirmar'),
            description: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.notificacion, 'perder'),
            textOk: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.botones, "aceptar"),
            textCancel: AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.botones, "cancelar"),
            onOk: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;

    //cancelar
    if (!result) return;

    //eliminar los seleccionados
    amounts.removeWhere((document) => document.checked == true);
    //calcular totales
    calculateTotales(context);
  }

  //Seleccionar una forma de pago agregada
  void changeCheckedamount(bool? value, int index) {
    //cambiar valor segun checkbox
    amounts[index].checked = value!;
    notifyListeners();
  }

  //seleccionar toas las formas de pago agregadas
  void selectAllMounts(bool? value) {
    selectAllAmounts = value!;

    //Cambiar todos los valores
    for (var element in amounts) {
      element.checked = selectAllAmounts;
    }
    notifyListeners();
  }

  //Navegar a pantalla para agregar datos de la forma de pago
  //monto, autorizacion y referencia
  Future<void> navigateAmount(
    BuildContext context,
    PaymentModel payment,
  ) async {
    //limpiar cuentas
    accounts.clear();

    notifyListeners();

    // if (vmDoc.clienteSelect == null) {
    //   NotificationService.showSnackbar(
    //     AppLocalizations.of(
    //       context,
    //     )!.translate(BlockTranslate.notificacion, 'cuentaAntesPago'),
    //   );
    //   return;
    // }

    // //Vaidar si la forma de pago seleccionada es CxC y si la cuenta correntista lo permite
    // if (payment.cuentaCorriente && !vmDoc.clienteSelect!.permitirCxC) {
    //   NotificationService.showSnackbar(
    //     AppLocalizations.of(
    //       context,
    //     )!.translate(BlockTranslate.notificacion, 'sinPermisoCuentaPCobrar'),
    //   );
    //   return;
    // }

    // //si el cliente (cuenta correntista) tiene permitido CxC y la forma de pago es cuenta corriente
    // if (vmDoc.clienteSelect!.permitirCxC && payment.cuentaCorriente) {
    //   //validar limite de credito de cuenta correntista
    //   if (vmDetails.total > (vmDoc.clienteSelect?.limiteCredito ?? 0)) {
    //     //Mostrar alerta si el total a pagar supera el limite de credito
    //     NotificationService.showSnackbar(
    //       AppLocalizations.of(
    //         context,
    //       )!.translate(BlockTranslate.notificacion, 'superaLimiteCredito'),
    //     );
    //     return;
    //   }
    // }

    //validaciones para poder navegar a la pantalla
    // if (total == 0) {
    //   NotificationService.showSnackbar(
    //     AppLocalizations.of(
    //       context,
    //     )!.translate(BlockTranslate.notificacion, 'pagarCero'),
    //   );
    // } else if (saldo == 0) {
    //   NotificationService.showSnackbar(
    //     AppLocalizations.of(
    //       context,
    //     )!.translate(BlockTranslate.notificacion, 'pagarCero'),
    //   );
    // } else {
    //   if (payment.banco) await loadBancos(context);

    //   //Navegar a la pantalla siguiente
    // }
    Navigator.pushNamed(
      context,
      AmountConvertView.routeName,
      arguments: payment,
    );
  }

  confirmPayments(BuildContext context) {
    //Validar que se agregaron formas de pago
    if (paymentList.isNotEmpty) {
      //si no hay pagos agregados mostar mensaje
      if (amounts.isEmpty) {
        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'sinPago'),
        );
        return;
      }

      // si no se ha pagado el total mostrar mensaje
      if (double.parse(saldo.toStringAsFixed(2)) > 0) {
        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'saldoPendiente'),
        );
        return;
      }
    }

    //Proceso doc estructura y FEL
    processDocument(context);
  }

  /**FEL */

  List<LoadStepModel> steps = [
    LoadStepModel(text: "Creando documento...", status: 1, isLoading: true),
    LoadStepModel(
      text: "Generando firma electronica.",
      status: 1,
      isLoading: true,
    ),
  ];

  //Tareas completadas
  int stepsSucces = 0;
  //Ver infromes o errores
  bool viewMessage = false;
  bool viewError = false;

  //Ver voton reintentar firma
  bool viewErrorFel = false;

  //Ver boton reintentar proceso
  bool viewErrorProcess = false;

  //ver boton proceso exitoso
  bool viewSucces = false;

  //Error si es necesrio
  String error = "";

  //controlar proceso fel
  bool _isLoadingDTE = false;
  bool get isLoadingDTE => _isLoadingDTE;

  set isLoadingDTE(bool value) {
    _isLoadingDTE = value;
    notifyListeners();
  }

  ErrorModel? errorView;

  //cinsecutivo para obtener plantilla (impresion)
  int consecutivoDoc = 0;
  DocEstructuraModel? docGlobal;

  //Mostrar boton para imprimir
  bool _showPrint = false;
  bool get showPrint => _showPrint;

  set showPrint(bool value) {
    _showPrint = value;
    notifyListeners();
  }

  int idDocumentoRef = 0;

  //Mostrar boton para imprimir
  bool _directPrint = Preferences.directPrint;
  bool get directPrint => _directPrint;

  set directPrint(bool value) {
    _directPrint = value;
    Preferences.directPrint = value;
    notifyListeners();
  }

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

  //enviar el odcumento
  Future<ApiResModel> sendDocument(BuildContext context) async {
    setIdDocumentoRef();
    //view models ecternos

    // final LocationService vmLocation = Provider.of<LocationService>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final elVM = Provider.of<ElementoAsigandoViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final localVM = Provider.of<LocalSettingsViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final detailsVM = Provider.of<DetailsViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );
    // final paymentVM = Provider.of<PaymentViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final ReferenciaViewModel refVM = Provider.of<ReferenciaViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    final ConvertDocViewModel vmConvert = Provider.of<ConvertDocViewModel>(
      context,
      listen: false,
    );

    final DocumentViewModel docVM = Provider.of<DocumentViewModel>(
      context,
      listen: false,
    );

    //TODO:Validar carga de tipo cambio
    final MenuViewModel menuVM = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

    //usuario token y cadena de conexion
    String user = loginVM.user;
    String token = loginVM.token;

    //valores necesarios para el docuemento
    int? cuentaVendedor = origen?.cuentaCorrentistaRef;
    int cuentaCorrentisata = origen!.cuentaCorrentista!;
    String cuentaCta = origen!.cuentaCta!;
    int tipoDocumento = destino!.fTipoDocumento;
    String serieDocumento = destino!.fSerieDocumento;
    int empresa = destino!.fEmpresa;
    int estacion = origen!.estacionTrabajo; //TODO:Confirmar datos

    final ProductService productService = ProductService();

    List<DetailOriginDocInterModel> products = vmConvert.detailsOrigin
        .where((elemento) => elemento.checked)
        .toList();

    //validar transaccionnes
    for (var item in products) {
      //consumo del api
      ApiResModel resDisponibiladProducto = await productService
          .getValidaProducto(
            user,
            destino!.fSerieDocumento,
            destino!.fTipoDocumento, //TODO:Confirmar datos
            origen!.estacionTrabajo, //TODO:Confirmar datos
            destino!.fEmpresa,
            item.detalle.bodega,
            // item.tipoTransaccion!, //TODO:NO esta en el modelo
            1, //TODO:NO esta en el modelo
            item.detalle.unidadMedida,
            item.detalle.producto,
            item.detalle.cantidad.toInt(),
            menuVM.tipoCambio.toInt(), //TODO:No esta en el modelo
            // item.precio!.moneda, //TODO:NO esta en el modelo
            1, //TODO:NO esta en el modelo
            item.detalle.tipoPrecio,
            token,
            origen!.cuentaCorrentista!,
            origen!.cuentaCta!,
            docVM.fechaInicial,
            docVM.fechaFinal,
            item.detalle.monto,
            total,
          );

      if (!resDisponibiladProducto.succes) {
        isLoading = false;

        //si algo salio mal mostrar alerta
        await NotificationService.showErrorView(
          context,
          resDisponibiladProducto,
        );

        return ApiResModel(
          typeError: 1,
          succes: false,
          response: AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'errorValidarProducto'),
          url: resDisponibiladProducto.url,
          storeProcedure: resDisponibiladProducto.storeProcedure,
        );
      }

      //almacenar los mensajes
      //almacenar los mensajes
      final List<MensajeModel> resMensajes = resDisponibiladProducto.response;

      final List<String> mensajes = [];

      for (var element in resMensajes) {
        if (!element.resultado) {
          mensajes.add(element.mensaje ?? "");
        }
      }
      if (mensajes.isNotEmpty) {
        //Lista para agregar las validaciones
        List<ValidateProductModel> validaciones = [];
        //detener carga
        isLoading = false;

        ValidateProductModel validacion = ValidateProductModel(
          sku: item.detalle.producto.toString(),
          productoDesc: item.detalle.productoDescripcion,
          bodega: "${item.detalle.bodegaDescripcion} (${item.detalle.bodega})",
          tipoDoc: "${destino!.fTipoDocumento}",
          serie: destino!.fSerieDocumento,
          mensajes: mensajes,
        );

        //insertar registros
        validaciones.add(validacion);

        //aqui abre un dialogo con notificacion
        await NotificationService.showMessageValidations(context, validaciones);

        return ApiResModel(
          typeError: 1,
          succes: false,
          response: AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'errorValidarProducto'),
          url: resDisponibiladProducto.url,
          storeProcedure: resDisponibiladProducto.storeProcedure,
        );
      }
    }

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

      // for (var operacion in transaction.operaciones) {
      //   //Cargo
      //   if (operacion.cargo != 0) {
      //     consectivo++;
      //     cargos.add(
      //       DocTransaccion(
      //         traMontoDias: null,
      //         traObservacion: null,
      //         dConsecutivoInterno: firstPart,
      //         traConsecutivoInterno: consectivo,
      //         traConsecutivoInternoPadre: padre,
      //         traBodega: transaction.bodega!.bodega,
      //         traProducto: transaction.producto.producto,
      //         traUnidadMedida: transaction.producto.unidadMedida,
      //         traCantidad: 0,
      //         traTipoCambio: menuVM.tipoCambio,
      //         traMoneda: transaction.precio!.moneda,
      //         traTipoPrecio: transaction.precio!.precio
      //             ? transaction.precio!.id
      //             : null,
      //         traFactorConversion: !transaction.precio!.precio
      //             ? transaction.precio!.id
      //             : null,
      //         traTipoTransaccion: transaction.tipoTransaccion!,
      //         traMonto: operacion.cargo,
      //       ),
      //     );
      //   }

      //   //Descuento
      //   if (operacion.descuento != 0) {
      //     consectivo++;

      //     descuentos.add(
      //       DocTransaccion(
      //         traMontoDias: null,
      //         traObservacion: null,
      //         dConsecutivoInterno: firstPart,
      //         traConsecutivoInterno: consectivo,
      //         traConsecutivoInternoPadre: padre,
      //         traBodega: transaction.bodega!.bodega,
      //         traProducto: transaction.producto.producto,
      //         traUnidadMedida: transaction.producto.unidadMedida,
      //         traCantidad: 0,
      //         traTipoCambio: menuVM.tipoCambio,
      //         traMoneda: transaction.precio!.moneda,
      //         traTipoPrecio: transaction.precio!.precio
      //             ? transaction.precio!.id
      //             : null,
      //         traFactorConversion: !transaction.precio!.precio
      //             ? transaction.precio!.id
      //             : null,
      //         traTipoTransaccion: transaction.tipoTransaccion!,
      //         traMonto: operacion.descuento,
      //       ),
      //     );
      //   }
      // }

      transactions.add(
        DocTransaccion(
          traObservacion: "", //TODO:No esta en el modelo
          dConsecutivoInterno: firstPart,
          traConsecutivoInterno: padre,
          traConsecutivoInternoPadre: null,
          traBodega: transaction.detalle.bodega,
          traProducto: transaction.detalle.producto,
          traUnidadMedida: transaction.detalle.unidadMedida,
          traCantidad: transaction.detalle.cantidad.toInt(),
          traTipoCambio: menuVM.tipoCambio, //TODO:No esta en el modelo
          // traMoneda: transaction.precio!.moneda, //TODO:No esta en el modelo
          traMoneda: 1, //TODO:No esta en el modelo
          traTipoPrecio: transaction.detalle.tipoPrecio,
          traFactorConversion: null, //TODO:No esta en el modelo
          // traTipoTransaccion: transaction.tipoTransaccion!, //TODO:No esta en el modelo
          traTipoTransaccion: 1, //TODO:No esta en el modelo
          traMonto: transaction.detalle.monto,
          traMontoDias: 0, //TODO:Calcular si ecotizacion (Alfa y Omega)
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
      docLatitud: "", //TODO: Obtener latitud
      docLongitud: "", //TODO: Obtener longitud
      consecutivoInterno: firstPart,
      docTraMonto: total,
      docCaMonto: totalCA,
      docIdCertificador: 1, //TODO: Agrgar certificador
      docCuentaVendedor: cuentaVendedor,
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
      docObservacion1: origen!.observacion1 ?? "",
      docTipoPago: 1, //TODO: preguntar
      docElementoAsignado: null, //TODO: Agregar elemento asignado
      docTransaccion: transactions,
      docCargoAbono: payments,
      docRefTipoReferencia:
          origen!.tipoReferencia, //TODO:Si es ilgua buscar en otra parte
      docFechaIni: origen!.fechaIni,
      docFechaFin: origen!.fechaFin,
      docRefFechaIni: origen!.referenciaDFechaIni,
      docRefFechaFin: origen!.referenciaDFechaFin,
      docRefObservacion: origen!.referenciaDObservacion,
      docRefDescripcion: origen!.referenciaDDescripcion,
      docRefObservacion2: origen!.referenciaDObservacion2,
      docRefObservacion3: origen!.referenciaDObservacion3,
      docReferencia: origen!.referencia, //TODO: Validar referencia
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
    ApiResModel res = await documentService.postDocument(document, token);

    return res;
  }

  //certificar DTE (Servicios del certificador)
  Future<ApiResModel> certDTE(BuildContext context) async {
    //Proveedor de datos externo
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    //usuario token y cadena de conexion
    int empresa = destino!.fEmpresa;
    String user = loginVM.user;
    String token = loginVM.token;
    String uuid = "";
    String apiUse = "";
    int certificador = 1; //TODO:parametrizar

    //Servicio para documentos

    final FelService felService = FelService();

    //Obtener plantilla xml para certificar
    ApiResModel resXmlDoc = await felService.getDocXml(
      user,
      token,
      consecutivoDoc,
    );

    //Si el api falló
    if (!resXmlDoc.succes) return resXmlDoc;

    //plantilla del documento
    List<DocXmlModel> docs = resXmlDoc.response;

    //si no se encuntra el documento
    if (docs.isEmpty) {
      return ApiResModel(
        typeError: 1,
        succes: false,
        response: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'noDispoDocCert'),
        url: "",
        storeProcedure: null,
      );
    }

    //Docuemnto que se va a usar
    DocXmlModel docXMl = docs.first;
    uuid = docXMl.dIdUnc;
    //Certificador del que se obtiene el token

    //obtner credenciales
    ApiResModel resCredenciales = await felService.getCredenciales(
      certificador,
      empresa,
      user,
      token,
    );

    //Si el api falló
    if (!resCredenciales.succes) return resCredenciales;

    //Credenciales encontradas
    List<CredencialModel> credenciales = resCredenciales.response;

    //Si se quiere certificar un documento buscar el api que se va a usar
    for (var credencial in credenciales) {
      if (credencial.campoNombre == 'apiUnificadaInfile') {
        //econtrar api en catalogo api (identificador)
        apiUse = credencial.campoValor;
        break;
      }
    }

    //si no se encpntró el api que se va a usar mostrar alerta
    if (apiUse.isEmpty) {
      return ApiResModel(
        typeError: 1,
        succes: false,
        response: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'noDispoServiProceDoc'),
        url: "",
        storeProcedure: null,
      );
    }

    String llaveApi = "";
    String llaveFirma = "";
    String usuarioApi = "";
    String usuarioFirma = "";

    for (var i = 0; i < credenciales.length; i++) {
      final CredencialModel credencial = credenciales[i];

      switch (credencial.campoNombre) {
        case "LlaveApi":
          llaveApi = credencial.campoValor;

          break;
        case "LlaveFirma":
          llaveFirma = credencial.campoValor;
          break;

        case "UsuarioApi":
          usuarioApi = credencial.campoValor;
          break;
        case "UsuarioFirma":
          usuarioFirma = credencial.campoValor;
          break;
        default:
          break;
      }
    }

    final DataInfileModel paramFel = DataInfileModel(
      usuarioFirma: usuarioFirma,
      llaveFirma: llaveFirma,
      usuarioApi: usuarioApi,
      llaveApi: llaveApi,
      identificador: uuid,
      docXml: docXMl.xmlContenido,
      //       docXml:
      //           """<dte:GTDocumento xmlns:dte="http://www.sat.gob.gt/dte/fel/0.2.0" Version="0.1">
      //   <dte:SAT ClaseDocumento="dte">
      //     <dte:DTE ID="DatosCertificados">
      //       <dte:DatosEmision ID="DatosEmision">
      //         <dte:DatosGenerales CodigoMoneda="GTQ" FechaHoraEmision="2024-06-03T02:53:51.000-06:00" Tipo="FCAM" />
      //         <dte:Emisor AfiliacionIVA="GEN" CodigoEstablecimiento="1" CorreoEmisor="" NITEmisor="9300000118K" NombreComercial="TEXAS MUEBLES Y MAS" NombreEmisor="CORPORACION NR, SOCIEDAD ANONIMA">
      //           <dte:DireccionEmisor>
      //             <dte:Direccion>4 AVENIDA 5-99 ZONA 1</dte:Direccion>
      //             <dte:CodigoPostal>010020</dte:CodigoPostal>
      //             <dte:Municipio>SANTA LUCIA COTZULMALGUAPA</dte:Municipio>
      //             <dte:Departamento>ESCUINTLA</dte:Departamento>
      //             <dte:Pais>GT</dte:Pais>
      //           </dte:DireccionEmisor>
      //         </dte:Emisor>
      //         <dte:Receptor CorreoReceptor="" IDReceptor="2768220480502" NombreReceptor="MELVIN DANIEL ,SOMA MÉNDEZ" TipoEspecial="CUI">
      //           <dte:DireccionReceptor>
      //             <dte:Direccion>Ciudad</dte:Direccion>
      //             <dte:CodigoPostal>01007</dte:CodigoPostal>
      //             <dte:Municipio>Guatemala</dte:Municipio>
      //             <dte:Departamento>Guatemala</dte:Departamento>
      //             <dte:Pais>GT</dte:Pais>
      //           </dte:DireccionReceptor>
      //         </dte:Receptor>
      //         <dte:Frases>
      //           <dte:Frase CodigoEscenario="1" TipoFrase="1" />
      //         </dte:Frases>
      //         <dte:Items>
      //           <dte:Item NumeroLinea="1" BienOServicio="B">
      //             <dte:Cantidad>1.0000</dte:Cantidad>
      //             <dte:UnidadMedida>UND</dte:UnidadMedida>
      //             <dte:Descripcion>457224|TELEFONO SAMSUNG GALAXY A34 457224RFCWA0SDV8Y     IMEI1: 350350681547282 IMEI2:351525681547288</dte:Descripcion>
      //             <dte:PrecioUnitario>2200.0000</dte:PrecioUnitario>
      //             <dte:Precio>2200.0000</dte:Precio>
      //             <dte:Descuento>0</dte:Descuento>
      //             <dte:Impuestos>
      //               <dte:Impuesto>
      //                 <dte:NombreCorto>IVA</dte:NombreCorto>
      //                 <dte:CodigoUnidadGravable>1</dte:CodigoUnidadGravable>
      //                 <dte:MontoGravable>1964.29</dte:MontoGravable>
      //                 <dte:MontoImpuesto>235.7143</dte:MontoImpuesto>
      //               </dte:Impuesto>
      //             </dte:Impuestos>
      //             <dte:Total>2200.0000</dte:Total>
      //           </dte:Item>
      //         </dte:Items>
      //         <dte:Totales>
      //           <dte:TotalImpuestos>
      //             <dte:TotalImpuesto NombreCorto="IVA" TotalMontoImpuesto="235.7143" />
      //           </dte:TotalImpuestos>
      //           <dte:GranTotal>2200.0000</dte:GranTotal>
      //         </dte:Totales>
      //         <dte:Complementos>
      //           <dte:Complemento IDComplemento="Cambiaria" NombreComplemento="Cambiaria" URIComplemento="http://www.sat.gob.gt/fel/cambiaria.xsd">
      //             <cfc:AbonosFacturaCambiaria xmlns:cfc="http://www.sat.gob.gt/dte/fel/CompCambiaria/0.1.0" Version="1">
      //               <cfc:Abono>
      //                 <cfc:NumeroAbono>1</cfc:NumeroAbono>
      //                 <cfc:FechaVencimiento>2024-03-29</cfc:FechaVencimiento>
      //                 <cfc:MontoAbono>2200.00</cfc:MontoAbono>
      //               </cfc:Abono>
      //             </cfc:AbonosFacturaCambiaria>
      //           </dte:Complemento>
      //         </dte:Complementos>
      //       </dte:DatosEmision>
      //     </dte:DTE>
      //   </dte:SAT>
      // </dte:GTDocumento>""",
    );

    final ApiResModel resCertDoc = await felService.postInfile(
      apiUse,
      paramFel,
      token,
    );

    if (!resCertDoc.succes) return resCertDoc;

    final dynamic doc = resCertDoc.response;

    final PostDocXmlModel paramUpdate = PostDocXmlModel(
      usuario: user,
      documento: doc,
      uuid: uuid,
      documentoCompleto: doc,
    );

    final ApiResModel resUpdateXml = await felService.postXmlUpdate(
      token,
      paramUpdate,
    );

    if (!resUpdateXml.succes) return resUpdateXml;

    final List<DataFelModel> dataFel = resUpdateXml.response;

    if (dataFel.isNotEmpty) {
      final DataFelModel fel = dataFel.first;

      DateTime fechaAnt = fel.fechaHoraCertificacion;

      String strDate =
          "${fechaAnt.day}/${fechaAnt.month}/${fechaAnt.year} "
          "${fechaAnt.hour}:${fechaAnt.minute}:${fechaAnt.second}";

      docGlobal!.docFelSerie = fel.serieDocumento;
      docGlobal!.docFelUUID = fel.numeroAutorizacion;
      docGlobal!.docFelFechaCertificacion = strDate;
      docGlobal!.docFelNumeroDocumento = fel.numeroDocumento;

      final PostDocumentModel estructuraupdate = PostDocumentModel(
        estructura: docGlobal!.toJson(),
        user: user,
        estado: 11,
      );

      final DocumentService documentService = DocumentService();

      final ApiResModel resUpdateEstructura = await documentService
          .updateDocument(estructuraupdate, token, consecutivoDoc);

      if (!resUpdateEstructura.succes) {
        NotificationService.showSnackbar(
          "No se pudo actalizar documento estructura",
        );
      }
    } else {
      NotificationService.showSnackbar("No se obtieron los datos FEL");
    }

    return ApiResModel(
      typeError: 1,
      succes: true,
      response: AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.notificacion, 'docCertificado'),
      storeProcedure: null,
      url: "",
    );
  }

  //Navgar a pantalla de impresion
  Future<void> navigatePrint(BuildContext context) async {
    final DocumentoViewModel docsVm = Provider.of<DocumentoViewModel>(
      context,
      listen: false,
    );

    final DocumentViewModel docVm = Provider.of<DocumentViewModel>(
      context,
      listen: false,
    );

    final FacturaProvider facturaProvider = FacturaProvider();

    final FacturaTMU facturaTMU = FacturaTMU();

    isLoading = true;

    //cragar datos del reporte
    bool loadData = await facturaProvider.loaData(context, consecutivoDoc);

    isLoading = false;
    if (!loadData) return;

    await facturaTMU.getReport(context);

    //TODO: Validar si se regresa a la pantalla de documentos o se queda en la de impresion
    // if (docVm.valueParametro(48)) {
    //   docsVm.backTabs(context);
    // }
  }

  //Volver a certificar
  Future<void> reloadCert(BuildContext context) async {
    //cargar paso en pantalla d carga
    steps[1].isLoading = true;
    steps[1].status = 1;

    notifyListeners();

    //iniciar proceso
    ApiResModel felProcces = await certDTE(context);

    //No se completo el proceso fel
    if (!felProcces.succes) {
      //parar proceso
      steps[1].isLoading = false;
      steps[1].status = 3;

      //verificar tipo de error
      if (felProcces.typeError == 1) {
        //mensaje de error
        error = felProcces.response;
        viewMessage = true;
      } else {
        //si es necesario pantalla de error
        errorView = ErrorModel(
          date: DateTime.now(),
          description: felProcces.response.toString(),
          url: felProcces.url,
          storeProcedure: felProcces.storeProcedure,
        );

        //ver mensaje de error
        viewError = true;
      }

      //ver botones de error
      viewErrorFel = true;

      notifyListeners();

      return;
    }

    //se completo el proceso fel
    //actualizar status del paso
    for (var step in steps) {
      step.isLoading = false;
      step.status = 2;
    }

    stepsSucces++;

    //boton proceso correto
    isLoadingDTE = false;
    showPrint = true;

    if (directPrint) {
      // if (screen == 1) {
      navigatePrint(context);
      // } else {
      // printNetwork(context);
      // }
    }
    notifyListeners();
  }

  //Immprimir sin firma fel
  printWithoutFel(BuildContext context) async {
    //Proveedor de datos externo
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    String user = loginVM.user;
    String token = loginVM.token;

    //finalizar proceso
    isLoadingDTE = false;
    //Mostrar boton para imprimir
    showPrint = true;
    //boton proceso correto

    //TODO:Actaulizar estado

    final PostDocumentModel estructuraupdate = PostDocumentModel(
      estructura: docGlobal!.toJson(),
      user: user,
      estado: 11,
    );

    final DocumentService documentService = DocumentService();

    isLoading = true;

    final ApiResModel resUpdateEstructura = await documentService
        .updateDocument(estructuraupdate, token, consecutivoDoc);

    isLoading = false;

    if (!resUpdateEstructura.succes) {
      NotificationService.showSnackbar(
        "No se pudo actalizar documento estructura",
      );

      return;
    }

    if (directPrint) {
      // if (screen == 1) {
      navigatePrint(context);
      // } else {
      // printNetwork(context);
      // }
    }
  }

  //Ir a la pantalla de error
  navigateError(BuildContext context) {
    Navigator.pushNamed(context, "error", arguments: errorView);
  }

  Future<void> processDocument(BuildContext context) async {
    //iniciar cargas (steps)
    stepsSucces = 0;

    //iniciar cargas
    for (var step in steps) {
      step.isLoading = true;
      step.status = 1;
    }

    //ocultar botones y mensajes
    viewMessage = false;
    viewError = false;
    viewErrorFel = false;
    viewErrorProcess = false;
    viewSucces = false;

    notifyListeners();
    //Iniciar el proceso

    isLoadingDTE = true;

    //Enviar documento a demosoft
    ApiResModel sendProcess = await sendDocument(context);

    //Verificar si el documento se creo
    if (!sendProcess.succes) {
      //No se completo el proceso
      for (var step in steps) {
        step.isLoading = false;
        step.status = 3;
      }

      //verificar tipo de error
      if (sendProcess.typeError == 1) {
        error = sendProcess.response;
        viewMessage = true;
      } else {
        //si es necesario ventana de error
        errorView = ErrorModel(
          date: DateTime.now(),
          description: sendProcess.response,
          url: sendProcess.url,
          storeProcedure: sendProcess.storeProcedure,
        );

        viewError = true;
      }

      //ver botones de error
      viewErrorProcess = true;
      notifyListeners();

      return;
    }

    //Si todo salio bien
    //verificar si hay mas pasos o no
    steps[0].isLoading = false;
    steps[0].status = 2;
    stepsSucces++;

    notifyListeners();

    consecutivoDoc = sendProcess.response["data"];

    //Certificar documento, certificador (SAT)
    ApiResModel felProcces = await certDTE(context);

    if (!felProcces.succes) {
      //No se completo el proceso fel
      steps[1].isLoading = false;
      steps[1].status = 3;

      //tipo de error
      if (felProcces.typeError == 1) {
        error = felProcces.response;
        viewMessage = true;
      } else {
        //ir a pantalla de error
        errorView = ErrorModel(
          date: DateTime.now(),
          description: felProcces.response.toString(),
          url: felProcces.url,
          storeProcedure: felProcces.storeProcedure,
        );

        viewError = true;
      }

      viewErrorFel = true;

      notifyListeners();

      return;
    }

    //si todo esta coorecto
    for (var step in steps) {
      step.isLoading = false;
      step.status = 2;
    }
    stepsSucces++;

    //boton proceso correto
    isLoadingDTE = false;
    showPrint = true;

    if (directPrint) {
      // if (screen == 1) {
      navigatePrint(context);
      // } else {
      // printNetwork(context);
      // }
    }
    notifyListeners();
  }

  /**FIN FEL  */

  //agregar forma de pago
  void addAmount(AmountModel amount, BuildContext context) {
    amounts.add(amount); //agregar a lista
    calculateTotales(context); //calcular totales
  }

  //Calcular totales
  void calculateTotales(BuildContext context) {
    //Borré la funcion que guarda el documento

    //View models externos
    final vmAmount = Provider.of<AmountConvertViewModel>(
      context,
      listen: false,
    );

    //Reicniciar valores
    saldo = 0;
    cambio = 0;
    pagado = 0;

    //Recorrer formas de pago agregadas
    for (var element in amounts) {
      double monto = element.amount;
      pagado += monto; //sumar totales
    }

    //Recorrer formas de pago agregadas
    for (var element in amounts) {
      double diference = element.diference;
      pagado += diference; //sumar totales
    }

    //Calcular cambio y saldo pendiente de pagar
    if (pagado > total) {
      cambio = pagado - total;
    } else {
      saldo = total - pagado;
    }

    //Agregar valores a los inputs
    vmAmount.montoController.text = saldo.toStringAsFixed(2);
    vmAmount.formValues["monto"] = saldo.toStringAsFixed(2);

    saldo = double.parse(saldo.toStringAsFixed(2));
    cambio = double.parse(cambio.toStringAsFixed(2));
    pagado = double.parse(pagado.toStringAsFixed(2));

    notifyListeners();
  }
}
