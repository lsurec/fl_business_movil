//Modelo simulando datos de reporte
class EstadoCuenta {
  final String fecha;
  final String detalle;
  final double debito;
  final double credito;
  final double saldo;
  final String documento;
  final String tipo;
  final String referencia;

  EstadoCuenta({
    required this.fecha,
    required this.detalle,
    required this.debito,
    required this.credito,
    required this.saldo,
    required this.documento,
    required this.tipo,
    required this.referencia,
  });
}
