import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fl_business/demo_printer/pdf_utils.dart';
import 'package:fl_business/demo_printer/ticket_utils.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class HomePrinterViewModel extends ChangeNotifier {
  PdfPageFormat? formatoSeleccionado; // Guarda el formato actual de la página

  Future<void> imprimirTicket({required BuildContext context}) async {
    final TicketUtils ticketUtils = TicketUtils();
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
    // final Uint8List? logoBytesEmp = await UtilitiesService.loadLogoImage(
    //   '', //path completo generado con el campo de la empresa seleccionada
    // );
    // if (logoBytesEmp != null) {
    //   final Uint8List? imagenReducida = await utils.prepararImagenParaImpresion(
    //     logoBytesEmp,
    //   );
    //   if (imagenReducida != null) {
    //     await bluetooth.printImageBytes(imagenReducida);
    //   }
    // }

    bluetooth.printNewLine();

    // Imprimir encabezado (empresa, NIT, dirección) de la empresa seleccionada
    await ticketUtils.imprimirTexto('ILGUA', size: 2, align: 1);
    await ticketUtils.imprimirTexto('NIT: 15613-7', size: 1, align: 1);
    await ticketUtils.imprimirTexto('Zona 14-7', size: 1, align: 1);
    bluetooth.printNewLine();

    // Imprimir cada movimiento
    await ticketUtils.imprimirTexto('Fecha: 1.0.0');
    await ticketUtils.imprimirTexto(
      'Detalle: Eiusmod occaecat cillum id voluptate.',
    );
    await ticketUtils.imprimirTexto('Débito: 10.00  Crédito: 15.00');
    await ticketUtils.imprimirTexto('Saldo: 1110.00');
    await ticketUtils.imprimirTexto('Documento: 1  Tipo: PDF');
    await ticketUtils.imprimirTexto('Referencia: 51515');
    bluetooth.printNewLine();
    await ticketUtils.imprimirTexto(
      'Generado por: DEMOSOFT',
      size: 0,
      align: 1,
    );
    await ticketUtils.imprimirTexto('1.0.0', size: 0, align: 1);

    // Línea final y desconexión
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    await ticketUtils.desconectarSiConectado();
  }

  Future<Uint8List> generar({PdfPageFormat format = PdfPageFormat.a4}) async {
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
              rows: [],
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
              // PdfUtils.detalleTicket<EstadoCuenta>(
              //   items: movimientos,
              //   font: font,
              //   fontSize: 6,
              //   campos: {
              //     'Fecha': (m) => m.fecha,
              //     'Detalle': (m) => m.detalle,
              //     'Débito': (m) => m.debito.toStringAsFixed(2),
              //     'Crédito': (m) => m.credito.toStringAsFixed(2),
              //     'Saldo': (m) => m.saldo.toStringAsFixed(2),
              //     'Documento': (m) => m.documento,
              //     'Tipo': (m) => m.tipo,
              //     'Referencia': (m) => m.referencia,
              //   },
              // ),
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
