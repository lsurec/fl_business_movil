import 'dart:convert';

class VehiculoYearModel {
  final int anio;

  VehiculoYearModel({required this.anio});

  factory VehiculoYearModel.fromJson(Map<String, dynamic> json) {
    return VehiculoYearModel(anio: json['anio'] ?? json['year'] ?? 0);
  }

  static List<VehiculoYearModel> fromJsonList(String str) {
    final jsonData = json.decode(str);

    if (jsonData is Map && jsonData.containsKey('data')) {
      final data = jsonData['data'] as List;
      return data.map((e) => VehiculoYearModel.fromJson(e)).toList();
    }

    if (jsonData is List) {
      return jsonData.map((e) => VehiculoYearModel.fromJson(e)).toList();
    }

    throw Exception('Formato de JSON inesperado para VehiculoYearModel');
  }

  @override
  String toString() => anio.toString();
}
