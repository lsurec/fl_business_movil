class Prioridad {
  final int nivelPrioridad;
  final String id;
  final String nombre;
  final String descripcion;
  final String backColor;
  final bool defaultNP;

  Prioridad({
    required this.nivelPrioridad,
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.backColor,
    required this.defaultNP,
  });

  factory Prioridad.fromJson(Map<String, dynamic> json) {
    return Prioridad(
      nivelPrioridad: json['nivel_Prioridad'],
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      backColor: json['backColor'],
      defaultNP: json['default_NP'],
    );
  }
}
