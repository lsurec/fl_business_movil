import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_business/shared_preferences/preferences.dart';
import '../models/referencia_model.dart';
import '../models/response_model.dart';

class ReferenciaService {
  Future<ApiResponse<List<Referencia>>> buscarPorTexto({
    required String texto,
    required String empresa,
  }) async {
    final token = Preferences.token;
    final user = Preferences.userName;
    final String baseUrl =
        "${Preferences.urlApi}Tareas/idReferencia"; // tu endpoint correcto

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "bearer $token",
          "user": user,
          "filtro": texto,
          "empresa": empresa,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        return ApiResponse.fromJson(
          jsonData,
          (data) =>
              (data as List).map((item) => Referencia.fromJson(item)).toList(),
        );
      } else {
        return ApiResponse<List<Referencia>>(
          success: false,
          message: "Error al consultar API: ${response.statusCode}",
          data: [],
        );
      }
    } catch (e) {
      return ApiResponse<List<Referencia>>(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }
}
