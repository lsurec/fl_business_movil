import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fl_business/displays/report/models/models.dart';
import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:provider/provider.dart';

class ExistenciasTMU {
  //reports function
  static Future<void> getReport(
    BuildContext context,
    ReportStockModel data,
  ) async {
    final PrinterViewModel printerVM = Provider.of<PrinterViewModel>(
      context,
      listen: false,
    );

    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    final TmuUtils utils = TmuUtils();

    final enterpriseLogo = await utils.getEnterpriseLogo(context);

    List<int> bytes = [];

    final generator = Generator(
      AppData.paperSize[Preferences.paperSize],
      await CapabilityProfile.load(),
    );

    bytes += generator.image(enterpriseLogo, align: PosAlign.center);

    //Reporte de xistencias
    // Encabezado
    bytes += generator.text(
      "REPORTE DE EXISTENCIAS",
      styles: UtilitiesTMU.centerBold,
    );

    bytes += generator.hr(); // Línea horizontal

    bytes += generator.text(
      "Fecha: ${Utilities.getDateDDMMYYYY()}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Bodega: (${data.idBodega}) ${data.bodega}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Usuario: ${loginVM.user}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Registros: ${data.products.length}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.hr(); // Línea horizontal

    for (var element in data.products) {
      bytes += generator.text("ID: ${element.id}");
      bytes += generator.text("Producto: ${element.desc}");
      bytes += generator.text("Existenacia: ${element.existencias}");
      bytes += generator.hr(); // Línea horizontal
    }

    // Información adicional
    bytes += generator.text("Total: ${data.total}");
    bytes += generator.hr(); // Línea horizontal

    bytes += generator.text("Powered by", styles: UtilitiesTMU.center);

    bytes += generator.text(
      Utilities.author.nombre,
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      Utilities.author.website,
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Version: ${SplashViewModel.versionLocal}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(data.storeProcedure, styles: UtilitiesTMU.center);

    bytes += generator.cut();

    printerVM.printTMU(context, bytes, false);
  }
}
