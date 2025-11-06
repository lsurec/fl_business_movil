import 'package:fl_business/displays/vehiculos/models/vehiculoYearModel.dart';
import 'package:fl_business/displays/vehiculos/models/vehiculos_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehiculoService {
  final String token;
  final String baseUrl = 'http://192.168.0.101:9085/api/v2/vehiculos'; 

  VehiculoService({required this.token});

  Map<String, String> get headers => {
        'Authorization': 'bearer $token',
        'Content-Type': 'application/json',
      };

  // --- Obtener Marcas ---
  Future<List<VehiculoModel>> obtenerMarcas() async {
    final url = Uri.parse('$baseUrl/marcas');

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      try {
        return VehiculoModel.fromJsonList(res.body);
      } catch (e) {
        throw Exception('Error al parsear marcas: $e');
      }
    } else {
      throw Exception('Error al cargar marcas (${res.statusCode})');
    }
  }

  // --- Obtener Modelos ---
  Future<List<VehiculoModel>> obtenerModelos(int marcaId) async {
    final url = Uri.parse('$baseUrl/modelos/$marcaId');

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      try {
        return VehiculoModel.fromJsonList(res.body);
      } catch (e) {
        throw Exception('Error al parsear modelos: $e');
      }
    } else {
      throw Exception('Error al cargar modelos (${res.statusCode})');
    }
  }

  // --- Obtener Años ---
  Future<List<VehiculoYearModel>> obtenerAnios() async {
    final url = Uri.parse('$baseUrl/anios');

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      try {
        return VehiculoYearModel.fromJsonList(res.body);
      } catch (e) {
        throw Exception('Error al parsear años: $e');
      }
    } else {
      throw Exception('Error al cargar años (${res.statusCode})');
    }
  }

  // --- Obtener Colores ---
  Future<List<VehiculoModel>> obtenerColores() async {
    final url = Uri.parse('$baseUrl/colores');

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      try {
        return VehiculoModel.fromJsonList(res.body);
      } catch (e) {
        throw Exception('Error al parsear colores: $e');
      }
    } else {
      throw Exception('Error al cargar colores (${res.statusCode})');
    }
  }
}
