import 'dart:io';
import 'package:fl_business/models/url_pic_model.dart';
import 'package:fl_business/services/logo_service.dart';
import 'package:flutter/material.dart';

class LogoProvider extends ChangeNotifier {
  File? logo;

  Future<void> loadLogo(String token, UrlPicModel pic) async {
    logo = await LogoService.getLocalLogo();
    notifyListeners();

    if (logo != null) return;

    if (token.isEmpty || pic.url.isEmpty) return;

    // 2. Si no existe, descargarlo en segundo plano

    LogoService.downloadAndSaveLogo(token, pic).then((file) {
      if (file != null) {
        logo = file;
        notifyListeners();
      }
    });
  }
}
