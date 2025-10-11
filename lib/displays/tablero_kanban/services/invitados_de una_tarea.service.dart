import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;
import '../models/invitados_model.dart';

class InvitadosService {
  Future<List<Invitado>> obtenerInvitados(int idTarea) async {
    final String baseUrl = "${Preferences.urlApi}Tareas/invitados";
    final String token = Preferences.token;
    final String usuario = Preferences.userName;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "user": usuario,
          "tarea": idTarea.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final data = jsonBody["data"] as List;
        return data.map((e) => Invitado.fromJson(e)).toList();
      } else {
        print("Respuesta fallida: ${response.statusCode} -> ${response.body}");
        throw Exception(
          "Error al obtener invitados de la tarea $idTarea: ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error en obtenerInvitados: $e");
    }
  }
}
