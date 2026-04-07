import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fl_business/shared_preferences/preferences.dart';
import '../models/upload_file_model.dart';
import '../models/upload_response_model.dart';

class UploadService {

  Future<List<FileNameModel>> uploadImages({
    required List<String> imagePaths,
    required String token,
    required String urlCarpeta,
    required String user,
  }) async {

    final String url = "${Preferences.urlApi}v2/Shared/files";

    var uri = Uri.parse(url);

    var request = http.MultipartRequest("POST", uri);

    // 🔹 HEADERS DINÁMICOS
    request.headers.addAll({
      "Authorization": "bearer $token",
      "UserName": user,
    });

    // 🔹 FIELD
    request.fields['urlCarpeta'] = urlCarpeta;

    // 🔍 LOGS DE DEPURACIÓN
    print("📤 URL: $url");

    print("📤 HEADERS:");
    request.headers.forEach((key, value) {
      print("$key: $value");
    });

    print("📤 PARAMS:");
    print("urlCarpeta: $urlCarpeta");

    print("📤 ARCHIVOS:");
    for (var path in imagePaths) {
      print("Archivo: $path");

      request.files.add(
        await http.MultipartFile.fromPath('file', path),
      );
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RESPONSE BODY:");
      print(responseBody);

      if (response.statusCode == 200) {

        final decoded = json.decode(responseBody);

        print("📥 JSON DECODIFICADO:");
        print(decoded);

        final uploadResponse = UploadResponseModel.fromJson(decoded);

        if (uploadResponse.status) {
          print("✅ SUBIDA EXITOSA");
          print("📦 ARCHIVOS SUBIDOS: ${uploadResponse.data.length}");

          return uploadResponse.data;
        } else {
          print("⚠️ ERROR LÓGICO API:");
          print(uploadResponse.message);

          throw Exception(uploadResponse.message);
        }
      }

      print("❌ ERROR HTTP:");
      print("Código: ${response.statusCode}");
      print("Body: $responseBody");

      throw Exception("Error HTTP ${response.statusCode}: $responseBody");

    } catch (e) {
      print("❌ EXCEPCIÓN en uploadImages:");
      print(e);
      return [];
    }
  }
}