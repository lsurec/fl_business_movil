class CatalogoVehiculosModel {
  final String descripcion;
  final String elementoId;
  final int empresa;
  final int marca;
  final int model;
  final String? modeloFecha;
  final String motor;
  final String chasis;
  final int color;
  final String placa;
  final String centimetrosCubicos;
  final String cilindros;
  final String userName;
  // final int cuentaCorrentista;

  CatalogoVehiculosModel({
    required this.descripcion,
    required this.elementoId,
    required this.empresa,
    required this.marca,
    required this.model,
    required this.modeloFecha,
    required this.motor,
    required this.chasis,
    required this.color,
    required this.placa,
    required this.centimetrosCubicos,
    required this.cilindros,
    required this.userName,
    // required this.cuentaCorrentista,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'descripcion': descripcion,
      'placa': placa,
      'marca': marca,
      'modelo': model, //  nombre correcto y como int (perfecto)
      'motor': motor,
      'chasis': chasis,
      'color': color.toString(), //  obligatorio string
      'centimetrosCubicos': centimetrosCubicos,
      'cilindros': cilindros,
      'empresa': empresa,
      'userName': userName,
      // 'cuentaCorrentista': cuentaCorrentista,
    };

    if (modeloFecha != null) {
      data['modelo_Fecha'] = modeloFecha;
    }

    return data;
  }
}
