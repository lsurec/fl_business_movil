import 'dart:typed_data';
import 'package:fl_business/models/estado_cuenta.dart';
import 'package:fl_business/utils/ticket_utils.dart';
import 'package:fl_business/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class ImpresionTicket {
  /// Método estático para imprimir directamente en ticket
  static Future<void> imprimirTicket({
    required BuildContext context,
    required List<EstadoCuenta> movimientos,
  }) async {
    try {
      final TicketUtils ticketUtils = TicketUtils();
      final UtilitiesService utils = UtilitiesService();
      final bluetooth = ticketUtils.bluetooth;

      await ticketUtils.desconectarSiConectado();

      // Verificar Bluetooth
      if (!await ticketUtils.verificarBluetoothDisponible(context)) return;

      // Seleccionar impresora
      BluetoothDevice? impresora = await ticketUtils.seleccionarImpresora(
        context,
      );
      if (impresora == null) return;

      // Conectar impresora
      bool conectado = await ticketUtils.conectarImpresora(context, impresora);
      if (!conectado) return;

      List<int> bytes = [];

      final generator = Generator(
        PaperSize.mm58,
        await CapabilityProfile.load(),
      );

      bytes += generator.setGlobalCodeTable('CP1252');

      bytes += generator.text(
        "Prueba",
        styles: PosStyles(
          align: PosAlign.center,
          width: PosTextSize.size1,
          height: PosTextSize.size1,
        ),
      );

      bytes += generator.hr();

      bytes += generator.text(
        "CENTRADO",
        styles: PosStyles(align: PosAlign.center),
      );

      bytes += generator.text(
        "IZQUIERDA",
        styles: PosStyles(align: PosAlign.left),
      );

      bytes += generator.text(
        "DERECHA",
        styles: PosStyles(align: PosAlign.right),
      );

      bytes += generator.text("normal", styles: PosStyles(bold: false));

      bytes += generator.text("Bool", styles: PosStyles(bold: true));

      // Envíalo a la impresora
      await bluetooth.writeBytes(Uint8List.fromList(bytes));

      await ticketUtils.desconectarSiConectado();
    } catch (e) {
      print(e.toString());
    }
  }
}
