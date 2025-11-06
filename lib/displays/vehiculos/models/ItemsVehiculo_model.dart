class ItemVehiculo {
  final int bodega;
  final int producto;
  final int unidadMedida;
  final int tipoPrecio;
  final int moneda;
  final double precioUnidad;
  final int tipoTarifa;
  final String idProducto;
  final String desProducto;

  ItemVehiculo({
    required this.bodega,
    required this.producto,
    required this.unidadMedida,
    required this.tipoPrecio,
    required this.moneda,
    required this.precioUnidad,
    required this.tipoTarifa,
    required this.idProducto,
    required this.desProducto,
  });

  factory ItemVehiculo.fromJson(Map<String, dynamic> json) {
    return ItemVehiculo(
      bodega: json['bodega'],
      producto: json['producto'],
      unidadMedida: json['unidad_Medida'],
      tipoPrecio: json['tipo_Precio'],
      moneda: json['moneda'],
      precioUnidad: (json['precio_Unidad'] as num).toDouble(),
      tipoTarifa: json['tipo_Tarifa'],
      idProducto: json['id_Producto'],
      desProducto: json['des_Producto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bodega': bodega,
      'producto': producto,
      'unidad_Medida': unidadMedida,
      'tipo_Precio': tipoPrecio,
      'moneda': moneda,
      'precio_Unidad': precioUnidad,
      'tipo_Tarifa': tipoTarifa,
      'id_Producto': idProducto,
      'des_Producto': desProducto,
    };
  }
}
