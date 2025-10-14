// ignore_for_file: use_build_context_synchronously

import 'package:fl_business/displays/prc_documento_3/view_models/document_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:fl_business/displays/report/reports/factura/tmu.dart';
import 'package:flutter/material.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/documento_resumen_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/services/services.dart';
import 'package:fl_business/displays/report/reports/factura/pdf.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/shr_local_config/models/models.dart';
import 'package:fl_business/displays/shr_local_config/services/empresa_service.dart';
import 'package:fl_business/displays/shr_local_config/services/estacion_service.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/fel/models/models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecentViewModel extends ChangeNotifier {
  //cinsecutivo para obtener plantilla (impresion)
  int optionPrint = 0;
  int consecutivo = 0;
  DocEstructuraModel? docGlobal;

  //control del proceso
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //controlar proceso fel
  bool _isLoadingDTE = false;
  bool get isLoadingDTE => _isLoadingDTE;

  set isLoadingDTE(bool value) {
    _isLoadingDTE = value;
    notifyListeners();
  }

  //1. Cargando 2. Exitoso 3. Error
  //TODO:Pendiente de traducir por la lista
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
  //eror model para informe
  ErrorModel? errorView;

  //Lista de documentos recentes
  final List<DocumentoResumenModel> documents = [];

  //Mostrar boton para imprimir
  bool _showPrint = false;
  bool get showPrint => _showPrint;

  set showPrint(bool value) {
    _showPrint = value;
    notifyListeners();
  }

  //Ir a la pantalla de error
  navigateError(BuildContext context) {
    Navigator.pushNamed(context, "error", arguments: errorView);
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
    bool loadData = await facturaProvider.loaData(context, consecutivo);

    isLoading = false;
    if (!loadData) return;

    await facturaTMU.getReport(context);

    if (docVm.valueParametro(48)) {
      docsVm.backTabs(context);
    }
  }

  //Navgar a pantalla de impresion
  share(BuildContext context) async {
    final FacturaProvider facturaProvider = FacturaProvider();

    isLoading = true;

    final bool loadData = await facturaProvider.loaData(context, consecutivo);

    if (!loadData) {
      isLoading = false;

      return;
    }

    final FacturaPDF facturaPDF = FacturaPDF();

    await facturaPDF.getReport(context);

    isLoading = false;
  }

  //Navegar a vista detalles
  Future<void> navigateView(
    BuildContext context,
    DocumentoResumenModel doc,
  ) async {
    //Proveedor de datos externo
    final vmLogin = Provider.of<LoginViewModel>(context, listen: false);

    //usuario y token
    String token = vmLogin.token;
    String user = doc.estructura.docUserName;
    int empresaId = doc.estructura.docEmpresa;
    int estacionid = doc.estructura.docEstacionTrabajo;
    int documento = doc.estructura.docTipoDocumento;
    String serieDoc = doc.estructura.docSerieDocumento;
    int cuentaCorrentista = doc.estructura.docCuentaCorrentista;
    int cuentaCorrentistaRef = doc.estructura.docCuentaVendedor ?? 0;

    EmpresaModel? empresa;
    EstacionModel? estacion;
    String documentoDesc = "";
    String serieDesc = "";
    ClientModel? client;
    String seller = "";

    isLoading = true;

    final EmpresaService empresaService = EmpresaService();

    final ApiResModel resEmpresa = await empresaService.getEmpresa(user, token);

    //Si el api para  falló
    if (!resEmpresa.succes) {
      isLoading = false;

      await NotificationService.showErrorView(context, resEmpresa);
      return;
    }

    final List<EmpresaModel> empresas = resEmpresa.response;

    for (var i = 0; i < empresas.length; i++) {
      final EmpresaModel item = empresas[i];

      if (item.empresa == empresaId) {
        empresa = item;
        break;
      }
    }

    final EstacionService estacionService = EstacionService();

    final ApiResModel resEstacion = await estacionService.getEstacion(
      user,
      token,
    );

    //Si el api para  falló
    if (!resEstacion.succes) {
      isLoading = false;

      await NotificationService.showErrorView(context, resEstacion);
      return;
    }

    final List<EstacionModel> estaciones = resEstacion.response;

    for (var i = 0; i < estaciones.length; i++) {
      final EstacionModel item = estaciones[i];

      if (item.estacionTrabajo == estacionid) {
        estacion = item;
        break;
      }
    }

    final SerieService serieService = SerieService();

    final ApiResModel resSerie = await serieService.getSerie(
      documento,
      empresaId,
      estacionid,
      user,
      token,
    );

    //Si el api para  falló
    if (!resSerie.succes) {
      isLoading = false;

      await NotificationService.showErrorView(context, resSerie);
      return;
    }

    final List<SerieModel> series = resSerie.response;

    for (var i = 0; i < series.length; i++) {
      final SerieModel item = series[i];

      if (item.serieDocumento == serieDoc) {
        serieDesc = "${item.descripcion} ($serieDoc)";
        documentoDesc = "${item.desTipoDocumento} ($documento)";
        break;
      }
    }

    final CuentaService cuentaService = CuentaService();

    final ApiResModel resNameClient = await cuentaService.getNombreCuenta(
      token,
      cuentaCorrentista,
    );

    //Si el api para  falló
    if (!resNameClient.succes) {
      isLoading = false;

      await NotificationService.showErrorView(context, resNameClient);
      return;
    }

    final RespLogin nameClient = resNameClient.response;

    final MenuViewModel menuVM = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

    if (nameClient.data != null) {
      final ApiResModel resCuentaClient = await cuentaService
          .getCuentaCorrentista(
            empresaId,
            nameClient.data,
            user,
            token,
            menuVM.app,
          );

      //Si el api para  falló
      if (!resCuentaClient.succes) {
        isLoading = false;

        await NotificationService.showErrorView(context, resCuentaClient);
        return;
      }

      final List<ClientModel> cuentas = resCuentaClient.response;

      for (var i = 0; i < cuentas.length; i++) {
        final ClientModel item = cuentas[i];

        if (item.cuentaCorrentista == cuentaCorrentista) {
          client = item;
          break;
        }
      }
    }

    final ApiResModel resVendedor = await cuentaService.getCeuntaCorrentistaRef(
      user,
      documento,
      serieDoc,
      empresaId,
      token,
    );

    //Si el api para  falló
    if (!resVendedor.succes) {
      isLoading = false;

      await NotificationService.showErrorView(context, resVendedor);
      return;
    }

    final List<SellerModel> vendedores = resVendedor.response;

    for (var i = 0; i < vendedores.length; i++) {
      final SellerModel item = vendedores[i];

      if (item.cuentaCorrentista == cuentaCorrentistaRef) {
        seller = item.nomCuentaCorrentista;
        break;
      }
    }

    final List<TransactionDetail> transacciones = [];

    final ProductService productService = ProductService();

    for (var tra in doc.estructura.docTransaccion) {
      final ApiResModel resSku = await productService.getSku(
        token,
        tra.traProducto,
        tra.traUnidadMedida,
      );

      //Si el api para  falló
      if (!resSku.succes) {
        isLoading = false;

        await NotificationService.showErrorView(context, resSku);
        return;
      }

      final RespLogin sku = resSku.response;

      final ApiResModel resProduct = await productService.getProduct(
        sku.data,
        token,
        user,
        estacionid,
        0,
        100,
      );

      //Si el api para  falló
      if (!resProduct.succes) {
        isLoading = false;

        await NotificationService.showErrorView(context, resProduct);
        return;
      }

      final List<ProductModel> products = resProduct.response;

      for (var i = 0; i < products.length; i++) {
        final ProductModel item = products[i];

        if (item.producto == tra.traProducto) {
          transacciones.add(
            TransactionDetail(
              product: item,
              cantidad: tra.traCantidad,
              total: tra.traMonto,
            ),
          );
          break;
        }
      }
    }

    final PagoService pagoService = PagoService();

    final ApiResModel resPagos = await pagoService.getFormas(
      documento,
      serieDoc,
      empresaId,
      token,
    );

    //Si el api para  falló
    if (!resPagos.succes) {
      isLoading = false;

      showError(context, resPagos);

      return;
    }

    final List<PaymentModel> pagos = resPagos.response;

    final List<AmountModel> montos = [];

    for (var pago in doc.estructura.docCargoAbono) {
      BankModel? banco;
      AccountModel? ceuntaBanco;

      if (pago.banco != null) {
        final ApiResModel resBancos = await pagoService.getBancos(
          user,
          empresaId,
          token,
        );

        //Si el api para  falló
        if (!resBancos.succes) {
          isLoading = false;

          showError(context, resBancos);

          return;
        }

        final List<BankModel> bancos = resBancos.response;

        for (var i = 0; i < bancos.length; i++) {
          final BankModel item = bancos[i];

          if (item.banco == pago.banco) {
            banco = item;
            break;
          }
        }

        if (banco != null && pago.cuentaBancaria != null) {
          final ApiResModel resCuentaBanco = await pagoService.getCuentas(
            user,
            empresaId,
            banco.banco,
            token,
          );

          //Si el api para  falló
          if (!resCuentaBanco.succes) {
            isLoading = false;

            showError(context, resCuentaBanco);

            return;
          }

          List<AccountModel> cuentasBanco = resCuentaBanco.response;

          for (var i = 0; i < cuentasBanco.length; i++) {
            final AccountModel item = cuentasBanco[i];

            if (item.banco == pago.banco) {
              ceuntaBanco = item;
              break;
            }
          }
        }
      }

      for (var i = 0; i < pagos.length; i++) {
        final PaymentModel item = pagos[i];

        if (item.tipoCargoAbono == pago.tipoCargoAbono) {
          montos.add(
            AmountModel(
              checked: false,
              amount: pago.monto,
              diference: pago.cambio,
              authorization: pago.autorizacion,
              reference: pago.referencia,
              payment: item,
              account: ceuntaBanco,
              bank: banco,
            ),
          );

          break;
        }
      }
    }

    final DetailDocModel detallesDoc = DetailDocModel(
      idRef: doc.estructura.docIdDocumentoRef,
      fecha: strDate(doc.item.fechaHora),
      consecutivo: doc.item.consecutivoInterno,
      empresa: empresa!,
      estacion: estacion!,
      client: client,
      seller: seller,
      transactions: transacciones,
      payments: montos,
      cargo: doc.cargo,
      descuento: doc.descuento,
      observacion: doc.estructura.docObservacion1,
      subtotal: doc.subtotal,
      total: doc.total,
      documento: documento,
      serie: serieDoc,
      documentoDesc: documentoDesc,
      serieDesc: serieDesc,
      docRefTipoReferencia: doc.estructura.docRefTipoReferencia,
      docFechaIni: doc.estructura.docFechaIni,
      docFechaFin: doc.estructura.docFechaFin,
      docRefFechaIni: doc.estructura.docRefFechaIni,
      docRefFechaFin: doc.estructura.docRefFechaFin,
      docRefDescripcion: doc.estructura.docRefDescripcion,
      docRefObservacion: doc.estructura.docRefObservacion,
      docRefObservacion2: doc.estructura.docRefObservacion2,
      docRefObservacion3: doc.estructura.docRefObservacion3,
    );

    Navigator.pushNamed(context, AppRoutes.detailsDoc, arguments: detallesDoc);

    //finalizar proceso
    isLoading = false;
  }

  showError(BuildContext context, ApiResModel res) async {
    //Si el api para  falló

    await NotificationService.showErrorView(context, res);
  }

  //fehca str a Date formmat dd/MM/yyyy hh:mm
  String strDate(String dateStr) {
    // Convierte la cadena a un objeto DateTime
    DateTime dateTime = DateTime.parse(dateStr);

    // Formatea la fecha en el formato dd/MM/yyyy
    String formattedDate = DateFormat('dd/MM/yyyy hh:mm').format(dateTime);

    return formattedDate;
  }

  //buscar documentos recientes
  Future<void> loadDocs(BuildContext context) async {
    //Proveedor de datos externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    //usuario y token
    String user = loginVM.user;
    String token = loginVM.token;

    //servicio documentos
    DocumentService documentService = DocumentService();

    //elinar documentos existentes
    documents.clear();

    //inciar proceso
    isLoading = true;

    //consummo api buscar documentos recienets
    final ApiResModel res = await documentService.getDocument(0, user, token);

    //Si el api falló
    if (!res.succes) {
      //finalizar procesp
      isLoading = false;
      //mostrar dialogo de confirmacion

      await NotificationService.showErrorView(context, res);
      return;
    }

    final List<GetDocModel> docs = res.response;

    for (var doc in docs) {
      final DocEstructuraModel estructura = DocEstructuraModel.fromJson(
        doc.estructura,
      );

      double subtotal = 0;
      double cargo = 0;
      double descuento = 0;
      double total = 0;

      for (var tra in estructura.docTransaccion) {
        if (tra.traCantidad == 0 && tra.traMonto > 0) {
          cargo += tra.traMonto;
        } else if (tra.traCantidad == 0 && tra.traMonto < 0) {
          descuento += tra.traMonto;
        } else {
          subtotal += tra.traMonto;
        }
      }

      total = (subtotal + cargo) + descuento;

      documents.add(
        DocumentoResumenModel(
          consecutivo: doc.consecutivoInterno,
          item: doc,
          estructura: estructura,
          subtotal: subtotal,
          cargo: cargo,
          descuento: descuento,
          total: total,
        ),
      );
    }

    //finalizar procesp
    isLoading = false;
  }

  Future<void> reprintDoc(
    BuildContext context,
    int option, //1: tmu; 2: pdf
    DocumentoResumenModel doc,
  ) async {
    optionPrint = option;
    consecutivo = doc.consecutivo;
    docGlobal = doc.estructura;

    // if (doc.item.estado == 11) {
    if (doc.item.estado == 1) {
      await reloadCert(context);
      return;
    }

    //imprimir
    printOrShaherDoc(context);
  }

  //
  printOrShaherDoc(BuildContext context) {
    switch (optionPrint) {
      case 1:
        navigatePrint(context);
        break;
      case 2:
        share(context);
        break;
      default:
    }
  }

  //Volver a certificar
  Future<void> reloadCert(BuildContext context) async {
    stepsSucces = 0;
    notifyListeners();

    isLoadingDTE = true;
    //primer paso terminado
    steps[0].isLoading = false;
    steps[0].status = 2;
    stepsSucces++;

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

        notifyListeners();
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
        notifyListeners();
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

    notifyListeners();

    printOrShaherDoc(context);
  }

  //certificar DTE (Servicios del certificador)
  Future<ApiResModel> certDTE(BuildContext context) async {
    //Proveedor de datos externo
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);

    //usuario token y cadena de conexion
    int empresa = localVM.selectedEmpresa!.empresa;
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
      consecutivo,
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
          .updateDocument(estructuraupdate, token, consecutivo);

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
}
