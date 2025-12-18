import 'dart:convert';
import 'dart:io';
import 'package:fl_business/models/api_response_model.dart';
import 'package:fl_business/models/url_pic_model.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LogoService {
  static final _logoFileName = Preferences.logo;

  /// Retorna el archivo si existe, sino null
  static Future<File?> getLocalLogo() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$_logoFileName");

    if (await file.exists()) {
      return file;
    }
    return null;
  }

  /// Descarga el logo por API POST, decodifica Base64 y guarda
  static Future<File?> downloadAndSaveLogo(
    String token,
    UrlPicModel urlPicture,
  ) async {
    final url = Uri.parse("${Preferences.urlApi}v2/Picture/base64");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "bearer $token",
        },
        body: urlPicture.toJson(), // Cambia los parámetros
      );

      if (response.statusCode == 200) {
        //guardar nombre de la imagen

        ApiResponseModel res = ApiResponseModel.fromMap(
          jsonDecode(response.body),
        );

        final String base64Str = res.data;

        final bytes = base64Decode(base64Str);

        Uri uriPicture = Uri.parse(urlPicture.url);
        Preferences.logo =
            uriPicture.pathSegments.last; // "miumagen.mmiinmaen.jpg"

        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/${Preferences.logo}");

        await file.writeAsBytes(bytes, flush: true);
        return file;
      }
    } catch (_) {
      NotificationService.showSnackbar("No se pudo cargar el logo");
    }

    return null;
  }
}
