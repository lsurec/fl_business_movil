import 'package:fl_business/displays/prc_documento_3/view_models/document_view_model.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/report/reports/factura/tmu.dart';
import 'package:flutter/material.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:provider/provider.dart';

class DetailsDocViewModel extends ChangeNotifier {
  //control del proceso
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //Mostrar boton para imprimir
  bool _showBlock = false;
  bool get showBlock => _showBlock;

  set showBlock(bool value) {
    _showBlock = value;
    notifyListeners();
  }

  //Navgar a pantalla de impresion
  Future<void> navigatePrint(BuildContext context, DetailDocModel doc) async {
    final DocumentoViewModel docsVm = Provider.of<DocumentoViewModel>(
      context,
      listen: false,
    );

    final DocumentViewModel docVm = Provider.of<DocumentViewModel>(
      context,
      listen: false,
    );

    final FacturaProvider facturaProvider = FacturaProvider();

    final FacturaTMU facturaTMU = FacturaTMU();

    isLoading = true;

    //cragar datos del reporte
    bool loadData = await facturaProvider.loaData(context, doc.consecutivo);

    isLoading = false;
    if (!loadData) return;

    await facturaTMU.getReport(context);

    if (docVm.valueParametro(48)) {
      docsVm.backTabs(context);
    }
  }

  //Navgar a pantalla de impresion
  share(BuildContext context, DetailDocModel doc) async {
    final vmShare = Provider.of<ShareDocViewModel>(context, listen: false);
    final menuVM = Provider.of<MenuViewModel>(context, listen: false);

    isLoading = true;

    if (menuVM.documento == 20) {
      await vmShare.sheredDocCotiAlfayOmega(
        context,
        doc.consecutivo,
        doc.seller,
        doc.client,
        doc.total,
      );
      isLoading = false;
      return;
    } else {
      await vmShare.sheredDoc(context, doc.consecutivo, doc.seller, doc.client);
      isLoading = false;
      return;
    }
  }
}
