// ignore_for_file: use_build_context_synchronously, library_prefixes
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/models.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/services/reception_service.dart';
import 'package:fl_business/displays/report/models/models.dart';
import 'package:fl_business/displays/report/reports/tmu/existencias_tmu.dart';
import 'package:fl_business/displays/report/reports/tmu/fact_t_contado_cred_tmu.dart';
import 'package:fl_business/displays/report/view_models/report_view_model.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';

class PrintViewModel extends ChangeNotifier {
  //manejar flujo del procesp
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //impresion de pprueba
  Future<PrintModel> printReceiveTest(
    BuildContext context,
    int paperDefault,
  ) async {
    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    List<int> bytes = [];

    final generator = Generator(
      AppData.paperSize[paperDefault],
      await CapabilityProfile.load(),
    );

    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(
      AppLocalizations.of(context)!.translate(BlockTranslate.tiket, "generico"),
      styles: PosStyles(
        align: AppData.posAlign["center"],
        width: AppData.posTextSize[2],
        height: AppData.posTextSize[2],
      ),
    );

    bytes += generator.text(
      "CENTER",
      styles: PosStyles(
        align: AppData.posAlign["center"],
        width: AppData.posTextSize[1],
        height: AppData.posTextSize[1],
      ),
    );

    bytes += generator.text(
      "LEFT",
      styles: PosStyles(align: AppData.posAlign["left"]),
    );

    bytes += generator.text(
      "RIGHT",
      styles: PosStyles(align: AppData.posAlign["right"]),
    );

    bytes += generator.text(
      "normal",
      styles: PosStyles(bold: AppData.boolText["normal"]),
    );

    bytes += generator.text(
      "Bool",
      styles: PosStyles(bold: AppData.boolText["bool"]),
    );

    bytes += generator.text(
      "Usuario: ${loginVM.user}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Version: ${SplashViewModel.versionLocal}",
      styles: PosStyles(align: AppData.posAlign["center"]),
    );

    return PrintModel(bytes: bytes, generator: generator);
  }

  //Reporte de facturas
  Future getReportFactCredContado(
    BuildContext context,
    int paperDefault,
  ) async {
    final ReportViewModel reportVM = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );

