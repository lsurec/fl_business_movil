import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/libraries/app_data.dart' as AppData;
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/providers/logo_provider.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pdf_render_plus/pdf_render.dart' as render;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:diacritic/diacritic.dart';

import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

class TestTMU {
  Future<Uint8List> pdfPageToPng(Uint8List pdfBytes) async {
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
    image = trimBottom(image);

    return Uint8List.fromList(img.encodePng(image));
  }

  img.Image trimBottom(img.Image image) {
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

  final List<int> report = [];

  Future<bool> getReportBluetooth(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          200 * PdfPageFormat.mm,
          1000 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PDF DE PRUEBA',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text('Texto normal'),
              pw.Text('Texto con acentos: á é í ó ú ñ Ñ'),
              pw.Text('Símbolos: @ # % & * + - ='),
              pw.Text('Números: 1234567890'),

              pw.SizedBox(height: 20),

              pw.Container(
                width: 200,
                height: 50,
                color: PdfColors.grey300,
                alignment: pw.Alignment.center,
                child: pw.Text('Caja de prueba'),
              ),

              pw.SizedBox(height: 20),

              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Producto'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Cantidad'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Precio'),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Café'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('2'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Q20.00'),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              pw.Center(
                child: pw.Text(
                  'Fin de la prueba',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final pngBytes = await pdfPageToPng(pdfBytes);

    // final Uint8List pictureResize = await compressPicture(pngBytes);

    final pdfPng = img.decodeImage(pngBytes)!;

    final generator = Generator(
      AppData.paperSize[Preferences.paperSize],
      await CapabilityProfile.load(),
    );

    report.addAll(generator.image(pdfPng, align: PosAlign.center));

    return true;
  }

  Future<Uint8List> compressPicture(Uint8List original) async {
    return await FlutterImageCompress.compressWithList(
      original,
      quality:
          50, // Baja calidad para impresión auqnue en png no se nota tanto, pero reduce el tamaño del archivo
      format: CompressFormat.png,
    );
  }
  // Future<bool> getReportBluetooth(BuildContext context) async {
  //   try {
  //     final LoginViewModel vmLogin = Provider.of<LoginViewModel>(
  //       context,
  //       listen: false,
  //     );

  //     final LocalSettingsViewModel vmSettings =
  //         Provider.of<LocalSettingsViewModel>(context, listen: false);

  //     final generator = Generator(
  //       AppData.paperSize[Preferences.paperSize],
  //       await CapabilityProfile.load(),
  //     );

  //     PosStyles center = const PosStyles(align: PosAlign.center);
  //     PosStyles centerBold = const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     );

  //     report.clear();
  //     final TmuUtils utils = TmuUtils();
  //     report.addAll(generator.emptyLines(1));

  //     if (Provider.of<LogoProvider>(context, listen: false).logo != null) {
  //       final enterpriseLogo = await utils.getEnterpriseLogo(context);

  //       report.addAll(generator.image(enterpriseLogo, align: PosAlign.center));
  //     }
  //     final myLogo = await utils.getMyCompanyLogo();

  //     report.addAll(generator.hr());
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics("PRUEBA DE IMPRESIÓN"),
  //         styles: centerBold,
  //       ),
  //     );
  //     report.addAll(generator.hr());

  //     report.addAll(
  //       generator.text("Dispositivo: ${Preferences.printer!.name}"),
  //     );
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics("Dirección: ${Preferences.printer!.address}"),
  //       ),
  //     );
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics("Tamaño de papel: ${Preferences.paperSize} mm"),
  //       ),
  //     );
  //     report.addAll(generator.emptyLines(1));
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics("*** Conexión exitosa ***"),
  //         styles: center,
  //       ),
  //     );
  //     report.addAll(generator.emptyLines(1));
  //     report.addAll(generator.hr());
  //     report.addAll(generator.text("Usuario: ${vmLogin.user}"));
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics(
  //           "Empresa: ${vmSettings.selectedEmpresa!.empresaNombre}",
  //         ),
  //       ),
  //     );
  //     report.addAll(
  //       generator.text(
  //         removeDiacritics(
  //           "Estación: ${vmSettings.selectedEstacion!.descripcion}",
  //         ),
  //       ),
  //     );
  //     report.addAll(generator.text("Fecha: ${Utilities.getDateDDMMYYYY()}"));
  //     report.addAll(generator.text("Origen de datos: ${Preferences.urlApi}"));
  //     report.addAll(generator.hr()); // Línea horizontal
  //     report.addAll(generator.image(myLogo, align: PosAlign.center));
  //     report.addAll(generator.text("Powered by", styles: center));
  //     report.addAll(generator.text(Utilities.author.nombre, styles: center));
  //     report.addAll(generator.text(Utilities.author.website, styles: center));

  //     report.addAll(
  //       generator.text(
  //         removeDiacritics("Versión: ${SplashViewModel.versionLocal}"),
  //         styles: center,
  //       ),
  //     );

  //     if (!Preferences.paperCut) {
  //       report.addAll(generator.emptyLines(3));
  //     }

  //     if (Preferences.paperCut) {
  //       report.addAll(generator.cut());
  //     }

  //     return true;
  //   } catch (e) {
  //     final ApiResModel res = ApiResModel(
  //       succes: false,
  //       response: e.toString(),
  //       url: '',
  //       storeProcedure: '',
  //     );

  //     NotificationService.showErrorView(context, res);

  //     return false;
  //   }
  // }

  // Future<bool> getReportTCPIP(BuildContext context) async {
  //   try {
  //     final LoginViewModel vmLogin = Provider.of<LoginViewModel>(
  //       context,
  //       listen: false,
  //     );

  //     final LocalSettingsViewModel vmSettings =
  //         Provider.of<LocalSettingsViewModel>(context, listen: false);

  //     final TmuUtils utils = TmuUtils();

  //     final enterpriseLogo = await utils.getEnterpriseLogo(context);
  //     final myLogo = await utils.getMyCompanyLogo();

  //     final generator = Generator(
  //       AppData.paperSize[80],
  //       await CapabilityProfile.load(),
  //     );

  //     PosStyles center = const PosStyles(align: PosAlign.center);
  //     PosStyles centerBold = const PosStyles(
  //       align: PosAlign.center,
  //       bold: true,
  //     );

  //     report = [];

  //     report += generator.image(enterpriseLogo, align: PosAlign.center);

  //     report += generator.hr();
  //     report += generator.text(
  //       removeDiacritics("PRUEBA DE IMPRESIÓN"),
  //       styles: centerBold,
  //     );
  //     report += generator.hr();

  //     report += generator.text("IP: ");

  //     report += generator.emptyLines(1);
  //     report += generator.text(
  //       removeDiacritics("*** Conexión exitosa ***"),
  //       styles: center,
  //     );
  //     report += generator.emptyLines(1);
  //     report += generator.hr();
  //     report += generator.text("Usuario: ${vmLogin.user}");
  //     report += generator.text(
  //       removeDiacritics(
  //         "Empresa: ${vmSettings.selectedEmpresa!.empresaNombre}",
  //       ),
  //     );
  //     report += generator.text(
  //       removeDiacritics(
  //         "Estación: ${vmSettings.selectedEstacion!.descripcion}",
  //       ),
  //     );
  //     report += generator.text("Fecha: ${Utilities.getDateDDMMYYYY()}");
  //     report += generator.text("Origen de datos: ${Preferences.urlApi}");
  //     report += generator.hr(); // Línea horizontal
  //     report += generator.image(myLogo, align: PosAlign.center);
  //     report += generator.text("Powered by", styles: center);
  //     report += generator.text(Utilities.author.nombre, styles: center);
  //     report += generator.text(Utilities.author.website, styles: center);

  //     report += generator.text(
  //       removeDiacritics("Versión: ${SplashViewModel.versionLocal}"),
  //       styles: center,
  //     );

  //     report += generator.cut();

  //     return true;
  //   } catch (e) {
  //     final ApiResModel res = ApiResModel(
  //       succes: false,
  //       response: e.toString(),
  //       url: '',
  //       storeProcedure: '',
  //     );

  //     NotificationService.showErrorView(context, res);

  //     return false;
  //   }
  // }
}
