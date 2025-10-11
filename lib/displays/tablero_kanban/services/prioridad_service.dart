import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;
import '../models/prioridad_model.dart';

class PrioridadService {
  Future<List<Prioridad>> fetchPrioridades() async {
    final String baseUrl = "${Preferences.urlApi}Tareas/tipo/prioridad/sa";
    final String token = Preferences.token;
    final String user = Preferences.userName;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "bearer $token", "user": user},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List prioridadesData = jsonData["data"];
        return prioridadesData.map((e) => Prioridad.fromJson(e)).toList();
      } else {
        throw Exception(
          "Error al cargar prioridades: ${response.statusCode} ${response.body}",
        );
      }
    } catch (e) {
      print("Error en PrioridadService: $e");
      return [];
    }
  }
}
