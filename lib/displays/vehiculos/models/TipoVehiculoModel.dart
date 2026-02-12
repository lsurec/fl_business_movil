class TipoVehiculoModel {
  final String? id;
  final String? descripcion;
  final bool? estado;
  final int? consecutivoInterno;
  final String? userName;
  final DateTime? fechaHora;
  final String? mUserName;
  final DateTime? mFechaHora;

  TipoVehiculoModel({
    this.id,
    this.descripcion,
    this.estado,
    this.consecutivoInterno,
    this.userName,
    this.fechaHora,
    this.mUserName,
    this.mFechaHora,
  });

  factory TipoVehiculoModel.fromJson(Map<String, dynamic> json) {
    return TipoVehiculoModel(
      id: json['id']?.toString(),
      descripcion: json['descripcion'],
      estado: json['estado'],
      consecutivoInterno: json['consecutivo_Interno'],
      userName: json['userName'],
      fechaHora: json['fecha_Hora'] != null
          ? DateTime.parse(json['fecha_Hora'])
          : null,
      mUserName: json['m_UserName'],
      mFechaHora: json['m_Fecha_Hora'] != null
          ? DateTime.parse(json['m_Fecha_Hora'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'estado': estado,
      'consecutivo_Interno': consecutivoInterno,
      'userName': userName,
      'fecha_Hora': fechaHora?.toIso8601String(),
      'm_UserName': mUserName,
      'm_Fecha_Hora': mFechaHora?.toIso8601String(),
    };
  }

  bool get activo => estado == true;

  // 🔥 CLAVE PARA DROPDOWN / LISTAS
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoVehiculoModel &&
          runtimeType == other.runtimeType &&
          id != null &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
