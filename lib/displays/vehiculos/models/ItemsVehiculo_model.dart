class ItemVehiculoApi {
  final int bodega;
  final int producto;
  final int unidadMedida;
  final int tipoPrecio;
  final int moneda;
  final double precioUnidad;
  final int tipoTarifa;

  final String idProducto;
  final String desProducto;
  final String desUnidadMedida;
  final int tipoProducto;
  final String nomBodega;

  ItemVehiculoApi({
    required this.bodega,
    required this.producto,
    required this.unidadMedida,
    required this.tipoPrecio,
    required this.moneda,
    required this.precioUnidad,
    required this.tipoTarifa,
    required this.idProducto,
    required this.desProducto,
    required this.desUnidadMedida,
    required this.tipoProducto,
    required this.nomBodega,
  });

  factory ItemVehiculoApi.fromJson(Map<String, dynamic> json) {
    return ItemVehiculoApi(
      bodega: json['bodega'] ?? 0,
      producto: json['producto'] ?? 0,
      unidadMedida: json['unidad_Medida'] ?? 0,
      tipoPrecio: json['tipo_Precio'] ?? 0,
      moneda: json['moneda'] ?? 0,
      precioUnidad: (json['precio_Unidad'] ?? 0).toDouble(),
      tipoTarifa: json['tipo_Tarifa'] ?? 0,
      idProducto: json['id_Producto']?.toString() ?? '',
      desProducto: json['des_Producto'] ?? '',
      desUnidadMedida: json['des_Unidad_Medida'] ?? '',
      tipoProducto: json['tipo_Producto'] ?? 0,
      nomBodega: json['nom_Bodega'] ?? '',
    );
  }
}
