class ReportUnidadesVendidasModel {
  String bodega;
  int idBodega;
  List<ProductReportUnidadesVendidas> products;
  double total;
  String storeProcedure;

  ReportUnidadesVendidasModel({
    required this.bodega,
    required this.idBodega,
    required this.products,
    required this.total,
    required this.storeProcedure,
  });
}

class ProductReportUnidadesVendidas {
  String id;
  String desc;
  double unidades;

  ProductReportUnidadesVendidas({
    required this.id,
    required this.desc,
    required this.unidades,
  });
}
