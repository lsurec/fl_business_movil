import 'dart:convert';
import 'package:fl_business/displays/vehiculos/models/TipoVehiculoModel.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;

class TipoVehiculoService {
  Future<List<TipoVehiculoModel>> getTiposVehiculo(
    String criterioBusqueda,
    String token,
    String userName,
    int empresa,
    int estacionTrabajo,
  ) async {
    final String url = "${Preferences.urlApi}v2/TipoVehiculo/listar";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "bearer $token",
      "userName": userName,
      "empresa": '$empresa',
      "estacionTrabajo": '$estacionTrabajo',
      "criterioBusqueda": criterioBusqueda,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          final List<dynamic> data = jsonResponse["data"];

          return data
              .map<TipoVehiculoModel>(
                (json) => TipoVehiculoModel.fromJson(json),
              )
              .toList();
        } else {
          throw Exception("Error en API: ${jsonResponse["message"]}");
        }
      }

      throw Exception(
        "Error HTTP ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
      );
    } catch (e) {
      print("❌ Error en TipoVehiculoService.getTiposVehiculo(): $e");
      return [];
    }
  }
}
