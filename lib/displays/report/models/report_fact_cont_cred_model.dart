class ReportFactContCredModel {
  String bodega;
  int idBodega;
  List<DocReportModel> docs;
  DateTime startDate;
  DateTime endDate;
  double totalContado;
  double totalCredito;
  double totalContCred;
  String storeProcedure;

  ReportFactContCredModel({
    required this.bodega,
    required this.idBodega,
    required this.docs,
    required this.startDate,
    required this.endDate,
    required this.totalContado,
    required this.totalCredito,
    required this.totalContCred,
    required this.storeProcedure,
  });
}

class DocReportModel {
  String id;
  double monto;
  String tipo;

  DocReportModel({
    required this.id,
    required this.tipo,
    required this.monto,
  });
}
