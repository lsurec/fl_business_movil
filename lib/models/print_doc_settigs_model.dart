import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/models.dart';
import 'package:fl_business/displays/report/models/models.dart';

class PrintDocSettingsModel {
  int opcion;
  DocDestinationModel? destination;
  int? consecutivoDoc;
  ReportModel? report;

  PrintDocSettingsModel({
    required this.opcion,
    this.consecutivoDoc,
    this.destination,
    this.report,
  });
}
