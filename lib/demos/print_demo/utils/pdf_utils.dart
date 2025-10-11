import 'dart:io';
import 'dart:typed_data';

import 'package:fl_business/demos/print_demo/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfUtilsDemo {
  /// Verifica si el formato de página es A4
  static bool esA4(PdfPageFormat format) {
    return (format.width - PdfPageFormat.a4.width).abs() < 0.1 &&
        (format.height - PdfPageFormat.a4.height).abs() < 0.1;
  }

  /// Encabezado de página con logoEmpresa a la izquierda,
  /// logoDemo a la derecha y datos de la empresa en el centro
  static Future<pw.Widget> encabezadoPagina({
    double nombreFontSize = 14,
    double infoFontSize = 10,
    pw.Font? font,
  }) async {
    // Recuperar logos
    final logos = await PdfUtilsDemo.cargarLogos();
    final logoEmpresa = logos['empresa'];
    final logoDemo = logos['demo'];

    // Recuperar datos de la empresa
    String empresaNombre = "ILGUA";
    String empresaNIT = "15613-7";
    String empresaDireccion = "zona 14-7";
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo empresa izquierda
        if (logoEmpresa != null)
          pw.Container(width: 50, height: 50, child: pw.Image(logoEmpresa))
        else
          pw.SizedBox(width: 50, height: 50), // espacio si no hay logo
        // Espacio entre logo y datos
        pw.SizedBox(width: 10),

        // Datos de la empresa centrados
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                empresaNombre,
                style: pw.TextStyle(
                  fontSize: nombreFontSize,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                "NIT: ${empresaNIT}",
                style: pw.TextStyle(fontSize: infoFontSize, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                empresaDireccion,
                style: pw.TextStyle(fontSize: infoFontSize, font: font),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),

        // Espacio entre datos y logo demo
        pw.SizedBox(width: 10),

        // Logo demo derecha
        if (logoDemo != null)
          pw.Container(width: 50, height: 50, child: pw.Image(logoDemo))
        else
          pw.SizedBox(width: 50, height: 50), // espacio si no hay logo
      ],
    );
  }

  static pw.Widget piePaginaPdf({pw.Font? font, double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8.0),
      child: pw.Center(
        child: pw.Text(
          "Generado por: ${UtilitiesService.nombreEmpresa} | Versión: ${UtilitiesService.version}",
          style: pw.TextStyle(fontSize: fontSize, font: font),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Genera una tabla de 2 columnas tipo clave-valor a partir de una lista de mapas genéricos
  /// [data] es la lista, [getKey] y [getValue] son funciones para extraer la clave y valor
  static pw.Widget tablaClaveValor<T>({
    required List<T> data,
    required String Function(T item) getKey,
    required String Function(T item) getValue,
    double fontSize = 10,
    pw.Font? font,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
      children: data.map((item) {
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                getKey(item),
                style: pw.TextStyle(
                  fontSize: fontSize,
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                getValue(item),
                style: pw.TextStyle(fontSize: fontSize, font: font),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  /// Encabezado adaptado a ticket (altura infinita)
  static Future<pw.Widget> encabezadoTicket({
    double nombreFontSize = 7,
    double infoFontSize = 6,
    pw.Font? font,
    Uint8List? logoEmpresaBytes,
  }) async {
    final logos = await cargarLogos();
    final logoEmpresa = logoEmpresaBytes != null
        ? pw.MemoryImage(logoEmpresaBytes)
        : logos['empresa'];

    //simulando datos de la empresa seleccionada:
    String empresaNombre = "ILGUA";
    String empresaNIT = "15613-7";
    String empresaDireccion = "zona 14-7";

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (logoEmpresa != null)
          pw.Center(child: pw.Image(logoEmpresa, width: 40, height: 40)),
        pw.Text(
          empresaNombre,
          style: pw.TextStyle(
            fontSize: nombreFontSize,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.Text(
          "NIT: $empresaNIT",
          style: pw.TextStyle(fontSize: infoFontSize, font: font),
        ),
        pw.Text(
          empresaDireccion,
          style: pw.TextStyle(fontSize: infoFontSize, font: font),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  /// Muestra información en ticket de forma vertical, genérico para cualquier tipo de objeto
  static pw.Widget detalleTicket<T>({
    required List<T> items,
    required Map<String, String Function(T)> campos,
    pw.Font? font,
    double fontSize = 6,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((item) {
        final List<pw.Widget> camposWidgets = campos.entries.map((campo) {
          return pw.Text(
            '${campo.key}: ${campo.value(item)}',
            style: pw.TextStyle(fontSize: fontSize, font: font),
          );
        }).toList();

        // Agregar espacio entre items:
        camposWidgets.add(pw.Text("\n"));

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: camposWidgets,
        );
      }).toList(),
    );
  }

  /// Crea una tabla responsiva dividiendo los datos en columnas dinámicas
  /// Ideal para listas largas que deben adaptarse a A4 u otro tamaño
  static pw.Widget tablaResponsive({
    required List<List<String>> rows,
    List<String>? headers,
    double fontSize = 10,
    pw.Font? font,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: pw.FontWeight.bold,
        font: font,
      ),
      cellStyle: pw.TextStyle(fontSize: fontSize, font: font),
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignments: Map.fromIterables(
        List.generate(headers?.length ?? 0, (index) => index),
        List.generate(headers?.length ?? 0, (_) => pw.Alignment.centerLeft),
      ),
    );
  }

  /// Crea un layout de dos columnas ajustable
  static pw.Widget dosColumnas({
    required pw.Widget izquierda,
    required pw.Widget derecha,
    double spacing = 10,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: izquierda),
        pw.SizedBox(width: spacing),
        pw.Expanded(child: derecha),
      ],
    );
  }

  static Future<Map<String, pw.ImageProvider?>> cargarLogos({
    String? logoEmpresaPath = "assets/logos/yourLogoHere.png",
  }) async {
    // Logo demo fijo desde assets del paquete
    Uint8List? logoBytesDemo;
    try {
      logoBytesDemo = await rootBundle
          .load('assets/logos/logo.png')
          .then((bd) => bd.buffer.asUint8List());
    } catch (_) {
      logoBytesDemo = null;
    }

    // Logo empresa desde ruta externa (archivo local)
    Uint8List? logoBytesEmp;
    if (logoEmpresaPath != null && logoEmpresaPath.isNotEmpty) {
      try {
        final file = File(logoEmpresaPath);
        if (await file.exists()) {
          logoBytesEmp = await file.readAsBytes();
        } else {
          logoBytesEmp = await rootBundle
              .load(logoEmpresaPath)
              .then((bd) => bd.buffer.asUint8List());
        }
      } catch (_) {
        logoBytesEmp = null;
      }
    }

    return {
      'empresa': logoBytesEmp != null ? pw.MemoryImage(logoBytesEmp) : null,
      'demo': logoBytesDemo != null ? pw.MemoryImage(logoBytesDemo) : null,
    };
  }
}
