import 'dart:convert';
import 'package:fl_business/displays/vehiculos/models/CatalogoVehiculoModel.dart';
import 'package:http/http.dart' as http;
import 'package:fl_business/shared_preferences/preferences.dart';

class CatalogoVehiculosService {

  String get baseUrl => "${Preferences.urlApi}v2/catalogo-vehiculos";

  //  CREAR VEHÍCULO (SOLO POST)
  Future<bool> crearVehiculo(CatalogoVehiculosModel model, String usuario, int empresa, token) async {
    final url = Uri.parse("$baseUrl/crear");

    final body = model.toJson();

    print(' REQUEST BODY:');
    print(jsonEncode(body));

    final response = await http.post(
      url,
      headers: {
    "Authorization": "bearer ${token}",
    "Content-Type": "application/json",
    "UserName": usuario,
    "empresa": empresa.toString(),
  },
      body: jsonEncode(body),
    );

    print(' STATUS CODE: ${response.statusCode}');
    print(' RESPONSE BODY: ${response.body}');

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['status'] == true) {
      return true;
    } else {
      throw Exception(decoded['message'] ?? 'Error al crear vehículo');
    }
  }
}
