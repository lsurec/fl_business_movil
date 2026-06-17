import 'dart:convert';

////////////////// Modelo de respuesta
class CroquisModel {
  int consecutivoInterno;
  String descripcion;
  String? imagenUrl;
  int empresa;
  int estado;
  String userName;
  DateTime fechaHora;

  CroquisModel({
    required this.consecutivoInterno,
    required this.descripcion,
    this.imagenUrl,
    required this.empresa,
    required this.estado,
    required this.userName,
    required this.fechaHora,
  });

  factory CroquisModel.fromJson(String str) =>
      CroquisModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CroquisModel.fromMap(Map<String, dynamic> json) {
    return CroquisModel(
      consecutivoInterno: json["consecutivo_Interno"] ?? 0,
      descripcion: json["descripcion"] ?? "",
      imagenUrl: json["imagenUrl"],
      empresa: json["empresa"] ?? 0,
      estado: json["estado"] ?? 0,
      userName: json["userName"] ?? "",
      fechaHora: DateTime.parse(json["fecha_Hora"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "consecutivo_Interno": consecutivoInterno,
      "descripcion": descripcion,
      "imagenUrl": imagenUrl,
      "empresa": empresa,
      "estado": estado,
      "userName": userName,
      "fecha_Hora": fechaHora.toIso8601String(),
    };
  }
}

//////// Modelo para crear
class CrearCroquisModel {
  String descripcion;
  String? imagenUrl;
  int empresa;
  int estacionTrabajo;
  String userName;

  CrearCroquisModel({
    required this.descripcion,
    this.imagenUrl,
    required this.empresa,
    required this.estacionTrabajo,
    required this.userName,
  });

  factory CrearCroquisModel.fromJson(String str) =>
      CrearCroquisModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CrearCroquisModel.fromMap(Map<String, dynamic> json) {
    return CrearCroquisModel(
      descripcion: json["descripcion"],
      imagenUrl: json["imagenUrl"],
      empresa: json["empresa"],
      estacionTrabajo: json["estacion_Trabajo"],
      userName: json["userName"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "descripcion": descripcion,
      "imagenUrl": imagenUrl,
      "empresa": empresa,
      "estacion_Trabajo": estacionTrabajo,
      "userName": userName,
    };
  }
}

/////////////Modelo para actualizar
class ActualizarCroquisModel {
  int consecutivoInterno;
  String? descripcion;
  String? imagenUrl;
  String mUserName;

  ActualizarCroquisModel({
    required this.consecutivoInterno,
    this.descripcion,
    this.imagenUrl,
    required this.mUserName,
  });

  factory ActualizarCroquisModel.fromJson(String str) =>
      ActualizarCroquisModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ActualizarCroquisModel.fromMap(Map<String, dynamic> json) {
    return ActualizarCroquisModel(
      consecutivoInterno: json["consecutivo_Interno"],
      descripcion: json["descripcion"],
      imagenUrl: json["imagenUrl"],
      mUserName: json["mUserName"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "consecutivo_Interno": consecutivoInterno,
      "descripcion": descripcion,
      "imagenUrl": imagenUrl,
      "mUserName": mUserName,
    };
  }
}
