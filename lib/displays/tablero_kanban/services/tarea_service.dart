import 'dart:convert';
import 'package:fl_business/displays/tablero_kanban/models/tarea_model.dart';

import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/models/response_model.dart';
import 'package:http/http.dart' as http;

import 'package:fl_business/shared_preferences/preferences.dart';

class TareaService {
  final String _baseUrl = Preferences.urlApi;

  // ================== TODAS ==================
  Future<ApiResModel> getTodas(
    String user,
    String token,
    int rangoIni,
    int rangoFin,
  ) async {
    return _getTareasPorUrl("tareas/todas", user, token, rangoIni, rangoFin);
  }

  // ================== CREADAS ==================
  Future<ApiResModel> getRangoCreadas(
    String user,
    String token,
    int rangoIni,
    int rangoFin,
  ) async {
    return _getTareasPorUrl("tareas/creadas", user, token, rangoIni, rangoFin);
  }

  // ================== ASIGNADAS ==================
  Future<ApiResModel> getRangoAsignadas(
    String user,
    String token,
    int rangoIni,
    int rangoFin,
  ) async {
    return _getTareasPorUrl(
      "tareas/asignadas",
      user,
      token,
      rangoIni,
      rangoFin,
    );
  }

  // ================== INVITADAS ==================
  Future<ApiResModel> getRangoInvitadas(
    String user,
    String token,
    int rangoIni,
    int rangoFin,
  ) async {
    return _getTareasPorUrl(
      "tareas/invitaciones",
      user,
      token,
      rangoIni,
      rangoFin,
    );
  }

  // ================== MÉTODO PRIVADO COMÚN ==================
  Future<ApiResModel> _getTareasPorUrl(
    String endpoint,
    String user,
    String token,
    int rangoIni,
    int rangoFin,
  ) async {
    Uri url = Uri.parse("$_baseUrl$endpoint");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "bearer $token",
          "user": user,
          "rangoIni": rangoIni.toString(),
          "rangoFin": rangoFin.toString(),
        },
      );

      ResponseModel res = ResponseModel.fromMap(jsonDecode(response.body));

      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }

      List<Tarea> tareas = [];
      for (var item in res.data) {
        tareas.add(Tarea.fromJson(item));
      }

      return ApiResModel(
        url: url.toString(),
        succes: true,
        response: tareas,
        storeProcedure: null,
      );
    } catch (e) {
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }
}
