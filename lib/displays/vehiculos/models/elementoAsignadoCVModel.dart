import 'dart:convert';

class ElementoAsignadoModel {
  int elementoAsignado;
  String descripcion;
  String elementoId;
  int empresa;
  int raiz;
  int nivel;
  int elementoAsignadoPadre;
  int estado;
  DateTime fechaHora;
  String userName;
  String? colorDisponible;
  String? colorAbierto;
  int? objVertical;
  int? objHorizontal;
  int pagina;
  int orden;
  int objSecuencia;
  bool? opcDetalle; // ✅ nullable
  int? marca;
  DateTime? modeloFecha;
  int? seccion;
  int? cuentaCorrentista;
  String? color;
  String? placa;
  String? chasis;
  int? modelo;

  ElementoAsignadoModel({
    required this.elementoAsignado,
    required this.descripcion,
    required this.elementoId,
    required this.empresa,
    required this.raiz,
    required this.nivel,
    required this.elementoAsignadoPadre,
    required this.estado,
    required this.fechaHora,
    required this.userName,
    this.colorDisponible,
    this.colorAbierto,
    this.objVertical,
    this.objHorizontal,
    required this.pagina,
    required this.orden,
    required this.objSecuencia,
    this.opcDetalle, // ✅ ya no required
    this.marca,
    this.modeloFecha,
    this.seccion,
    this.cuentaCorrentista,
    this.color,
    this.placa,
    this.chasis,
    this.modelo,
  });

  factory ElementoAsignadoModel.fromJson(String str) =>
      ElementoAsignadoModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ElementoAsignadoModel.fromMap(Map<String, dynamic> json) =>
      ElementoAsignadoModel(
        elementoAsignado: json["elemento_Asignado"],
        descripcion: json["descripcion"],
        elementoId: json["elemento_Id"],
        empresa: json["empresa"],
        raiz: json["raiz"],
        nivel: json["nivel"],
        elementoAsignadoPadre: json["elemento_Asignado_Padre"],
        estado: json["estado"],
        fechaHora: DateTime.parse(json["fecha_Hora"]),
        userName: json["userName"],
        colorDisponible: json["color_Disponible"],
        colorAbierto: json["color_Abierto"],
        objVertical: json["obj_Vertical"],
        objHorizontal: json["obj_Horizontal"],
        pagina: json["pagina"],
        orden: json["orden"],
        objSecuencia: json["obj_Secuencia"],
        opcDetalle: json["opc_Detalle"] as bool?, // ✅ CLAVE
        marca: json["marca"],
        modeloFecha: json["modelo_Fecha"] == null
            ? null
            : DateTime.parse(json["modelo_Fecha"]),
        seccion: json["seccion"],
        cuentaCorrentista: json["cuenta_Correntista"],
        color: json["color"]?.toString(),
        placa: json["placa"]?.toString(),
        chasis: json["chasis"]?.toString(),
        modelo: json["modelo"],
      );

  Map<String, dynamic> toMap() => {
        "elemento_Asignado": elementoAsignado,
        "descripcion": descripcion,
        "elemento_Id": elementoId,
        "empresa": empresa,
        "raiz": raiz,
        "nivel": nivel,
        "elemento_Asignado_Padre": elementoAsignadoPadre,
        "estado": estado,
        "fecha_Hora": fechaHora.toIso8601String(),
        "userName": userName,
        "color_Disponible": colorDisponible,
        "color_Abierto": colorAbierto,
        "obj_Vertical": objVertical,
        "obj_Horizontal": objHorizontal,
        "pagina": pagina,
        "orden": orden,
        "obj_Secuencia": objSecuencia,
        "opc_Detalle": opcDetalle,
        "marca": marca,
        "modelo_Fecha": modeloFecha?.toIso8601String(),
        "seccion": seccion,
        "cuenta_Correntista": cuentaCorrentista,
      };
}
