class CatalogoVehiculosModel {
  final String descripcion;
  final String elementoId;
  final int empresa;
  final int marca;
  final int modelo;
  final String? modeloFecha;
  final String motor;
  final String chasis;
  final String color;
  final String placa;
  final String centimetrosCubicos;
  final String cilindros;
  final String userName;

  CatalogoVehiculosModel({
    required this.descripcion,
    required this.elementoId,
    required this.empresa,
    required this.marca,
    required this.modelo,
    required this.modeloFecha,
    required this.motor,
    required this.chasis,
    required this.color,
    required this.placa,
    required this.centimetrosCubicos,
    required this.cilindros,
    required this.userName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'descripcion': descripcion,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'motor': motor,
      'chasis': chasis,
      'color': color,
      'centimetrosCubicos': centimetrosCubicos,
      'cilindros': cilindros,
      'empresa': empresa,
      'userName': userName,
    };

    if (modeloFecha != null) {
      data['modelo_Fecha'] = modeloFecha;
    }

    return data;
  }
}
