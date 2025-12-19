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
}