    return FactTContadoCredTMU.getReport(
      context,
      paperDefault,
      reportVM.reportFactContCredModel!,
    );
  }

  //Reporte de unidades vendidas
  Future printReporUnidadesVendidas(
    BuildContext context,
    int paperDefault,
  ) async {
    final ReportViewModel reportVM = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );

    return UnidadesVendidasTMU.getReport(
      context,
      paperDefault,
      reportVM.reportUnidadesVendidasModel!,
    );
  }

  //Reporte de existencias
  Future printReporStokc(BuildContext context, int paperDefault) async {
    final ReportViewModel reportVM = Provider.of<ReportViewModel>(
      context,
      listen: false,
    );

    return ExistenciasTMU.getReport(
      context,
      paperDefault,
      reportVM.reportStockModel!,
    );
  }

  //formato TMU documento conversion
  Future printDocConversion(
    BuildContext context,
    int paperDefault,
    DocDestinationModel document,
  ) async {
    //datos externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final String token = loginVM.token;
    final String user = loginVM.user;

    //Buscar datos paar imprimir
    final ReceptionService receptionService = ReceptionService();

    isLoading = true;

    final ApiResModel res = await receptionService.getDataPrint(
      token, //token,
      user, //user,
      document.data.documento, //documento,
      document.data.tipoDocumento, //tipoDocumento,
      document.data.serieDocumento, //serieDocumento,
      document.data.empresa, //empresa,
      document.data.localizacion, //localizacion,
      document.data.estacion, //estacion,
      document.data.fechaReg, //fechaReg,
    );

    isLoading = false;

    //si el consumo salió mal
    if (!res.succes) {
      NotificationService.showErrorView(context, res);

      return;
    }

    final List<PrintConvertModel> data = res.response;

    if (data.isEmpty) {
      res.response = AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.notificacion, "sinDatos");
      NotificationService.showErrorView(context, res);

      return;
    }

    final vmHome = Provider.of<HomeViewModel>(context, listen: false);

    // Crear una instancia de NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(
      symbol: vmHome
          .moneda, // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
      decimalDigits: 2, // Número de decimales a mostrar
    );

    final PrintConvertModel encabezado = data.first;

    Empresa empresa = Empresa(
      razonSocial: encabezado.razonSocial ?? "",
      nombre: encabezado.empresaNombre ?? "",
      direccion: encabezado.empresaDireccion ?? "",
      nit: encabezado.empresaNit ?? "",
      tel: encabezado.empresaTelefono ?? "",
    );

    //TODO: Certificar
    Documento documento = Documento(
      consecutivoInterno: 0,
      titulo: encabezado.tipoDocumento!,
      descripcion: AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.tiket, "generico"),
      fechaCert: "",
      serie: "",
      no: "",
      autorizacion: "",
      noInterno: encabezado.refIdDocumento ?? "",
      serieInterna: encabezado.serieDocumento ?? "",
    );

    DateTime now = DateTime.now();

    // Formatear la fecha como una cadena
    String formattedDate =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";

    Cliente cliente = Cliente(
      nombre: encabezado.documentoNombre ?? "",
      direccion: encabezado.documentoDireccion ?? "",
      nit: encabezado.documentoNit ?? "",
      fecha: formattedDate,
      tel: encabezado.documentoTelefono ?? "",
      email: "", //Cambiar aqui,
    );

    List<Item> items = [];

    for (var detail in data) {
      items.add(
        Item(
          descripcion: detail.desProducto ?? "",
          cantidad: detail.cantidad ?? 0,
          unitario: detail.montoUMTipoMoneda ?? "",
          total: detail.montoTotalTipoMoneda ?? "",
          sku: detail.productoId ?? "",
          precioDia: detail.montoTotalTipoMoneda ?? "",
          um: detail.simbolo ?? "",
        ),
      );
    }

    Montos montos = Montos(
      subtotal: encabezado.subTotal ?? 0,
      cargos: 0,
      descuentos: encabezado.descuento ?? 0,
      total: (encabezado.subTotal ?? 0) + (encabezado.descuento ?? 0),
      totalLetras: encabezado.montoLetras!.toUpperCase(),
    );

    String vendedor = encabezado.atendio ?? "";

    List<String> mensajes = [
      //TODO: Mostrar frase
      // "**Sujeto a pagos trimestrales**",
      AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.tiket, "sinCambios"),
    ];

    PoweredBy poweredBy = PoweredBy(
      nombre: "Desarrollo Moderno de Software S.A.",
      website: "www.demosoft.com.gt",
    );

    DocPrintModel docPrintModel = DocPrintModel(
      empresa: empresa,
      documento: documento,
      cliente: cliente,
      items: items,
      montos: montos,
      pagos: [],
      vendedor: vendedor,
      certificador: Certificador(nombre: "", nit: ""),
      observacion: encabezado.observacion1 ?? "",
      mensajes: mensajes,
      poweredBy: poweredBy,
      noDoc: encabezado.refIdDocumento ?? "",
      usuario: user,
      procedimientoAlmacenado: res.storeProcedure ?? "",
    );

    List<int> bytes = [];

    final generator = Generator(
      AppData.paperSize[paperDefault],
      await CapabilityProfile.load(),
    );

    PosStyles center = const PosStyles(align: PosAlign.center);
    PosStyles centerBold = const PosStyles(align: PosAlign.center, bold: true);

    bytes += generator.setGlobalCodeTable('CP1252');

    bytes += generator.text(docPrintModel.empresa.razonSocial, styles: center);
    bytes += generator.text(docPrintModel.empresa.nombre, styles: center);

    bytes += generator.text(docPrintModel.empresa.direccion, styles: center);

    bytes += generator.text(
      "NIT: ${docPrintModel.empresa.nit}",
      styles: center,
    );

    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, "noVinculada")} ${docPrintModel.empresa.tel}",
      styles: center,
    );

    bytes += generator.emptyLines(1);

    bytes += generator.text(docPrintModel.documento.titulo, styles: centerBold);

    bytes += generator.text(
      docPrintModel.documento.descripcion,
      styles: centerBold,
    );

    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'interno')} ${docPrintModel.documento.noInterno}",
      styles: center,
    );
    bytes += generator.emptyLines(1);
    bytes += generator.text(
      AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'cliente'),
      styles: center,
    );

    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'nombre')} ${docPrintModel.cliente.nombre}",
      styles: center,
    );
    bytes += generator.text(
      "NIT: ${docPrintModel.cliente.nit}",
      styles: center,
    );
    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'direccion')} ${docPrintModel.cliente.direccion}",
      styles: center,
    );
    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'tel')}: ${docPrintModel.cliente.tel}",
      styles: center,
    );
    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, 'fecha')}: ${docPrintModel.cliente.fecha}",
      styles: center,
    );

    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(text: "Pre Repo.", width: 2),
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'cantidad'),
        width: 2,
      ), // Ancho 2
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.general, 'descripcion'),
        width: 4,
      ), // Ancho 6
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'precioU'),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ), // Ancho 4
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'monto'),
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ), // Ancho 4
    ]);

    for (var transaction in docPrintModel.items) {
      bytes += generator.row([
        PosColumn(text: "${transaction.cantidad}", width: 2), // Ancho 2
        PosColumn(text: transaction.descripcion, width: 4), // Ancho 6
        PosColumn(
          text: transaction.unitario,
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ), // Ancho 4
        PosColumn(
          text: transaction.total,
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ), // Ancho 4
      ]);
    }

    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'subTotal'),
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currencyFormat.format(docPrintModel.montos.subtotal),
        styles: const PosStyles(align: PosAlign.right),
        width: 6,
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'cargos'),
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currencyFormat.format(docPrintModel.montos.cargos),
        styles: const PosStyles(align: PosAlign.right),
        width: 6,
      ),
    ]);

    bytes += generator.row([
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'descuentos'),
        width: 6,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: currencyFormat.format(docPrintModel.montos.descuentos),
        styles: const PosStyles(align: PosAlign.right),
        width: 6,
      ),
    ]);

    bytes += generator.emptyLines(1);

    bytes += generator.row([
      PosColumn(
        text: AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'totalT'),
        styles: const PosStyles(bold: true, width: PosTextSize.size2),
        width: 6,
        containsChinese: false,
      ),
      PosColumn(
        text: currencyFormat.format(docPrintModel.montos.total),
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
          width: PosTextSize.size2,
          underline: true,
        ),
        width: 6,
      ),
    ]);

    bytes += generator.text(
      docPrintModel.montos.totalLetras,
      styles: centerBold,
    );

    bytes += generator.emptyLines(1);

    //Si la lista de vendedores no está vacia imprimir
    bytes += generator.text(
      "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'vendedor')} ${docPrintModel.vendedor}",
      styles: center,
    );
    //Si la lista de vendedores no está vacia imprimir
    bytes += generator.text(
      "Observacion:", //TODO:Translate
      styles: center,
    ); //Si la lista de vendedores no está vacia imprimir
    bytes += generator.text(encabezado.observacion1 ?? "", styles: center);

    bytes += generator.emptyLines(1);

    for (var mensaje in docPrintModel.mensajes) {
      bytes += generator.text(mensaje, styles: centerBold);
    }

    bytes += generator.emptyLines(1);
    bytes += generator.text(
      "Usuario: ${loginVM.user}",
      styles: UtilitiesTMU.center,
    );
    bytes += generator.emptyLines(1);

    bytes += generator.text("--------------------", styles: center);

    bytes += generator.text("Powered by", styles: center);
    bytes += generator.text(docPrintModel.poweredBy.nombre, styles: center);
    bytes += generator.text(docPrintModel.poweredBy.website, styles: center);

    bytes += generator.text(
      "Version: ${SplashViewModel.versionLocal}",
      styles: center,
    );
    return PrintModel(bytes: bytes, generator: generator);
  }
}
