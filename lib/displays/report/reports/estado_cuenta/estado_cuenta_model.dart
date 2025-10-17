import 'dart:convert';

class EstadoCuentaModel {
  String idDocumento;
  String tipoDocumento;
  String serieDocumento;
  String iDDocumentoRef;
  String comensal;
  int consecutivoInterno;
  DateTime fechaHora;
  String desUbicacion;
  String desMesa;
  String desSerieDocumento;
  String userName;
  String productoId;
  String unidadMedida;
  String desProducto;
  String bodega;
  double cantidad;
  int tipoTransaccion;
  int dConsecutivoInterno;

  EstadoCuentaModel({
    required this.idDocumento,
    required this.tipoDocumento,
    required this.serieDocumento,
    required this.iDDocumentoRef,
    required this.comensal,
    required this.consecutivoInterno,
    required this.fechaHora,
    required this.desUbicacion,
    required this.desMesa,
    required this.desSerieDocumento,
    required this.userName,
    required this.productoId,
    required this.unidadMedida,
    required this.desProducto,
    required this.bodega,
    required this.cantidad,
    required this.tipoTransaccion,
    required this.dConsecutivoInterno,
  });

  factory EstadoCuentaModel.fromJson(String str) =>
      EstadoCuentaModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EstadoCuentaModel.fromMap(Map<String, dynamic> json) =>
      EstadoCuentaModel(
        idDocumento: json["id_Documento"],
        tipoDocumento: json["tipo_Documento"],
        serieDocumento: json["serie_Documento"],
        iDDocumentoRef: json["iD_Documento_Ref"],
        comensal: json["comensal"],
        consecutivoInterno: json["consecutivo_Interno"],
        fechaHora: DateTime.parse(json["fecha_Hora"]),
        desUbicacion: json["des_Ubicacion"],
        desMesa: json["des_Mesa"],
        desSerieDocumento: json["des_Serie_Documento"],
        userName: json["userName"],
        productoId: json["producto_Id"],
        unidadMedida: json["unidad_Medida"],
        desProducto: json["des_Producto"],
        bodega: json["bodega"],
        cantidad: json["cantidad"],
        tipoTransaccion: json["tipo_Transaccion"],
        dConsecutivoInterno: json["d_Consecutivo_Interno"],
      );

  Map<String, dynamic> toMap() => {
    "id_Documento": idDocumento,
    "tipo_Documento": tipoDocumento,
    "serie_Documento": serieDocumento,
    "iD_Documento_Ref": iDDocumentoRef,
    "comensal": comensal,
    "consecutivo_Interno": consecutivoInterno,
    "fecha_Hora": fechaHora.toIso8601String(),
    "des_Ubicacion": desUbicacion,
    "des_Mesa": desMesa,
    "des_Serie_Documento": desSerieDocumento,
    "userName": userName,
    "producto_Id": productoId,
    "unidad_Medida": unidadMedida,
    "des_Producto": desProducto,
    "bodega": bodega,
    "cantidad": cantidad,
    "tipo_Transaccion": tipoTransaccion,
    "d_Consecutivo_Interno": dConsecutivoInterno,
  };
}
