class ErrorModel {
  ErrorModel({
    required this.date,
    required this.description,
    this.url,
    required this.storeProcedure,
    this.docEstructura,
  });

  DateTime date;
  String description;
  String? url;
  String? storeProcedure;
  String? docEstructura;
}
