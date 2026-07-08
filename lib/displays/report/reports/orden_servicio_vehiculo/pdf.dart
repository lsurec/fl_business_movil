import 'dart:io';
import 'dart:typed_data';

import 'package:fl_business/displays/prc_documento_3/models/detalle_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/encabezado_model.dart';
import 'package:fl_business/displays/report/reports/pdf/utilities_pdf.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/services/picture_service.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class DocumentoConversionPDF {
  // ================= PDF =================
  final DateTime fechaActual = DateTime.now();

  //// Aqui importamos el logo de la empresa
  ///
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
                margin: const pw.EdgeInsets.symmetric(horizontal: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    ...headersStart.map(
                      (text) =>
                          pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
                    ),
                  ],
                ),
              ),

              //  FIX AQUÍ
              pw.Image(image, width: 120, height: 65, fit: pw.BoxFit.contain),

              pw.Container(
                width: PdfPageFormat.letter.width * 0.20,
                child: pw.Column(
                  children: [
                    ...headersEnd.map(
                      (text) => pw.Text(
                        text,
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 5),
          pw.Divider(thickness: 1),
        ],
      ),
    );
  }

  Future<void> generarPdfPrueba(
    BuildContext context,
    dynamic docGlobal,
    EncabezadoModel encabezado,
    List<DetalleModel> detalles,
  ) async {
    try {
      final empresa = context.read<LocalSettingsViewModel>().selectedEmpresa!;

      final pictureService = PictureService();

      final ByteData logo = await pictureService.getLogo(
        empresa.absolutePathPicture,
      );
      final Uint8List rawBytes = logo.buffer.asUint8List(
        logo.offsetInBytes,
        logo.lengthInBytes,
      );
      final decodedImage = img.decodeImage(rawBytes);
      if (decodedImage == null) {
        throw Exception("No se pudo decodificar la imagen del logo");
      }
      final resized = img.copyResize(decodedImage, width: 300);

      final Uint8List logoBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: 90),
      );
      final pdf = pw.Document();

      final ByteData logoDemo = await rootBundle.load(
        'assets/logo_demosoft.png',
      );

      final user = Provider.of<LoginViewModel>(context, listen: false).user;

      final DateTime fechaActual = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.letter.copyWith(
            marginBottom: 40,
            marginLeft: 20,
            marginTop: 20,
            marginRight: 20,
          ),

          header: (_) => buildHeader(
            logoBytes,

            [
              encabezado.razonSocial ?? '',
              encabezado.empresaDireccion ?? '',
              encabezado.empresaNit ?? '',
              encabezado.empresaTelefono ?? '',
            ],

            [
              'Fecha: ${encabezado.docFechaDocumento ?? ''}',
              'Serie: ${encabezado.serieDocumento ?? ''}',
              'Documento: ${encabezado.idDocumento ?? ''}',
              // 'Documento: ${docGlobal.toJson()['Consecutivo_Interno']}',
              'Usuario: ${encabezado.userName ?? ''}',
            ],
          ),

          footer: (context) => UtilitiesPdf.buildFooter(
            logoDemo, //  ByteData original (NO logoBytes)
            context,
            ' ', //
          ),

          build: (_) => [
            pw.SizedBox(height: 20),

            // ================= CLIENTE =================
            pw.Text(
              'INFORMACION CLIENTE',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 5),

            _filaDoble(
              'Nombre',
              encabezado.ccFacturaNombre ?? '',
              'NIT',
              encabezado.ccFacturaNit ?? '',
            ),

            _filaDoble(
              'Teléfono',
              encabezado.ccTelefono ?? '',
              'Email',
              encabezado.ccEMail ?? '',
            ),

            _filaDoble(
              'Dirección',
              encabezado.ccFacturaDireccion ?? '',
              '',
              '',
            ),

            pw.SizedBox(height: 10),

            // ================= VEHICULO =================
            pw.Text(
              "INFORMACIÓN VEHÍCULO",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 5),

            _filaDoble(
              'Placa',
              docGlobal.docPlaca ?? '',
              'Marca',
              docGlobal.docMarca ?? '',
            ),

            _filaDoble(
              'Modelo',
              docGlobal.docModelo ?? '',
              'Año',
              docGlobal.docAnio ?? '',
            ),

            _filaDoble(
              'Color',
              docGlobal.docColor ?? '',
              'Chasis',
              docGlobal.docChasis ?? '',
            ),

            _filaDoble(
              'Kilometraje',
              docGlobal.docKilometraje ?? '',
              'CC',
              docGlobal.docCc ?? '',
            ),

            _filaDoble(
              'Cilindraje',
              docGlobal.docCil ?? '',
              'Gasolina',
              '${docGlobal.docNivelGasolina ?? ''}%',
            ),

            pw.SizedBox(height: 20),

            // ================= ITEMS =================
            pw.Center(
              child: pw.Text(
                "ITEMS VERIFICADOS",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(),

              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("OK"),
                    ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("SKU"),
                    ),

                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text("NOTA"),
                    ),
                  ],
                ),

                ...detalles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final detalle = entry.value;

                  final observacion = index < docGlobal.docTransaccion.length
                      ? docGlobal.docTransaccion[index].traObservacion ?? ''
                      : '';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          "X",
                          style: pw.TextStyle(color: PdfColors.green),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(detalle.desProducto ?? ''),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(observacion),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // ================= OBSERVACIONES =================
            pw.Text("Observación 1: ${docGlobal.docObservacion1 ?? ''}"),

            pw.Text("Observación 2: ${docGlobal.docObservacion2 ?? ''}"),

            pw.Text("Observación 3: ${docGlobal.docObservacion3 ?? ''}"),
          ],
        ),
      );

      final output = await getApplicationDocumentsDirectory();

      final file = File("${output.path}/OrdenTrabajo.pdf");

      await file.writeAsBytes(await pdf.save());
      await OpenFilex.open(file.path);

      print("PDF generado: ${file.path}");
    } catch (e) {
      print("Error PDF: $e");
    }
  }

  pw.Widget _filaDoble(
    String titulo1,
    String valor1,
    String titulo2,
    String valor2,
  ) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$titulo1: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.TextSpan(
                  text: valor1,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),

        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '$titulo2: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.TextSpan(
                  text: valor2,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
