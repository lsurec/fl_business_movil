import 'dart:convert';

class ApiResponseModel {
  bool status;
  String message;
  String error;
  String storedProcedure;
  Map<String, dynamic>? parameters;
  dynamic data;
  DateTime timestamp;
  String version;
  DateTime? releaseDate;
  String? url;

  ApiResponseModel({
    required this.status,
    required this.message,
    required this.error,
    required this.storedProcedure,
    required this.parameters,
    required this.data,
    required this.timestamp,
    required this.version,
    this.releaseDate,
    this.url,
  });

  factory ApiResponseModel.fromJson(String str) =>
      ApiResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ApiResponseModel.fromMap(Map<String, dynamic> json) =>
      ApiResponseModel(
        status: json["status"],
        message: json["message"],
        error: json["error"],
        storedProcedure: json["storedProcedure"],
        parameters: json["parameters"],
        data: json["data"],
        timestamp: DateTime.parse(json["timestamp"]),
        version: json["version"],
        releaseDate: json["releaseDate"] != null
            ? DateTime.parse(json["releaseDate"])
            : null,
        url: json["url"],
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "message": message,
    "error": error,
    "storedProcedure": storedProcedure,
    "parameters": parameters,
    "data": data,
    "timestamp": timestamp.toIso8601String(),
    "version": version,
    "releaseDate": releaseDate?.toIso8601String(),
    "url": url,
  };
}
