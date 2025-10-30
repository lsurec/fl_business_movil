import 'dart:convert';

class EstadoCuentaModel {
  DateTime fechaDocumento;
  String? idDocumento;
  int tipoDocumento;
  String? desTipoDocumento;
  String? serieDocumento;
  String? desSerieDocumento;
  String? iDDocumentoRef;
  String? observacion1;
  int consecutivoInterno;
  DateTime fechaHora;
  String? desUbicacion;
  String? desMesa;
  String? cliente;
  String? nitCliente;
  String? direccionCliente;
  String? userName;
  String? productoId;
  String? unidadMedida;
  String? desProducto;
  int bodega;
  String? nomBodega;
  double cantidad;
  double monto;
  int tipoTransaccion;
  int dConsecutivoInterno;
  String? simbolo;
  int moneda;

  EstadoCuentaModel({
    required this.fechaDocumento,
    required this.idDocumento,
    required this.tipoDocumento,
    required this.desTipoDocumento,
    required this.serieDocumento,
    required this.desSerieDocumento,
    required this.iDDocumentoRef,
    required this.observacion1,
    required this.consecutivoInterno,
    required this.fechaHora,
    required this.desUbicacion,
    required this.desMesa,
    required this.cliente,
    required this.nitCliente,
    required this.direccionCliente,
    required this.userName,
    required this.productoId,
    required this.unidadMedida,
    required this.desProducto,
    required this.bodega,
    required this.nomBodega,
    required this.cantidad,
    required this.monto,
    required this.tipoTransaccion,
    required this.dConsecutivoInterno,
    required this.simbolo,
    required this.moneda,
  });

  factory EstadoCuentaModel.fromJson(String str) =>
      EstadoCuentaModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory EstadoCuentaModel.fromMap(Map<String, dynamic> json) =>
      EstadoCuentaModel(
        fechaDocumento: DateTime.parse(json["fecha_Documento"]),
        idDocumento: json["id_Documento"],
        tipoDocumento: json["tipo_Documento"],
        desTipoDocumento: json["des_Tipo_Documento"],
        serieDocumento: json["serie_Documento"],
        desSerieDocumento: json["des_Serie_Documento"],
        iDDocumentoRef: json["iD_Documento_Ref"],
        observacion1: json["observacion_1"],
        consecutivoInterno: json["consecutivo_Interno"],
        fechaHora: DateTime.parse(json["fecha_Hora"]),
        desUbicacion: json["des_Ubicacion"],
        desMesa: json["des_Mesa"],
        cliente: json["cliente"],
        nitCliente: json["nit_Cliente"],
        direccionCliente: json["direccion_Cliente"],
        userName: json["userName"],
        productoId: json["producto_Id"],
        unidadMedida: json["unidad_Medida"],
        desProducto: json["des_Producto"],
        bodega: json["bodega"],
        nomBodega: json["nom_Bodega"],
        cantidad: json["cantidad"],
        monto: json["monto"],
        tipoTransaccion: json["tipo_Transaccion"],
        dConsecutivoInterno: json["d_Consecutivo_Interno"],
        simbolo: json["simbolo"],
        moneda: json["moneda"],
      );

  Map<String, dynamic> toMap() => {
    "fecha_Documento": fechaDocumento.toIso8601String(),
    "id_Documento": idDocumento,
    "tipo_Documento": tipoDocumento,
    "des_Tipo_Documento": desTipoDocumento,
    "serie_Documento": serieDocumento,
    "des_Serie_Documento": desSerieDocumento,
    "iD_Documento_Ref": iDDocumentoRef,
    "observacion_1": observacion1,
    "consecutivo_Interno": consecutivoInterno,
    "fecha_Hora": fechaHora.toIso8601String(),
    "des_Ubicacion": desUbicacion,
    "des_Mesa": desMesa,
    "cliente": cliente,
    "nit_Cliente": nitCliente,
    "direccion_Cliente": direccionCliente,
    "userName": userName,
    "producto_Id": productoId,
    "unidad_Medida": unidadMedida,
    "des_Producto": desProducto,
    "bodega": bodega,
    "nom_Bodega": nomBodega,
    "cantidad": cantidad,
    "monto": monto,
    "tipo_Transaccion": tipoTransaccion,
    "d_Consecutivo_Interno": dConsecutivoInterno,
    "simbolo": simbolo,
    "moneda": moneda,
  };
}
