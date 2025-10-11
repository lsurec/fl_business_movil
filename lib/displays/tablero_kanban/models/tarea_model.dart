class Tarea {
  final int id;
  final int iDTarea;
  final String usuarioCreador;
  final String? emailCreador;
  final String? usuarioResponsable; // nuevo campo
  final String descripcion;
  final DateTime fechaInicial;
  final DateTime fechaFinal;
  final int referencia;
  final String iDReferencia;
  final String descripcionReferencia;
  final String ultimoComentario;
  final DateTime? fechaUltimoComentario;
  final String usuarioUltimoComentario;
  final String tareaObservacion1;
  final DateTime tareaFechaIni;
  final DateTime tareaFechaFin;
  final int tipoTarea;
  final String descripcionTipoTarea;
  final int estadoObjeto;
  final String tareaEstado;
  final String usuarioTarea;
  final String backColor;
  final int nivelPrioridad;
  final String nomNivelPrioridad;
  final int registros;
  final bool filtroTodasTareas;
  final bool filtroMisTareas;
  final bool filtroMisResponsabilidades;
  final bool filtroMisInvitaciones;

  Tarea({
    required this.id,
    required this.iDTarea,
    required this.usuarioCreador,
    this.emailCreador,
    required this.usuarioResponsable,
    required this.descripcion,
    required this.fechaInicial,
    required this.fechaFinal,
    required this.referencia,
    required this.iDReferencia,
    required this.descripcionReferencia,
    required this.ultimoComentario,
    this.fechaUltimoComentario,
    required this.usuarioUltimoComentario,
    required this.tareaObservacion1,
    required this.tareaFechaIni,
    required this.tareaFechaFin,
    required this.tipoTarea,
    required this.descripcionTipoTarea,
    required this.estadoObjeto,
    required this.tareaEstado,
    required this.usuarioTarea,
    required this.backColor,
    required this.nivelPrioridad,
    required this.nomNivelPrioridad,
    required this.registros,
    required this.filtroTodasTareas,
    required this.filtroMisTareas,
    required this.filtroMisResponsabilidades,
    required this.filtroMisInvitaciones,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      iDTarea: json['iD_Tarea'],
      usuarioCreador: json['usuario_Creador'],
      emailCreador: json['email_Creador'],
      usuarioResponsable: json['usuario_Responsable'], // puede ser null
      descripcion: json['descripcion'],
      fechaInicial: DateTime.parse(json['fecha_Inicial']),
      fechaFinal: DateTime.parse(json['fecha_Final']),
      referencia: json['referencia'],
      iDReferencia: json['iD_Referencia'],
      descripcionReferencia: json['descripcion_Referencia'] ?? '',
      ultimoComentario: json['ultimo_Comentario'] ?? '',
      fechaUltimoComentario: json['fecha_Ultimo_Comentario'] != null
          ? DateTime.parse(json['fecha_Ultimo_Comentario'])
          : null,
      usuarioUltimoComentario: json['usuario_Ultimo_Comentario'] ?? '',
      tareaObservacion1: json['tarea_Observacion_1'] ?? '',
      tareaFechaIni: DateTime.parse(json['tarea_Fecha_Ini']),
      tareaFechaFin: DateTime.parse(json['tarea_Fecha_Fin']),
      tipoTarea: json['tipo_Tarea'],
      descripcionTipoTarea: json['descripcion_Tipo_Tarea'],
      estadoObjeto: json['estado_Objeto'],
      tareaEstado: json['tarea_Estado'],
      usuarioTarea: json['usuario_Tarea'],
      backColor: json['backColor'],
      nivelPrioridad: json['nivel_Prioridad'],
      nomNivelPrioridad: json['nom_Nivel_Prioridad'],
      registros: json['registros'],
      filtroTodasTareas: json['filtroTodasTareas'],
      filtroMisTareas: json['filtroMisTareas'],
      filtroMisResponsabilidades: json['filtroMisResponsabilidades'],
      filtroMisInvitaciones: json['filtroMisInvitaciones'],
    );
  }
}
