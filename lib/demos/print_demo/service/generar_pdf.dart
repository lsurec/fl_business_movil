import 'dart:typed_data';
import 'package:fl_business/demos/print_demo/models/estado_cuenta.dart';
import 'package:fl_business/demos/print_demo/utils/pdf_utils.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class GenerarPdf {
  /// Genera el PDF usando PdfUtils y la lista de movimientos
  /// Ajusta tamaños de fuente y logos según el formato (A4 o ticket)
  static Future<Uint8List> generar({
    required List<EstadoCuenta> movimientos,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document();
    final isA4 = PdfUtils.esA4(format);

    // Fuente por defecto
    final font = await PdfGoogleFonts.openSansRegular();

    // Encabezado con ajuste según formato
    final encabezado = await PdfUtils.encabezadoPagina(
      font: font,
      nombreFontSize: isA4 ? 14 : 7,
      infoFontSize: isA4 ? 10 : 6,
    );

    final encabezadoTicket = await PdfUtils.encabezadoTicket(
      font: font,
      nombreFontSize: 7,
      infoFontSize: 6,
    );

    if (isA4) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: format,
          margin: const pw.EdgeInsets.all(10),
          build: (context) => [
            encabezado,
            pw.SizedBox(height: 20),
            PdfUtils.tablaResponsive(
              headers: [
                'Fecha',
                'Detalle',
                'Débito',
                'Crédito',
                'Saldo',
                'Documento',
                'Tipo',
                'Referencia',
              ],
              rows: movimientos.map((m) {
                return [
                  m.fecha,
                  m.detalle,
                  m.debito.toStringAsFixed(2),
                  m.credito.toStringAsFixed(2),
                  m.saldo.toStringAsFixed(2),
                  m.documento,
                  m.tipo,
                  m.referencia,
                ];
              }).toList(),
              font: font,
              fontSize: 10, // tamaño normal para A4
            ),
            pw.SizedBox(height: 10),
            pw.Divider(
              indent: 40,
              endIndent: 40,
              thickness: 1,
              height: 1,
              color: PdfColors.grey400,
            ),
            // Pie de página A4
            PdfUtils.piePaginaPdf(font: font, fontSize: 8),
          ],
        ),
      );
    } else {
      pdf.addPage(
        pw.Page(
          pageFormat: format, // altura infinita para ticket
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              encabezadoTicket,
              pw.SizedBox(height: 4), // menos espacio para ticket
              PdfUtils.detalleTicket<EstadoCuenta>(
                items: movimientos,
                font: font,
                fontSize: 6,
                campos: {
                  'Fecha': (m) => m.fecha,
                  'Detalle': (m) => m.detalle,
                  'Débito': (m) => m.debito.toStringAsFixed(2),
                  'Crédito': (m) => m.credito.toStringAsFixed(2),
                  'Saldo': (m) => m.saldo.toStringAsFixed(2),
                  'Documento': (m) => m.documento,
                  'Tipo': (m) => m.tipo,
                  'Referencia': (m) => m.referencia,
                },
              ),
              pw.SizedBox(height: 4),
              // Pie de página para ticket
              PdfUtils.piePaginaPdf(font: font, fontSize: 6),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
