class ReportStockModel {
  String bodega;
  int idBodega;
  List<ProductReportStockModel> products;
  double total;
  String storeProcedure;

  ReportStockModel({
    required this.bodega,
    required this.idBodega,
    required this.products,
    required this.total,
    required this.storeProcedure,
  });
}

class ProductReportStockModel {
  String id;
  String desc;
  double existencias;

  ProductReportStockModel({
    required this.id,
    required this.desc,
    required this.existencias,
  });
}
