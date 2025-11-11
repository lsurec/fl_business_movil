import 'package:fl_business/displays/prc_documento_3/models/formato_comanda.dart';
import 'package:fl_business/displays/report/utils/pdf_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/displays/restaurant/view_models/order_view_model.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ErrorPrintViewModel extends ChangeNotifier {
  //manejar flujo del procesp
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  var printerManager = PrinterManager.instance;

  Future<void> printTCPIP(
    BuildContext context,
    ResComandaModel comanda,
    int indexOrder,
    List<ResComandaModel> comandas,
  ) async {
    isLoading = true;

    try {
      final bool isConnect = await printerManager.connect(
        type: PrinterType.network,
        model: TcpPrinterInput(ipAddress: comanda.comanda.ipAdress),
      );

      if (!isConnect) {
        isLoading = false;
        NotificationService.showSnackbar(
          "Impresora ${comanda.comanda.ipAdress} no disponible",
        );

        return;
      }

      final bool isSend = await printerManager.send(
        type: PrinterType.network,
        bytes: comanda.format,
      );

      if (!isSend) {
        await printerManager.disconnect(type: PrinterType.network);

        isLoading = false;
        NotificationService.showSnackbar(
          "No se pudieron enviar los datos a la impresora ${comanda.comanda.ipAdress}]",
        );
        return;
      }

      final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
        context,
        listen: false,
      );

      //marcar como comandados
      for (var traPend in vmOrder.orders[indexOrder].transacciones) {
        if (traPend.consecutivo == comanda.comanda.traConsecutivo) {
          traPend.processed = true;
        }
      }
      vmOrder.saveOrder();

      comanda.error = null;

      returnView(context, comandas);
    } catch (e) {
      isLoading = false;
      comanda.error = e.toString();
      NotificationService.showSnackbar("Algo salió mal, intenta de nuevo");
    }
  }

  Future<void> printBT(
    BuildContext context,
    ResComandaModel comanda,
    int indexOrder,
    List<ResComandaModel> comandas,
  ) async {
    final PrinterViewModel vmPrinter = Provider.of<PrinterViewModel>(
      context,
      listen: false,
    );

    final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    isLoading = true;

    final bool isPrint = await vmPrinter.printTMU(
      context,
      comanda.format,
      false,
    );

    isLoading = false;

    if (!isPrint) return;
    //marcar como comandados
    for (var traPend in vmOrder.orders[indexOrder].transacciones) {
      if (traPend.consecutivo == comanda.comanda.traConsecutivo) {
        traPend.processed = true;
      }
    }
    vmOrder.saveOrder();

    comanda.error = null;
    returnView(context, comandas);
  }

  Future<void> sharePDF(
    BuildContext context,
    ResComandaModel comanda,
    int indexOrder,
    List<ResComandaModel> comandas,
  ) async {
    final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    isLoading = true;

    final now = comanda.comanda.detalles[0].fechaHora;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          57 * PdfPageFormat.mm, // Ancho típico de ticket
          double.infinity, // Altura infinita
          marginAll: 10, // Márgenes
        ),
        // altura infinita para ticket
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(comanda.comanda.detalles[0].desUbicacion),
            pw.Text(
              "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'mesa')}: ${comanda.comanda.detalles[0].desMesa.toUpperCase()}",
            ),
            pw.Text(
              "${comanda.comanda.detalles[0].desSerieDocumento} - ${comanda.comanda.detalles[0].iDDocumentoRef}",
            ),
            pw.SizedBox(height: 10),

            ...comanda.comanda.detalles
                .map(
                  (tra) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("Cant. ${tra.cantidad}"),
                      pw.Text(
                        "${tra.desProducto} ${tra.observacion.isNotEmpty ? '(${tra.observacion})' : ''}",
                      ),
                      pw.Divider(),
                    ],
                  ),
                )
                .toList(),

            pw.SizedBox(height: 10),
            pw.Text(
              "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'atencion')}: ${comanda.comanda.detalles[0].userName.toUpperCase()}",
            ),
            pw.Text(
              "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}",
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),

            pw.Text("Powered By:"),
            pw.Text(Utilities.author.nombre),
            pw.Text(Utilities.author.website),
            pw.Text("Version: ${SplashViewModel.versionLocal}"),
          ],
        ),
      ),
    );

    final bool isShare = await PdfUtils.sharePdf(
      context,
      pdf,
      "comanda-${comanda.comanda.bodega}-$now",
    );

    isLoading = false;

    if (!isShare) return;

    for (var traPend in vmOrder.orders[indexOrder].transacciones) {
      if (traPend.consecutivo == comanda.comanda.traConsecutivo) {
        traPend.processed = true;
      }
    }

    vmOrder.saveOrder();

    comanda.error = null;
    returnView(context, comandas);
  }

  Future<void> printTCPIPAlll(
    BuildContext context,
    List<ResComandaModel> comandas,
    int indexOrder,
  ) async {
    final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    isLoading = true;

    for (var element in comandas) {
      if (element.error == null) {
        var printerManager = PrinterManager.instance;

        try {
          //TODO:Nueva metodología
          final bool isConnect = await printerManager.connect(
            type: PrinterType.network,
            model: TcpPrinterInput(ipAddress: element.comanda.ipAdress),
          );

          if (!isConnect) {
            // isLoading = false;
            element.error =
                "Impresora ${element.comanda.ipAdress} no disponible";

            continue;
          }

          final bool isSend = await printerManager.send(
            type: PrinterType.network,
            bytes: element.format,
          );

          if (!isSend) {
            await printerManager.disconnect(type: PrinterType.network);

            // isLoading = false;
            element.error =
                "No se pudieron enviar los datos a la impresora ${element.comanda.ipAdress}]";
            continue;
          }

          //marcar como comandados
          for (var traPend in vmOrder.orders[indexOrder].transacciones) {
            if (traPend.consecutivo == element.comanda.traConsecutivo) {
              traPend.processed = true;
            }
          }
          vmOrder.saveOrder();
        } catch (e) {
          element.error = e.toString();
        }
      }
    }

    isLoading = false;

    //TODO:verificar si las comandas fueron enviadas
    final List<ResComandaModel> errores = comandas
        .where((p) => p.error != null)
        .toList();

    returnView(context, comandas);
  }

  Future<void> printBTAlll(
    BuildContext context,
    List<ResComandaModel> comandas,
    int indexOrder,
  ) async {
    isLoading = true;

    final List<int> format = [];

    for (var element in comandas) {
      format.addAll(element.format);
    }

    final PrinterViewModel vmPrinter = Provider.of<PrinterViewModel>(
      context,
      listen: false,
    );

    final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    final bool isPrint = await vmPrinter.printTMU(context, format, false);

    isLoading = false;

    if (!isPrint) return;
    //marcar como comandados
    for (var comanda in comandas) {
      comanda.error = null;
    }

    for (var element in vmOrder.orders[indexOrder].transacciones) {
      element.processed = true;
    }

    vmOrder.saveOrder();

    returnView(context, comandas);
  }

  Future<void> sharePDFAlll(
    BuildContext context,
    List<ResComandaModel> comandas,
    int indexOrder,
  ) async {
    final OrderViewModel vmOrder = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    isLoading = true;

    final now = comandas[0].comanda.detalles[0].fechaHora;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          57 * PdfPageFormat.mm, // Ancho típico de ticket
          double.infinity, // Altura infinita
          marginAll: 10, // Márgenes
        ),
        // altura infinita para ticket
        build: (_) => pw.Column(
          children: [
            ...comandas
                .map(
                  (comanda) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(comanda.comanda.detalles[0].desUbicacion),
                      pw.Text(
                        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'mesa')}: ${comanda.comanda.detalles[0].desMesa.toUpperCase()}",
                      ),
                      pw.Text(
                        "${comanda.comanda.detalles[0].desSerieDocumento} - ${comanda.comanda.detalles[0].iDDocumentoRef}",
                      ),
                      pw.SizedBox(height: 10),

                      ...comanda.comanda.detalles
                          .map(
                            (tra) => pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text("Cant. ${tra.cantidad}"),
                                pw.Text(
                                  "${tra.desProducto} ${tra.observacion.isNotEmpty ? '(${tra.observacion})' : ''}",
                                ),
                                pw.Divider(),
                              ],
                            ),
                          )
                          .toList(),

                      pw.SizedBox(height: 10),
                      pw.Text(
                        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'atencion')}: ${comanda.comanda.detalles[0].userName.toUpperCase()}",
                      ),
                      pw.Text(
                        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}",
                      ),
                      pw.SizedBox(height: 20),
                      pw.Divider(),

                      pw.Text("Powered By:"),
                      pw.Text(Utilities.author.nombre),
                      pw.Text(Utilities.author.website),
                      pw.Text("Version: ${SplashViewModel.versionLocal}"),
                    ],
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );

    final bool isShare = await PdfUtils.sharePdf(context, pdf, "comanda-$now");

    isLoading = false;

    if (!isShare) return;
    //marcar como comandados
    for (var comanda in comandas) {
      comanda.error = null;
    }

    for (var element in vmOrder.orders[indexOrder].transacciones) {
      element.processed = true;
    }

    vmOrder.saveOrder();

    returnView(context, comandas);
  }

  returnView(BuildContext context, List<ResComandaModel> comandas) {
    final List<ResComandaModel> errores = comandas
        .where((p) => p.error != null)
        .toList();

    if (errores.isEmpty) {
      Navigator.pop(context);
    }
  }
}
