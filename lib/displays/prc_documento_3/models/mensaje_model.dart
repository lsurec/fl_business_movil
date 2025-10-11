import 'dart:convert';

class MensajeModel {
    String? mensaje;
    bool resultado;

    MensajeModel({
        required this.mensaje,
        required this.resultado,
    });

    factory MensajeModel.fromJson(String str) => MensajeModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory MensajeModel.fromMap(Map<String, dynamic> json) => MensajeModel(
        mensaje: json["mensaje"],
        resultado: json["resultado"],
    );

    Map<String, dynamic> toMap() => {
        "mensaje": mensaje,
        "resultado": resultado,
    };
}