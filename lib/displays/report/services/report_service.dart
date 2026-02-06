import 'dart:convert';
import 'package:fl_business/displays/report/models/models.dart';
import 'package:fl_business/displays/report/reports/estado_cuenta/estado_cuenta_model.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;

class ReportService {
  //url del servidor
  final String _baseUrl = Preferences.urlApi;

  Future<ApiResponseModel> getEstadoCuenta(
    String token,
    String user,
    int consecutivo,
  ) async {
    Uri url = Uri.parse("${_baseUrl}v2/report/estado/cuenta");

    try {
      //url completa

      //configuracion del api
      final response = await http.get(
        url,
        headers: {
          // "Authorization": "bearer $token",
          "Authorization": "bearer $token",
          "user": user,
          "consecutivo": "$consecutivo",
        },
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        List<EstadoCuentaModel> items = (res.data as List)
            .map((item) => EstadoCuentaModel.fromMap(item))
            .toList();

        res.data = items;
      }

      res.url = url.toString();
      return res;
    } catch (e) {
      //respuesta incorrecta
      return ApiResponseModel(
        status: false,
        message: "Excepcion no controlada",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "Desconocida",
        url: url.toString(),
      );
    }
  }

  Future<ApiResponseModel> getRptFacturas(
    String token,
    String user,
    DateTime startDate,
    DateTime endDate,
    int typeDoc,
    int enterprise,
    int station,
    int warehouse,
  ) async {
    Uri url = Uri.parse("${_baseUrl}v2/Report/facturas");

    try {
      //url completa

      //configuracion del api
      final response = await http.get(
        url,
        headers: {
          // "Authorization": "bearer $token",
          "Authorization": "bearer $token",
          "user": user,
          "startDate": "$startDate",
          "endDate": "$endDate",
          "typeDoc": "$typeDoc",
          "enterprise": "$enterprise",
          "station": "$station",
          "warehouse": "$warehouse",
        },
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        List<ViewFacturaModel> items = (res.data as List)
            .map((item) => ViewFacturaModel.fromMap(item))
            .toList();

        res.data = items;
      }

      res.url = url.toString();
      return res;
    } catch (e) {
      //respuesta incorrecta
      return ApiResponseModel(
        status: false,
        message: "Excepcion no controlada",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "Desconocida",
        url: url.toString(),
      );
    }
  }

  Future<ApiResponseModel> getRptExistencias(
    String token,
    String user,
    int enterprise,
    int station,
    int warehouse,
  ) async {
    Uri url = Uri.parse("${_baseUrl}v2/Report/stock");

    try {
      //url completa

      //configuracion del api
      final response = await http.get(
        url,
        headers: {
          // "Authorization": "bearer $token",
          "Authorization": "bearer $token",
          "user": user,
          "enterprise": "$enterprise",
          "station": "$station",
          "warehouse": "$warehouse",
        },
      );

      ApiResponseModel res = ApiResponseModel.fromMap(
        jsonDecode(response.body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        List<ViewStockModel> items = (res.data as List)
            .map((item) => ViewStockModel.fromMap(item))
            .toList();

        res.data = items;
      }

      res.url = url.toString();
      return res;
    } catch (e) {
      //respuesta incorrecta
      return ApiResponseModel(
        status: false,
        message: "Excepcion no controlada",
        error: e.toString(),
        storedProcedure: "",
        parameters: null,
        data: [],
        timestamp: DateTime.now(),
        version: "Desconocida",
        url: url.toString(),
      );
    }
  }
}
