class Referencia {
  final int referencia;
  final String descripcion;
  final dynamic referenciaId; // Puede ser String o int
  final String fDesEstadoObjeto;

  Referencia({
    required this.referencia,
    required this.descripcion,
    required this.referenciaId,
    required this.fDesEstadoObjeto,
  });

  factory Referencia.fromJson(Map<String, dynamic> json) {
    return Referencia(
      referencia: json['referencia'],
      descripcion: json['descripcion'],
      referenciaId: json['referencia_Id'],
      fDesEstadoObjeto: json['fDes_Estado_Objeto'],
    );
  }

  get referencia_Id => null;

  Map<String, dynamic> toJson() {
    return {
      'referencia': referencia,
      'descripcion': descripcion,
      'referencia_Id': referenciaId,
      'fDes_Estado_Objeto': fDesEstadoObjeto,
    };
  }
}
