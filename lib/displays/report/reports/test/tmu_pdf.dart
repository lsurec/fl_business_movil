import 'dart:typed_data';

import 'package:fl_business/displays/report/utils/tmu_pdf_utils.dart';
import 'package:fl_business/displays/shr_local_config/models/empresa_model.dart';
import 'package:fl_business/displays/shr_local_config/models/estacion_model.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/services/picture_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:fl_business/libraries/app_data.dart' as AppData;

class TestTmuPdf {
  final List<int> report = [];

  Future<bool> getReport(BuildContext context) async {
    final LocalSettingsViewModel empresaVm =
        Provider.of<LocalSettingsViewModel>(context, listen: false);

    final LoginViewModel loginVm = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    final EmpresaModel empresaSession = empresaVm.selectedEmpresa!;
    final EstacionModel selectedEstacion = empresaVm.selectedEstacion!;

    PictureService pictureService = PictureService();

    final ByteData logoEmpresa = await pictureService.getLogo(
      empresaSession.absolutePathPicture,
    );

    final ByteData imgDemo = await rootBundle.load('assets/logo_demosoft.png');

    Uint8List logoData = (logoEmpresa).buffer.asUint8List();
    Uint8List logoDemo = (imgDemo).buffer.asUint8List();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: TmuPdfUtils.formatoTicket,
        build: (contextP) {
          final anchoPagina = contextP.page.pageFormat.availableWidth;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              TmuPdfUtils.picture(anchoPagina, logoData),
              TmuPdfUtils.hr,
              TmuPdfUtils.title("PRUEBA DE IMPRESIÓN"),
              TmuPdfUtils.hr,
              TmuPdfUtils.text("Dispositivo: ${Preferences.printer!.name}"),
              TmuPdfUtils.text("Dirección: ${Preferences.printer!.address}"),
              TmuPdfUtils.text("Tamaño de papel: ${Preferences.paperSize} mm"),
              TmuPdfUtils.emptyLines(1),
              TmuPdfUtils.text("*** Conexión exitosa ***"),
              TmuPdfUtils.emptyLines(1),
              TmuPdfUtils.text("Usuario: ${loginVm.user}"),
              TmuPdfUtils.text("Empresa: ${empresaSession.empresaNombre}"),
              TmuPdfUtils.text("Estación: ${selectedEstacion.descripcion}"),
              TmuPdfUtils.text("Fecha: ${Utilities.getDateDDMMYYYY()}"),
              TmuPdfUtils.text("Origen de datos: ${Preferences.urlApi}"),
              TmuPdfUtils.hr,
              TmuPdfUtils.picture(anchoPagina, logoDemo),
              TmuPdfUtils.text("Powered by"),
              TmuPdfUtils.text(Utilities.author.nombre),
              TmuPdfUtils.text(Utilities.author.website),
              TmuPdfUtils.text("Versión: ${SplashViewModel.versionLocal}"),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final pngBytes = await TmuPdfUtils.pdfPageToPng(pdfBytes);

    final pdfPng = img.decodeImage(pngBytes)!;

    final generator = Generator(
      AppData.paperSize[Preferences.paperSize],
      await CapabilityProfile.load(),
    );

    report.addAll(generator.image(pdfPng, align: PosAlign.center));

    if (!Preferences.paperCut) {
      report.addAll(generator.emptyLines(3));
    } else {
      report.addAll(generator.cut());
    }

    return true;
  }
}
