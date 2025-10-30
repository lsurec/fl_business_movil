import 'dart:io';

import 'package:fl_business/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:share_plus/share_plus.dart';

class PdfUtils {
  static Future<bool> sharePdf(
    BuildContext context,
    Document pdf,
    String name,
  ) async {
    //Crear y guardar el pdf
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$name-${DateTime.now().toString()}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    /// Crear los parámetros de compartición
    final params = ShareParams(text: name, files: [XFile(filePath)]);

    // Compartir y capturar el resultado
    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.dismissed) {
      NotificationService.showSnackbar("Acción cancelada");
      return false;
    } else if (result.status == ShareResultStatus.success) {
      NotificationService.showSnackbar("Documento compartido");
      return true;
    } else {
      NotificationService.showSnackbar("No se pudo completar la acción");
      return false;
    }
  }
}
