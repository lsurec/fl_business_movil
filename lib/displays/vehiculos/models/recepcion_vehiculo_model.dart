class RecepcionVehiculoModel {
  final String nit;
  final String nombre;
  final String direccion;
  final String celular;
  final String email;

  final String placa;
  final String chasis;
  final String marca;
  final String modelo;
  final int anio;
  final String color;

  final String fechaRecibido;
  final String fechaSalida;

  final String detalleTrabajo;
  final String kilometraje;
  final String cc;
  final String cil;

  RecepcionVehiculoModel({
    required this.nit,
    required this.nombre,
    required this.direccion,
    required this.celular,
    required this.email,
    required this.placa,
    required this.chasis,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.color,
    required this.fechaRecibido,
    required this.fechaSalida,
    required this.detalleTrabajo,
    required this.kilometraje,
    required this.cc,
    required this.cil,
  });

  Map<String, dynamic> toJson() {
    return {
      'nit': nit,
      'nombre': nombre,
      'direccion': direccion,
      'celular': celular,
      'email': email,
      'placa': placa,
      'chasis': chasis,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'color': color,
      'fechaRecibido': fechaRecibido,
      'fechaSalida': fechaSalida,
      'detalleTrabajo': detalleTrabajo,
      'kilometraje': kilometraje,
      'cc': cc,
      'cil': cil,
    };
  }

  factory RecepcionVehiculoModel.fromJson(Map<String, dynamic> json) {
    return RecepcionVehiculoModel(
      nit: json['nit'] ?? '',
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
      placa: json['placa'] ?? '',
      chasis: json['chasis'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'] ?? 0,
      color: json['color'] ?? '',
      fechaRecibido: json['fechaRecibido'] ?? '',
      fechaSalida: json['fechaSalida'] ?? '',
      detalleTrabajo: json['detalleTrabajo'] ?? '',
      kilometraje: json['kilometraje'] ?? '',
      cc: json['cc'] ?? '',
      cil: json['cil'] ?? '',
    );
  }
}
