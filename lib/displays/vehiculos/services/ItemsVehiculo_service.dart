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
  }) async {
 
    final String url = "${Preferences.urlApi}v2/ItemsVehiculo/items";
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "bearer ${Preferences.token}",
      "UserName": Preferences.userName,
      "tipoDocumento": tipoDocumento,
      "serieDocumento": serieDocumento,
      "empresa": empresa,
      "estacionTrabajo": estacionTrabajo,
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse["status"] == true && jsonResponse["data"] != null) {
          final List<dynamic> data = jsonResponse["data"];
          return data
              .map<ItemVehiculoApi>((json) => ItemVehiculoApi.fromJson(json))
              .toList();
        } else {
          throw Exception("Error en API: ${jsonResponse["message"]}");
        }
      }

      throw Exception(
        "Error HTTP ${response.statusCode}: ${response.reasonPhrase}\n${response.body}",
      );
    } catch (e) {
      print(" Error en ItemVehiculoService.getItemsVehiculo(): $e");
      return [];
    }
  }
}
