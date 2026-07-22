import 'dart:typed_data';

import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_render_plus/pdf_render.dart' as render;
import 'package:image/image.dart' as img;

class TmuPdfUtils {
  static Future<Uint8List> pdfPageToPng(Uint8List pdfBytes) async {
    final document = await render.PdfDocument.openData(pdfBytes);

    final page = await document.getPage(1);

    // Ancho recomendado para impresoras de 80 mm (203 dpi)
    const printerWidth = 576;

    final pageImage = await page.render(
      width: printerWidth,
      height: (page.height * printerWidth / page.width).round(),
    );

    var image = img.Image.fromBytes(
      width: pageImage.width,
      height: pageImage.height,
      bytes: pageImage.pixels.buffer,
      order: img.ChannelOrder.rgba,
    );

    // Elimina filas blancas al final
    image = _trimBottom(image);

    return Uint8List.fromList(img.encodePng(image));
  }

  static img.Image _trimBottom(img.Image image) {
    int lastRow = image.height - 1;

    for (int y = image.height - 1; y >= 0; y--) {
      bool isBlank = true;

      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        if (pixel.r < 250 || pixel.g < 250 || pixel.b < 250) {
          isBlank = false;
          lastRow = y;
          break;
        }
      }

      if (!isBlank) {
        break;
      }
    }

    return img.copyCrop(
      image,
      x: 0,
      y: 0,
      width: image.width,
      height: lastRow + 1,
    );
  }

  static PdfPageFormat get formatoTicket => PdfPageFormat(
    Preferences.paperSize * PdfPageFormat.mm,
    double.infinity, // altura dinámica según el contenido
    marginAll: 3 * PdfPageFormat.mm,
  );

  static pw.Widget emptyLines(int lines, {double lineHeight = 10}) =>
      pw.SizedBox(height: lines * lineHeight);

  static pw.Widget get hr => pw.Divider(
    thickness: 0.5,
    color: PdfColors.black, // opcional, por defecto ya es oscuro
    height: 10, // espacio vertical total que ocupa el divider (line + padding)
  );

  static pw.Widget title(String text, {bool bold = false}) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 8,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  );
  static pw.Widget text(String text, {bool bold = false}) => pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 7,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  );

  static pw.Widget picture(anchoPagina, Uint8List img) => pw.Container(
    width: anchoPagina * 0.4, // 50% del ancho imprimible
    child: pw.Image(pw.MemoryImage(img), fit: pw.BoxFit.contain),
  );
}
