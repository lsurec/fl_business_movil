import 'dart:convert';
import 'package:fl_business/shared_preferences/preferences.dart';

import '../models/usuario_model.dart';
import 'package:http/http.dart' as http;

class UsuarioService {
  final String baseUrl = "${Preferences.urlApi}usuarios";

  Future<List<Usuario>> buscarUsuarios({required String filtro}) async {
    final token = Preferences.token;
    final user = Preferences.userName;

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'bearer $token',
        'user': user,
        'filtro': filtro,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar usuarios: ${response.statusCode}');
    }
  }
}
