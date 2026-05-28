// ignore_for_file: use_build_context_synchronously

import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/destination_doc_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/origin_doc_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/amount_convert_view_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/convert_doc_view_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/views/views.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/services/services.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
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

  //enviar el odcumento
  Future<ApiResModel> sendDocument(BuildContext context) async {
    //view models ecternos

    // final LocationService vmLocation = Provider.of<LocationService>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final docVM = Provider.of<DocumentViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final elVM = Provider.of<ElementoAsigandoViewModel>(
    //   scaffoldKey.currentContext!,
    //   listen: false,
    // );

    // final menuVM = Provider.of<MenuViewModel>(
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

    final ConvertDocViewModel convertDocVM = Provider.of<ConvertDocViewModel>(
      context,
      listen: false,
    );

    //usuario token y cadena de conexion
    String user = loginVM.user;
    String token = loginVM.token;

    //valores necesarios para el docuemento
    int? cuentaVendedor = destino.docVM.cuentasCorrentistasRef.isEmpty
        ? null
        : docVM.vendedorSelect!.cuentaCorrentista;
    int cuentaCorrentisata = docVM.clienteSelect!.cuentaCorrentista;
    String cuentaCta = docVM.clienteSelect!.cuentaCta;
    int tipoDocumento = menuVM.documento!;
    String serieDocumento = docVM.serieSelect!.serieDocumento!;
    int empresa = localVM.selectedEmpresa!.empresa;
    int estacion = localVM.selectedEstacion!.estacionTrabajo;
    List<AmountModel> amounts = paymentVM.amounts;
    List<TraInternaModel> products = detailsVM.traInternas;

    final ProductService productService = ProductService();

    //validar transaccionnes
    for (var item in products) {
      //consumo del api
      ApiResModel resDisponibiladProducto = await productService
          .getValidaProducto(
            user,
            docVM.serieSelect!.serieDocumento!,
            menuVM.documento!,
            localVM.selectedEstacion!.estacionTrabajo,
            localVM.selectedEmpresa!.empresa,
            item.bodega!.bodega,

            item.tipoTransaccion!,
            item.producto.unidadMedida,
            item.producto.producto,
            item.cantidad,
            menuVM.tipoCambio.toInt(),
            item.precio!.moneda,
            item.precio!.id,
            token,
            docVM.clienteSelect!.cuentaCorrentista,
            docVM.clienteSelect!.cuentaCta,
            docVM.fechaInicial,
            docVM.fechaFinal,
            item.cantidad * item.precio!.precioU,
            item.total,
          );

      if (!resDisponibiladProducto.succes) {
        isLoading = false;

        //si algo salio mal mostrar alerta
        await NotificationService.showErrorView(
          scaffoldKey.currentContext!,
          resDisponibiladProducto,
        );

        return ApiResModel(
          typeError: 1,
          succes: false,
          response: AppLocalizations.of(
            scaffoldKey.currentContext!,
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
          sku: item.producto.productoId,
          productoDesc: item.producto.desProducto,
          bodega: "${item.bodega!.nombre} (${item.bodega!.bodega})",
          tipoDoc: "${menuVM.name} (${menuVM.documento!})",
          serie:
              "${docVM.serieSelect!.descripcion!} (${docVM.serieSelect!.serieDocumento!})",
          mensajes: mensajes,
        );

        //insertar registros
        validaciones.add(validacion);

        //aqui abre un dialogo con notificacion
        await NotificationService.showMessageValidations(
          scaffoldKey.currentContext!,
          validaciones,
        );

        return ApiResModel(
          typeError: 1,
          succes: false,
          response: AppLocalizations.of(
            scaffoldKey.currentContext!,
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
              traTipoTransaccion: transaction.tipoTransaccion!,
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
              traTipoTransaccion: transaction.tipoTransaccion!,
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
          traTipoTransaccion: transaction.tipoTransaccion!,
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
      docLatitud: vmLocation.latitutd,
      docLongitud: vmLocation.longitud,
      consecutivoInterno: firstPart,
      docTraMonto: detailsVM.total,
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
      docObservacion1: observacion.text,
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
    ApiResModel res = await documentService.postDocument(document, token);

    return res;
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
    ApiResModel sendProcess = await sendDocument();

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
      navigatePrint();
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
