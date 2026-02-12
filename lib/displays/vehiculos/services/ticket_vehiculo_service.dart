import 'dart:typed_data';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart';
import 'package:fl_business/shared_preferences/preferences.dart';

class TicketVehiculoService {

  static Future<List<int>> generarTicket({
    required List<dynamic> items,
    Uint8List? firmaMecanico,
    Uint8List? firmaCliente,
  }) async {

    final profile = await CapabilityProfile.load();

    final generator = Generator(
      Preferences.paperSize == 80
          ? PaperSize.mm80
          : PaperSize.mm58,
      profile,
    );

    List<int> bytes = [];

    // ====== HEADER ======
    bytes += generator.text(
      'REPORTE DE VEHICULO',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();

    // ====== ITEMS ======
    for (final item in items) {

      bytes += generator.text(
        item.desProducto ?? '',
        styles: const PosStyles(bold: true),
      );

      bytes += generator.text(
        (item.detalle ?? '').isEmpty ? '-' : item.detalle,
      );

      bytes += generator.hr();
    }

    // ====== FIRMA MECANICO ======
    if (firmaMecanico != null) {
      bytes += generator.text(
        'Firma Mecanico',
        styles: const PosStyles(align: PosAlign.center),
      );

      final image = decodeImage(firmaMecanico);
      if (image != null) {
        bytes += generator.image(image);
      }

      bytes += generator.hr();
    }

    // ====== FIRMA CLIENTE ======
    if (firmaCliente != null) {
      bytes += generator.text(
        'Firma Cliente',
        styles: const PosStyles(align: PosAlign.center),
      );

      final image = decodeImage(firmaCliente);
      if (image != null) {
        bytes += generator.image(image);
      }
    }

    bytes += generator.feed(2);

    if (Preferences.paperCut) {
      bytes += generator.cut();
    }

    return bytes;
  }
}
