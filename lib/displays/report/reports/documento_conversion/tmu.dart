import 'package:fl_business/displays/report/reports/documento_conversion/provider.dart';
import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';
import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/models/print_model.dart';
import 'package:fl_business/providers/logo_provider.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/home_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DocumentoConversionTMU {
  PrintModel? report;

  Future<void> getReport(BuildContext context) async {
    try {
      final PrinterViewModel printerVM = Provider.of<PrinterViewModel>(
        context,
        listen: false,
      );

      final HomeViewModel vmHome = Provider.of<HomeViewModel>(
        context,
        listen: false,
      );

      // Crear una instancia de NumberFormat para el formato de moneda
      final currencyFormat = NumberFormat.currency(
        symbol: vmHome
            .moneda, // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
        decimalDigits: 2, // Número de decimales a mostrar
      );

      final TmuUtils utils = TmuUtils();

      final data = DocumentoConversionProvider.data!;

      List<int> bytes = [];
      final generator = Generator(
        AppData.paperSize[Preferences.paperSize],
        await CapabilityProfile.load(),
      );

      PosStyles center = const PosStyles(align: PosAlign.center);
      PosStyles centerBold = const PosStyles(
        align: PosAlign.center,
        bold: true,
      );

      bytes += generator.setGlobalCodeTable('CP1252');

      if (Provider.of<LogoProvider>(context, listen: false).logo != null) {
        final enterpriseLogo = await utils.getEnterpriseLogo(context);

        bytes += generator.image(enterpriseLogo, align: PosAlign.center);
      }

      bytes += generator.text(data.empresa.razonSocial, styles: center);
      bytes += generator.text(data.empresa.nombre, styles: center);

      bytes += generator.text(data.empresa.direccion, styles: center);

      bytes += generator.text("NIT: ${data.empresa.nit}", styles: center);

      bytes += generator.text("TEL: ${data.empresa.tel}", styles: center);

      bytes += generator.emptyLines(1);

      bytes += generator.text(data.documento.titulo, styles: centerBold);

      bytes += generator.text(data.documento.descripcion, styles: centerBold);

      bytes += generator.emptyLines(1);

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'interno')} ${data.documento.noInterno}",
        styles: center,
      );
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'serie')} ${data.documento.serieInterna}",
        styles: center,
      );

      bytes += generator.emptyLines(1);
      bytes += generator.text(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'cliente'),
        styles: center,
      );

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'nombre')} ${data.cliente.nombre}",
        styles: center,
      );
      bytes += generator.text("NIT: ${data.cliente.nit}", styles: center);
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'direccion')} ${data.cliente.direccion}",
        styles: center,
      );
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'tel')}: ${data.cliente.tel}",
        styles: center,
      );
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, 'fecha')}: ${data.cliente.fecha}",
        styles: center,
      );

      bytes += generator.hr();

      for (var transaction in data.items) {
        bytes += generator.text("Cant. ${transaction.cantidad}");
        bytes += generator.text("Desc.: ${transaction.descripcion}");
        bytes += generator.text("Precio U.: ${transaction.unitario}");
        bytes += generator.text("Total: ${transaction.total}");
      }

      bytes += generator.hr();

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'subTotal')}: ${currencyFormat.format(data.montos.subtotal)}",
      );

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'cargos')}: ${currencyFormat.format(data.montos.cargos)} ",
      );

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'descuentos')}: ${currencyFormat.format(data.montos.descuentos)}",
      );

      bytes += generator.hr();

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'totalT')}: ${currencyFormat.format(data.montos.total)}",
      );

      bytes += generator.text(data.montos.totalLetras, styles: centerBold);

      bytes += generator.emptyLines(1);

      //Si la lista de vendedores no está vacia imprimir
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'vendedor')} ${data.vendedor}",
        styles: center,
      );
      //Si la lista de vendedores no está vacia imprimir
      bytes += generator.text(
        "Observacion:", //TODO:Translate
        styles: center,
      ); //Si la lista de vendedores no está vacia imprimir
      bytes += generator.text(data.observacion, styles: center);

      bytes += generator.emptyLines(1);

      for (var mensaje in data.mensajes) {
        bytes += generator.text(mensaje, styles: centerBold);
      }

      if (data.observacion != "") {
        bytes += generator.hr(); // Línea horizontal

        bytes += generator.text(
          "Observacion:", //TODO:Translate
          styles: center,
        );

        bytes += generator.text(data.observacion, styles: center);
      }

      bytes += generator.text(
        "Usuario: ${data.usuario}",
        styles: UtilitiesTMU.center,
      );

      bytes += generator.hr(); // Línea horizontal

      bytes += generator.text("Powered by", styles: center);
      bytes += generator.text(data.poweredBy.nombre, styles: center);
      bytes += generator.text(data.poweredBy.website, styles: center);

      bytes += generator.text(
        "Version: ${SplashViewModel.versionLocal}",
        styles: center,
      );

      bytes += generator.text(data.procedimientoAlmacenado, styles: center);
      if (!Preferences.paperCut) {
        bytes += generator.emptyLines(3);
      }

      if (Preferences.paperCut) {
        bytes += generator.cut();
      }

      printerVM.printTMU(context, bytes, false);
    } catch (e) {
      final ApiResModel res = ApiResModel(
        succes: false,
        response: e.toString(),
        url: '',
        storeProcedure: '',
      );

      NotificationService.showErrorView(context, res);
    }
  }
}
