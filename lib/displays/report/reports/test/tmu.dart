import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:provider/provider.dart';
import 'package:diacritic/diacritic.dart';

class TestTMU {
  List<int> report = [];

  Future<bool> getReport(BuildContext context) async {
    try {
      final LoginViewModel vmLogin = Provider.of<LoginViewModel>(
        context,
        listen: false,
      );

      final LocalSettingsViewModel vmSettings =
          Provider.of<LocalSettingsViewModel>(context, listen: false);

      final TmuUtils utils = TmuUtils();

      final enterpriseLogo = await utils.getEnterpriseLogo(context);
      final myLogo = await utils.getMyCompanyLogo();

      final generator = Generator(
        AppData.paperSize[Preferences.paperSize],
        await CapabilityProfile.load(),
      );

      PosStyles center = const PosStyles(align: PosAlign.center);
      PosStyles centerBold = const PosStyles(
        align: PosAlign.center,
        bold: true,
      );

      report = [];

      report += generator.image(enterpriseLogo, align: PosAlign.center);

      report += generator.hr();
      report += generator.text(
        removeDiacritics("PRUEBA DE IMPRESIÓN"),
        styles: centerBold,
      );
      report += generator.hr();

      report += generator.text("Dispositivo: ${Preferences.printer!.name}");
      report += generator.text(
        removeDiacritics("Dirección: ${Preferences.printer!.address}"),
      );
      report += generator.text(
        removeDiacritics("Tamaño de papel: ${Preferences.paperSize} mm"),
      );
      report += generator.emptyLines(1);
      report += generator.text(
        removeDiacritics("*** Conexión exitosa ***"),
        styles: center,
      );
      report += generator.emptyLines(1);
      report += generator.hr();
      report += generator.text("Usuario: ${vmLogin.user}");
      report += generator.text(
        removeDiacritics(
          "Empresa: ${vmSettings.selectedEmpresa!.empresaNombre}",
        ),
      );
      report += generator.text(
        removeDiacritics(
          "Estación: ${vmSettings.selectedEstacion!.descripcion}",
        ),
      );
      report += generator.text("Fecha: ${Utilities.getDateDDMMYYYY()}");
      report += generator.text("Origen de datos: ${Preferences.urlApi}");
      report += generator.hr(); // Línea horizontal
      report += generator.image(myLogo, align: PosAlign.center);
      report += generator.text("Powered by", styles: center);
      report += generator.text(Utilities.author.nombre, styles: center);
      report += generator.text(Utilities.author.website, styles: center);

      report += generator.text(
        removeDiacritics("Versión: ${SplashViewModel.versionLocal}"),
        styles: center,
      );

      report += generator.cut();

      return true;
    } catch (e) {
      final ApiResModel res = ApiResModel(
        succes: false,
        response: e.toString(),
        url: '',
        storeProcedure: '',
      );

      NotificationService.showErrorView(context, res);

      return false;
    }
  }
}
