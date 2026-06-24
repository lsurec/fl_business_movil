import 'dart:convert';

import 'package:fl_business/displays/vehiculos/models/elemento_asignado_croquis_model.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;

class CroquisService {
  final String _baseUrl = Preferences.urlApi;

  /// CREAR
  Future<ApiResponseModel> crearCroquis(
    CrearCroquisModel model,
    String token,
  ) async {
    String url = "${_baseUrl}v2/Croquis/croquis";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: model.toJson(),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        res.data = (res.data as List)
            .map((e) => CroquisModel.fromMap(e))
            .toList();
      }

      res.url = url;

      return res;
    } catch (e) {
      return ApiResponseModel(
        status: false,
        message: "Error no controlado",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "",
        url: url,
      );
    }
  }

  /// OBTENER
  Future<ApiResponseModel> obtenerCroquis(int empresa, String token) async {
    String url = "${_baseUrl}v2/Croquis/croquis";

    try {
      final uri = Uri.parse(
        url,
      ).replace(queryParameters: {"empresa": empresa.toString()});

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("url de la petición: $url");
        res.data = (res.data as List)
            .map((e) => CroquisModel.fromMap(e))
            .toList();
      }

      res.url = url;

      return res;
    } catch (e) {
      return ApiResponseModel(
        status: false,
        message: "Error no controlado",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "",
        url: url,
      );
    }
  }

  /// ACTUALIZAR
  Future<ApiResponseModel> actualizarCroquis(
    ActualizarCroquisModel model,
    String token,
  ) async {
    String url = "${_baseUrl}v2/Croquis/croquis";

    try {
      final response = await http.put(
        Uri.parse(url),
        body: model.toJson(),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return ApiResponseModel.fromMap(jsonDecode(response.body));
    } catch (e) {
      return ApiResponseModel(
        status: false,
        message: "Error no controlado",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "",
        url: url,
      );
    }
  }

  /// ELIMINAR
  Future<ApiResponseModel> eliminarCroquis(
    int consecutivoInterno,
    String usuario,
    String token,
  ) async {
    String url = "${_baseUrl}v2/Croquis/croquis";

    try {
      final uri = Uri.parse(url).replace(
        queryParameters: {
          "consecutivoInterno": consecutivoInterno.toString(),
          "usuario": usuario,
        },
      );

      final response = await http.delete(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      return ApiResponseModel.fromMap(jsonDecode(response.body));
    } catch (e) {
      return ApiResponseModel(
        status: false,
        message: "Error no controlado",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "",
        url: url,
      );
    }
  }

  Future<ApiResponseModel> obtenerCroquisTodos(
    int empresa,
    String token,
  ) async {
    String url = "${_baseUrl}v2/Croquis/croquis/todos";

    try {
      final uri = Uri.parse(
        url,
      ).replace(queryParameters: {"empresa": empresa.toString()});

      final response = await http.get(
        uri,
        headers: {"Authorization": "Bearer $token"},
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 200) {
        res.data = (res.data as List)
            .map((e) => CroquisModel.fromMap(e))
            .toList();
      }

      return res;
    } catch (e) {
      return ApiResponseModel(
        status: false,
        message: "Error no controlado",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "",
        url: url,
      );
    }
  }
}
