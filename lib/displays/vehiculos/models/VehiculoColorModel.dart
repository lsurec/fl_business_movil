import 'dart:convert';

class VehiculoColorModel {
  final int color; // Identificador numérico del color
  final String descripcion; // Nombre del color

  VehiculoColorModel({
    required this.color,
    required this.descripcion,
  });

  /// Crear una instancia desde un Map
  factory VehiculoColorModel.fromJson(Map<String, dynamic> json) {
    return VehiculoColorModel(
      color: json['color'] ?? 0,
      descripcion: json['descripcion'] ?? '',
    );
  }

  /// Convertir una lista JSON en una lista de objetos
  static List<VehiculoColorModel> fromJsonList(String str) {
    final jsonData = json.decode(str);

    if (jsonData is Map && jsonData.containsKey('data')) {
      final List data = jsonData['data'];
      return data
          .map((e) => VehiculoColorModel.fromJson(e))
          .toList();
    }

    if (jsonData is List) {
      return jsonData
          .map((e) => VehiculoColorModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Formato de JSON inesperado para VehiculoColorModel',
    );
  }

  /// Convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() => descripcion;
}