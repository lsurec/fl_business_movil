import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;
import '../models/estado_model.dart';

class EstadoService {
  // ================== MÉTODO PARA OBTENER ESTADOS ==================
  Future<List<Estado>> getEstados() async {
    // Tomamos URL, token y user desde Preferences
    final String baseUrl = "${Preferences.urlApi}Tareas/estados";
    final String token = Preferences.token;
    final String user = Preferences.userName;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "bearer $token", "user": user},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List estadosData = jsonData["data"];
        return estadosData.map((e) => Estado.fromJson(e)).toList();
      } else {
        throw Exception(
          "Error al cargar estados: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Error en EstadoService: $e");
      return [];
    }
  }
}
