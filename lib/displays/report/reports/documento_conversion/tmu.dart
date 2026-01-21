import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/models/print_model.dart';
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

      final data = FacturaProvider.data!;

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

      bytes += generator.text(data.empresa.razonSocial, styles: center);
      bytes += generator.text(data.empresa.nombre, styles: center);

      bytes += generator.text(data.empresa.direccion, styles: center);

      bytes += generator.text("NIT: ${data.empresa.nit}", styles: center);

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, "noVinculada")} ${data.empresa.tel}",
        styles: center,
      );

      bytes += generator.emptyLines(1);

      bytes += generator.text(data.documento.titulo, styles: centerBold);

      bytes += generator.text(data.documento.descripcion, styles: centerBold);

      bytes += generator.emptyLines(1);
      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'interno')} ${data.documento.noInterno}",
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

      for (var transaction in data.items) {
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
          text: currencyFormat.format(data.montos.subtotal),
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
          text: currencyFormat.format(data.montos.cargos),
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
          text: currencyFormat.format(data.montos.descuentos),
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
          text: currencyFormat.format(data.montos.total),
          styles: const PosStyles(
            bold: true,
            align: PosAlign.right,
            width: PosTextSize.size2,
            underline: true,
          ),
          width: 6,
        ),
      ]);

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
