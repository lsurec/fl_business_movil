class Estado {
  final int estado;
  final String descripcion;

  Estado({required this.estado, required this.descripcion});

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      estado: json['estado'],
      descripcion: json['descripcion'],
    );
  }
}
