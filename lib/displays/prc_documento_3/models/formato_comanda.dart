import 'package:fl_business/displays/prc_documento_3/models/models.dart';

class FormatoComanda {
  int traConsecutivo;
  String bodega;
  String ipAdress;
  List<PrintDataComandaModel> detalles;

  FormatoComanda({
    required this.traConsecutivo,
    required this.bodega,
    required this.detalles,
    required this.ipAdress,
  });
}

class ResComandaModel {
  FormatoComanda comanda;
  List<int> format;
  String? error;

  ResComandaModel({
    required this.comanda,
    required this.format,
    required this.error,
  });
}
