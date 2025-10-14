// ignore_for_file: use_build_context_synchronously

import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';
import 'package:fl_business/displays/tareas/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;

class FacturaTMU {
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

      final DocPrintModel data = FacturaProvider.data!;

      final TmuUtils utils = TmuUtils();

      final enterpriseLogo = await utils.getEnterpriseLogo(context);

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

      bytes += generator.image(enterpriseLogo, align: PosAlign.center);

      bytes += generator.text(data.empresa.razonSocial, styles: center);
      bytes += generator.text(data.empresa.nombre, styles: center);

      bytes += generator.text(data.empresa.direccion, styles: center);

      bytes += generator.text("NIT: ${data.empresa.nit}", styles: center);

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'tel')} ${data.empresa.tel}",
        styles: center,
      );

      bytes += generator.hr(); // Línea horizontal

      bytes += generator.text(data.documento.titulo, styles: centerBold);

      final docVM = Provider.of<DocumentViewModel>(context, listen: false);

      final bool isFel = docVM.printFel();

      if (!isFel) {
        bytes += generator.text("DOCUMENTO GENERICO", styles: centerBold);
      }

      bytes += generator.hr(); // Línea horizontal

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'serie')} ${data.documento.serieInterna}",
        styles: center,
      );
      bytes += generator.text(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'interno'),
        styles: center,
      );

      bytes += generator.text(data.documento.noInterno, styles: center);

      bytes += generator.text(
        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'consInt')} ${data.documento.consecutivoInterno}",
        styles: center,
      );

      if (isFel) {
        bytes += generator.hr(); // Línea horizontal
        bytes += generator.text(data.documento.descripcion, styles: centerBold);
        bytes += generator.hr(); // Línea horizontal

        bytes += generator.text(
          "Serie: ${data.documento.serie}",
          styles: center,
        );
        bytes += generator.text("No: ${data.documento.no}", styles: center);
        bytes += generator.text(
          "Fecha: ${data.documento.fechaCert}",
          styles: center,
        );

        bytes += generator.text("Autorizacion:", styles: centerBold);

        bytes += generator.text(
          data.documento.autorizacion,
          styles: centerBold,
        );
      }

      bytes += generator.hr(); // Línea horizontal

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
        "${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, 'fecha')} ${data.cliente.fecha}",
        styles: center,
      );

      bytes += generator.text(
        "Registros: ${data.items.length}",
        styles: center,
      );

      bytes += generator.hr(); // Línea horizontal

      if (Preferences.paperSize != 58) {
        bytes += generator.row([
          PosColumn(text: 'Cant.', width: 2), // Ancho 2
          PosColumn(text: 'Descripcion', width: 4), // Ancho 6
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
      } else {
        for (var element in data.items) {
          bytes += generator.text("Cant: ${element.cantidad}");
          bytes += generator.text("Desc: ${element.descripcion}");
          bytes += generator.text("P/U: ${element.unitario}");
          bytes += generator.text(
            "Total: ${element.total}",
            styles: const PosStyles(bold: true),
          );
          bytes += generator.hr(); // Línea horizontal
        }
      }

      if (Preferences.paperSize != 58) {
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

        bytes += generator.hr(); // Línea horizontal

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
      } else {
        bytes += generator.text(
          "Subtotal: ${currencyFormat.format(data.montos.subtotal)}",
        );
        bytes += generator.text(
          "Cargos: ${currencyFormat.format(data.montos.cargos)}",
        );
        bytes += generator.text(
          "Descuentos: ${currencyFormat.format(data.montos.descuentos)}",
        );
        bytes += generator.emptyLines(1);
        bytes += generator.text(
          "TOTAL: ${currencyFormat.format(data.montos.total)}",
          styles: const PosStyles(bold: true, width: PosTextSize.size2),
        );
      }

      bytes += generator.text(data.montos.totalLetras, styles: centerBold);

      bytes += generator.hr(); // Línea horizontal

      bytes += generator.text(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'detallePago'),
        styles: center,
      );

      if (Preferences.paperSize != 58) {
        for (var pago in data.pagos) {
          bytes += generator.row([
            PosColumn(text: "", width: 6),
            PosColumn(
              text: pago.tipoPago,
              styles: const PosStyles(align: PosAlign.right),
              width: 6,
            ),
          ]);
          bytes += generator.row([
            PosColumn(
              text: AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tiket, 'recibido'),
              width: 6,
            ),
            PosColumn(
              text: currencyFormat.format(pago.pago),
              styles: const PosStyles(align: PosAlign.right),
              width: 6,
            ),
          ]);
          bytes += generator.row([
            PosColumn(
              text: AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tiket, 'monto'),
              width: 6,
            ),
            PosColumn(
              text: currencyFormat.format(pago.monto),
              styles: const PosStyles(align: PosAlign.right),
              width: 6,
            ),
          ]);
          bytes += generator.row([
            PosColumn(
              text: AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.tiket, 'cambio'),
              width: 6,
            ),
            PosColumn(
              text: currencyFormat.format(pago.cambio),
              styles: const PosStyles(align: PosAlign.right),
              width: 6,
            ),
          ]);
        }
      } else {
        for (var pago in data.pagos) {
          bytes += generator.hr(); // Línea horizontal

          bytes += generator.text(pago.tipoPago);

          bytes += generator.text(
            "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'recibido')}: ${currencyFormat.format(pago.pago)}",
          );

          bytes += generator.text(
            "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'monto')}: ${currencyFormat.format(pago.monto)}",
          );

          bytes += generator.text(
            "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'cambio')}: ${currencyFormat.format(pago.cambio)}",
          );

          bytes += generator.hr(); // Línea horizontal
        }
      }

      if (data.vendedor != "") {
        bytes += generator.text(
          "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'vendedor')} ${data.vendedor}",
          styles: center,
        );

        bytes += generator.hr(); // Línea horizontal
      }

      for (var mensaje in data.mensajes) {
        bytes += generator.text(mensaje, styles: centerBold);
      }

      bytes += generator.hr(); // Línea horizontal

      if (isFel) {
        bytes += generator.text("Ceritificador:", styles: center);

        bytes += generator.text(data.certificador.nombre, styles: center);

        bytes += generator.text(data.certificador.nit, styles: center);
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

      bytes += generator.cut();

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
