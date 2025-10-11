import 'package:fl_business/displays/prc_documento_3/models/models.dart';

class DocumentoResumenModel {
  int consecutivo;
  GetDocModel item;
  DocEstructuraModel estructura;
  double subtotal;
  double cargo;
  double descuento;
  double total;

  DocumentoResumenModel({
    required this.consecutivo,
    required this.item,
    required this.estructura,
    required this.subtotal,
    required this.cargo,
    required this.descuento,
    required this.total,
  });
}
