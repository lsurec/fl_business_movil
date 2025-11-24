import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_business/shared_preferences/preferences.dart';

import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/post_document_model.dart';

class VehiculoService {
  VehiculoService();

  // ============= HEADERS AUTOMÁTICOS DESDE PREFERENCES =============
  Map<String, String> get headers => {
        "Authorization": "bearer ${Preferences.token}",
        "Content-Type": "application/json",
      };

  // ============= BASE URL AUTOMÁTICA =============
  String get baseUrl => "${Preferences.urlApi}v2/vehiculos";

  // ====================== OBTENER MARCAS ======================
  Future<List<VehiculoModel>> obtenerMarcas() async {
    final url = Uri.parse("$baseUrl/marcas");

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      return VehiculoModel.fromJsonList(res.body);
    } else {
      throw Exception("Error al cargar marcas (${res.statusCode})");
    }
  }

  // ====================== OBTENER MODELOS ======================
  Future<List<VehiculoModel>> obtenerModelos(int marcaId) async {
    final url = Uri.parse("$baseUrl/modelos/$marcaId");

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      return VehiculoModel.fromJsonList(res.body);
    } else {
      throw Exception("Error al cargar modelos (${res.statusCode})");
    }
  }

  // ====================== OBTENER AÑOS ======================
  Future<List<VehiculoYearModel>> obtenerAnios() async {
    final url = Uri.parse("$baseUrl/anios");

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      return VehiculoYearModel.fromJsonList(res.body);
    } else {
      throw Exception("Error al cargar años (${res.statusCode})");
    }
  }

  // ====================== OBTENER COLORES ======================
  Future<List<VehiculoModel>> obtenerColores() async {
    final url = Uri.parse("$baseUrl/colores");

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      return VehiculoModel.fromJsonList(res.body);
    } else {
      throw Exception("Error al cargar colores (${res.statusCode})");
    }
  }

  // ====================== GUARDAR DOCUMENTO ======================
  Future<Map<String, dynamic>> enviarDocumento(PostDocumentModel documento) async {
    final url = Uri.parse("$baseUrl/documento/crear");

    final res = await http.post(
      url,
      headers: headers,
      body: documento.toJson(),
    );

    print("Respuesta servidor: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error al guardar documento (${res.statusCode})");
    }
  }
}
