class TipoTarea {
  final int tipoTarea;
  final String descripcion;
  final bool documento;
  final dynamic descripcionAlterna;

  TipoTarea({
    required this.tipoTarea,
    required this.descripcion,
    required this.documento,
    this.descripcionAlterna,
  });

  factory TipoTarea.fromJson(Map<String, dynamic> json) {
    return TipoTarea(
      tipoTarea: json['tipo_Tarea'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      documento: json['documento'] ?? false,
      descripcionAlterna: json['descripcion_alterna'],
    );
  }
}