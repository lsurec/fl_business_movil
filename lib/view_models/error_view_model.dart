import 'package:fl_business/displays/report/reports/pdf/utilities_pdf.dart';
import 'package:fl_business/displays/report/utils/pdf_utils.dart';
import 'package:fl_business/services/picture_service.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

class ErrorViewModel extends ChangeNotifier {
  pw.Widget buildHeader(
    Uint8List logo,
    List<String> headersStart,
    List<String> headersEnd,
  ) {
    final image = pw.MemoryImage(logo);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                width: PdfPageFormat.letter.width * 0.20,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: headersStart
                      .map(
                        (e) =>
                            pw.Text(e, style: const pw.TextStyle(fontSize: 9)),
                      )
                      .toList(),
                ),
              ),

              pw.Image(image, width: 120, height: 65, fit: pw.BoxFit.contain),

              pw.Container(
                width: PdfPageFormat.letter.width * 0.20,
                child: pw.Column(
                  children: headersEnd
                      .map(
                        (e) => pw.Text(
                          e,
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 5),
          pw.Divider(),
        ],
      ),
    );
  }

  Future<void> createAndSavePDF(ErrorModel error, BuildContext contextP) async {
    final vmLogin = Provider.of<LoginViewModel>(contextP, listen: false);
    final vmLocal = Provider.of<LocalSettingsViewModel>(
      contextP,
      listen: false,
    );

    String jsonFormateado = error.docEstructura ?? '';

    try {
      final dynamic jsonObject = jsonDecode(jsonFormateado);

      const encoder = JsonEncoder.withIndent('  ');
      jsonFormateado = encoder.convert(jsonObject);
    } catch (e) {
      // Si no es JSON válido, usa el texto original
    }

    DateTime date = error.date;

    // final ByteData image = await rootBundle.load('assets/logo_demosoft.png');

    final pictureService = PictureService();
    if (vmLocal.selectedEmpresa == null) {
      throw Exception('No hay empresa seleccionada');
    }

    final ByteData logo = await pictureService.getLogo(
      vmLocal.selectedEmpresa!.absolutePathPicture,
    );
    // Uint8List logoData = (image).buffer.asUint8List();

    final Uint8List rawBytes = logo.buffer.asUint8List(
      logo.offsetInBytes,
      logo.lengthInBytes,
    );

    final decodedImage = img.decodeImage(rawBytes);

    if (decodedImage == null) {
      throw Exception("No se pudo decodificar el logo");
    }

    final resized = img.copyResize(decodedImage, width: 300);

    final Uint8List logoBytes = Uint8List.fromList(
      img.encodeJpg(resized, quality: 90),
    );

    final pdf = pw.Document();
    final ByteData logoDemo = await rootBundle.load('assets/logo_demosoft.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginBottom: 30,
          marginLeft: 20,
          marginTop: 20,
          marginRight: 20,
        ),
        header: (_) => buildHeader(
          logoBytes,
          [
            vmLocal.selectedEmpresa?.empresaNombre ?? '',
            vmLocal.selectedEmpresa?.empresaDireccion ?? '',
          ],
          [
            'Fecha: ${Utilities.formatearFechaHora(date)}',
            'Usuario: ${vmLogin.user}',
            'Versión: ${SplashViewModel.versionLocal}',
          ],
        ),
        footer: (context) => UtilitiesPdf.buildFooter(
          logoDemo, //  ByteData original (NO logoBytes)
          context,
          ' ', //
        ),
        build: (pw.Context context) => [
          // pw.Row(
          //   crossAxisAlignment: pw.CrossAxisAlignment.end,
          //   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          //   children: [
          //     pw.Column(
          //       crossAxisAlignment: pw.CrossAxisAlignment.start,
          //       children: [
          //         pw.Text(
          //           "DESARROLLO MODERNO DE SOFTWARE S.A",
          //           style: pw.TextStyle(
          //             color: PdfColor.fromHex("#1352F0"),
          //             fontWeight: pw.FontWeight.bold,
          //           ),
          //         ),
          //         pw.SizedBox(height: 5),
          //         pw.Text(
          //           "${AppLocalizations.of(contextP)!.translate(BlockTranslate.fecha, "fecha")} - ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}",
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          //         ),
          //       ],
          //     ),
          //     pw.Column(
          //       crossAxisAlignment: pw.CrossAxisAlignment.end,
          //       children: [
          //         // pw.Container(
          //         //   height: 65,
          //         //   child: pw.Image(pw.MemoryImage(logoData)),
          //         // ),
          //         pw.SizedBox(height: 5),
          //         pw.Text(
          //           "${AppLocalizations.of(contextP)!.translate(BlockTranslate.general, "usuario")}: ${vmLogin.user}",
          //           style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          //         ),
          //       ],
          //     ),
          //   ],
          // ),
          pw.SizedBox(height: 20),
          pw.Text(
            AppLocalizations.of(
              contextP,
            )!.translate(BlockTranslate.localConfig, "configuracion"),
            style: pw.TextStyle(
              color: PdfColor.fromHex("#CF113C"),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: PdfColor.fromHex("#1352F0")),
          pw.Text(
            AppLocalizations.of(
              contextP,
            )!.translate(BlockTranslate.localConfig, "empresa"),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            "${vmLocal.selectedEmpresa?.empresaNombre ?? AppLocalizations.of(contextP)!.translate(BlockTranslate.error, "noDisponible")} (${vmLocal.selectedEmpresa?.empresa ?? AppLocalizations.of(contextP)!.translate(BlockTranslate.error, "noDisponible")})",
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            AppLocalizations.of(
              contextP,
            )!.translate(BlockTranslate.localConfig, "estaciones"),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            "${vmLocal.selectedEstacion?.descripcion ?? AppLocalizations.of(contextP)!.translate(BlockTranslate.error, "noDisponible")} (${vmLocal.selectedEstacion?.estacionTrabajo ?? AppLocalizations.of(contextP)!.translate(BlockTranslate.error, "noDisponible")})",
          ),
          // pw.SizedBox(height: 20),
          // pw.Text(
          //   "Documento",
          //   style: pw.TextStyle(
          //     color: PdfColor.fromHex("#CF113C"),
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          // pw.Divider(color: PdfColor.fromHex("#1352F0")),
          // pw.Text(
          //   "Documento:",
          //   style: pw.TextStyle(
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          // pw.Text(
          //   "46612",
          // ),
          // pw.SizedBox(height: 5),
          // pw.Text(
          //   "Serie:",
          //   style: pw.TextStyle(
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          // pw.Text(
          //   "FEL64",
          // ),
          pw.SizedBox(height: 20),
          pw.Text(
            AppLocalizations.of(
              contextP,
            )!.translate(BlockTranslate.error, "errorDesc"),
            style: pw.TextStyle(
              color: PdfColor.fromHex("#CF113C"),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(color: PdfColor.fromHex("#1352F0")),
          if (error.url != null) ...[
            pw.Text('URL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(error.url!),
            pw.SizedBox(height: 5),
          ],

          if (error.storeProcedure != null) ...[
            pw.Text(
              'Store Procedure',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(error.storeProcedure!),
            pw.SizedBox(height: 5),
          ],
          pw.SizedBox(height: 5),

          pw.Divider(color: PdfColor.fromHex("#1352F0")),

          ..._buildLargeText(error.description),
          if (error.docEstructura != null &&
              error.docEstructura!.isNotEmpty) ...[
            pw.SizedBox(height: 15),

            pw.Text(
              'JSON enviado',
              style: pw.TextStyle(
                color: PdfColor.fromHex("#CF113C"),
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.Divider(color: PdfColor.fromHex("#1352F0")),

            ..._buildLargeText(jsonFormateado),

            pw.SizedBox(height: 10),
          ],

          pw.SizedBox(height: 5),
          pw.SizedBox(height: 5),
          pw.Text(
            'Versión: ${SplashViewModel.versionLocal}',
            textAlign: pw.TextAlign.justify,
          ),
        ],
      ),
    );

    await PdfUtils.sharePdf(contextP, pdf, "Error");
  }

  List<pw.Widget> _buildLargeText(String text) {
    const int chunkSize = 500;

    final widgets = <pw.Widget>[];

    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;

      widgets.add(
        pw.Text(text.substring(i, end), style: const pw.TextStyle(fontSize: 9)),
      );
    }

    return widgets;
  }
}
