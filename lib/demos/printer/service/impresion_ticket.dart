import 'dart:typed_data';
import 'package:fl_business/demos/printer/models/estado_cuenta.dart';
import 'package:fl_business/demos/printer/utils/ticket_utils.dart';
import 'package:fl_business/demos/printer/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class ImpresionTicket {
  /// Método estático para imprimir directamente en ticket
  static Future<void> imprimirTicket({
    required BuildContext context,
    required List<EstadoCuenta> movimientos,
  }) async {
    final TicketUtils ticketUtils = TicketUtils();
    final UtilitiesService utils = UtilitiesService();
    final bluetooth = ticketUtils.bluetooth;

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

    // Cargar e imprimir logo automáticamente
    bluetooth.printNewLine();

    //Con este codigo se agregaría el logo:
    final Uint8List? logoBytesEmp = await UtilitiesService.loadLogoImage(
      '', //path completo generado con el campo de la empresa seleccionada
    );
    if (logoBytesEmp != null) {
      final Uint8List? imagenReducida = await utils.prepararImagenParaImpresion(
        logoBytesEmp,
      );
      if (imagenReducida != null) {
        await bluetooth.printImageBytes(imagenReducida);
      }
    }

    bluetooth.printNewLine();

    // Imprimir encabezado (empresa, NIT, dirección) de la empresa seleccionada
    await ticketUtils.imprimirTexto('ILGUA', size: 2, align: 1);
    await ticketUtils.imprimirTexto('NIT: 15613-7', size: 1, align: 1);
    await ticketUtils.imprimirTexto('Zona 14-7', size: 1, align: 1);
    bluetooth.printNewLine();

    // Imprimir cada movimiento
    for (final m in movimientos) {
      await ticketUtils.imprimirTexto('Fecha: ${m.fecha}');
      await ticketUtils.imprimirTexto('Detalle: ${m.detalle}');
      await ticketUtils.imprimirTexto(
        'Débito: ${m.debito.toStringAsFixed(2)}  Crédito: ${m.credito.toStringAsFixed(2)}',
      );
      await ticketUtils.imprimirTexto('Saldo: ${m.saldo.toStringAsFixed(2)}');
      await ticketUtils.imprimirTexto(
        'Documento: ${m.documento}  Tipo: ${m.tipo}',
      );
      await ticketUtils.imprimirTexto('Referencia: ${m.referencia}');
      bluetooth.printNewLine();
    }
    await ticketUtils.imprimirTexto(
      'Generado por: ${UtilitiesService.nombreEmpresa}',
      size: 0,
      align: 1,
    );
    await ticketUtils.imprimirTexto(
      '${UtilitiesService.version}',
      size: 0,
      align: 1,
    );

    // Línea final y desconexión
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    await ticketUtils.desconectarSiConectado();
  }
}
