import 'dart:convert';
import 'package:fl_business/displays/vehiculos/models/ItemsVehiculo_model.dart';
import 'package:http/http.dart' as http;

class ItemVehiculoService {
  final String baseUrl = 'http://192.168.0.101:9085/api/v2/ItemsVehiculo/items';

  /// Obtiene la lista de ítems de vehículo desde la API
  Future<List<ItemVehiculo>> getItemsVehiculo({
    required String token,
    required String userName,
    required String tipoDocumento,
    required String serieDocumento,
    required String empresa,
    required String estacionTrabajo,
  }) async {
    final uri = Uri.parse(baseUrl);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
      'UserName': userName,
      'tipoDocumento': tipoDocumento,
      'serieDocumento': serieDocumento,
      'empresa': empresa,
      'estacionTrabajo': estacionTrabajo,
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      if (body['status'] == true && body['data'] != null) {
        final List<dynamic> data = body['data'];
        return data.map((item) => ItemVehiculo.fromJson(item)).toList();
      } else {
        throw Exception('Error en la respuesta: ${body['message']}');
      }
    } else {
      throw Exception('Error al obtener datos: ${response.statusCode}');
    }
  }
}
