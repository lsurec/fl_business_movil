import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart';
import 'package:http/http.dart' as http;

class ItemVehiculoService {
  Future<List<ItemVehiculoApi>> getItemsVehiculo({
    required String tipoDocumento,
    required String serieDocumento,
    required String empresa,
    required String estacionTrabajo,
    required String token,
    required String user,
  }) async {

    final String url = "${Preferences.urlApi}v2/ItemsVehiculo/items";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "bearer $token",
      "UserName": user,
      "tipoDocumento": tipoDocumento,
      "serieDocumento": serieDocumento,
      "empresa": empresa,
      "estacionTrabajo": estacionTrabajo,
    };

    //  PRINTS DE DEPURACIÓN
    print(" URL: $url");

    print(" HEADERS:");
    headers.forEach((key, value) {
      print("$key: $value");
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print(" STATUS CODE: ${response.statusCode}");
      print(" RESPONSE BODY:");
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        print(" JSON DECODIFICADO:");
        print(jsonResponse);

        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          final List<dynamic> data = jsonResponse["data"];

          print(" ITEMS RECIBIDOS: ${data.length}");

          return data
              .map<ItemVehiculoApi>((json) => ItemVehiculoApi.fromJson(json))
              .toList();
        } else {
          print(" ERROR LÓGICO API:");
          print(jsonResponse["message"]);
          throw Exception("Error en API: ${jsonResponse["message"]}");
        }
      }

      print(" ERROR HTTP:");
      print("Código: ${response.statusCode}");
      print("Mensaje: ${response.reasonPhrase}");

      throw Exception(
        "Error HTTP ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
      );
    } catch (e) {
      print(" EXCEPCIÓN en getItemsVehiculo:");
      print(e);
      return [];
    }
  }
}