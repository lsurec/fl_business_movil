import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fl_business/displays/report/models/report_fact_cont_cred_model.dart';
import 'package:fl_business/displays/report/reports/tmu/utilities_tmu.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:provider/provider.dart';

class FactTContadoCredTMU {
  //reports function
  static Future<void> getReport(
    BuildContext context,
    ReportFactContCredModel data,
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

    // final enterpriseLogo = await utils.getEnterpriseLogo(context);

    List<int> bytes = [];

    final generator = Generator(
      AppData.paperSize[Preferences.paperSize],
      await CapabilityProfile.load(),
    );

    bytes += generator.setGlobalCodeTable('CP1252');

    // bytes += generator.image(enterpriseLogo, align: PosAlign.center);

    //Reporte de xistencias
    // Encabezado
    bytes += generator.text(
      "LISTA FACTURAS, TOTALES DE CREDITO Y CONTADO",
      styles: UtilitiesTMU.centerBold,
    );

    bytes += generator.hr(); // Línea horizontal

    bytes += generator.text(
      "Fecha: ${Utilities.getDateDDMMYYYY()}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Fecha inicio: ${Utilities.formatearFecha(data.startDate)}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Fecha fin: ${Utilities.formatearFecha(data.endDate)}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Usuario: ${loginVM.user}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Bodega: (${data.idBodega}) ${data.bodega}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.text(
      "Registros: ${data.docs.length}",
      styles: UtilitiesTMU.center,
    );

    bytes += generator.hr(); // Línea horizontal

    for (var element in data.docs) {
      bytes += generator.text("ID: ${element.id}");
      bytes += generator.text("Monto: ${element.monto.toStringAsFixed(2)}");
      bytes += generator.hr(); // Línea horizontal
    }

    bytes += generator.hr(); // Línea horizontal

    bytes += generator.text(
      "Total Contado (Venta):",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text(
      "   ${data.totalContado}",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text(
      "Total Crédito (Venta):",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text(
      "   ${data.totalCredito}",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text("Total:", styles: UtilitiesTMU.startBold);
    bytes += generator.text(
      "   ${data.totalContCred}",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text(
      "Cantidad Documentos:",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.text(
      "   ${data.docs.length}",
      styles: UtilitiesTMU.startBold,
    );
    bytes += generator.hr(); // Línea horizontal
    // Información adicional

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
