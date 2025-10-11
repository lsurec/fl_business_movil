import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;
import '../models/tipo_tarea_model.dart';

class TipoTareaService {
  Future<List<TipoTarea>> getTiposTarea() async {
    // Tomamos URL y token desde Preferences
    final String baseUrl = "${Preferences.urlApi}Tareas/tipos/sa";
    final String token = Preferences.token;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> lista = data['data'];
        return lista.map((json) => TipoTarea.fromJson(json)).toList();
      } else {
        throw Exception(
          'Error al cargar tipos de tarea: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print("Error en TipoTareaService: $e");
      return [];
    }
  }
}
