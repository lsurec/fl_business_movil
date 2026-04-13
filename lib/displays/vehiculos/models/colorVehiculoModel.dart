import 'dart:convert';

class ColorVehiculoModel {
  final String descripcion;
  final int color;

  ColorVehiculoModel({required this.descripcion, required this.color});

  /// Crear una instancia desde un Map
  factory ColorVehiculoModel.fromJson(Map<String, dynamic> json) {
    return ColorVehiculoModel(
      descripcion: json['descripcion'] ?? '',
      color: json['color'] ?? 0,
    );
  }

  /// Convertir el objeto a Map
  Map<String, dynamic> toJson() {
    return {'descripcion': descripcion, 'color': color};
  }

  /// Convertir un JSON String a una lista de ColorModel
  static List<ColorVehiculoModel> fromJsonList(String str) {
    final Map<String, dynamic> jsonData = json.decode(str);
    final List<dynamic> data = jsonData['data'] ?? [];

    return data.map((item) => ColorVehiculoModel.fromJson(item)).toList();
  }

  /// (Opcional) Convertir un JSON String a un solo objeto
  factory ColorVehiculoModel.fromRawJson(String str) =>
      ColorVehiculoModel.fromJson(json.decode(str));

  /// (Opcional) Convertir el objeto a JSON String
  String toRawJson() => json.encode(toJson());
}
