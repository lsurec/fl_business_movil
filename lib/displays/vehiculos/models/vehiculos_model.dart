import 'dart:convert';

class VehiculoModel {
  final int id;
  final String descripcion;

  VehiculoModel({
    required this.id,
    required this.descripcion,
  });

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'] ?? json['modelo'] ?? json['anio'] ?? json['color'] ?? 0,
      descripcion: json['descripcion'] ?? '',
    );
  }

  static List<VehiculoModel> fromJsonList(String str) {
    final jsonData = json.decode(str);

    if (jsonData is Map && jsonData.containsKey('data')) {
      final data = jsonData['data'] as List;
      return data.map((e) => VehiculoModel.fromJson(e)).toList();
    }

    if (jsonData is List) {
      return jsonData.map((e) => VehiculoModel.fromJson(e)).toList();
    }

    throw Exception('Formato de JSON inesperado para VehiculoModel');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() => descripcion;
}
