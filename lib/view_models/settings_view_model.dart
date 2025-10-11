import 'package:flutter/material.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/themes/themes.dart';

class SettingsViewModel extends ChangeNotifier {
  navigatePrint(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.printer,
      arguments: PrintDocSettingsModel(opcion: 1),
    );
  }

  navigateLang(BuildContext context) {
    AppLocalizations.cambiarIdioma = 1;
    notifyListeners();
    Navigator.pushNamed(
      context,
      AppRoutes.lang,
      // arguments: PrintDocSettingsModel(opcion: 1),
    );
  }

  navigateTheme(BuildContext context) {
    AppTheme.cambiarTema = 1;
    notifyListeners();
    Navigator.pushNamed(
      context,
      AppRoutes.theme,
      // arguments: PrintDocSettingsModel(opcion: 1),
    );
  }
}
