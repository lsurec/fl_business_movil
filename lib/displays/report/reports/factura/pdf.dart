import 'package:fl_business/displays/report/utils/pdf_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/shr_local_config/models/models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/models/doc_print_model.dart';
import 'package:fl_business/services/picture_service.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class FacturaPDF {
  Future<void> getReport(BuildContext contextP) async {
    final DocPrintModel data = FacturaProvider.data!;

    final HomeViewModel vmHome = Provider.of<HomeViewModel>(
      contextP,
      listen: false,
    );

    // Crear una instancia de NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(
      symbol: vmHome
          .moneda, // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
      decimalDigits: 2, // Número de decimales a mostrar
    );

    PictureService pictureService = PictureService();

    final EmpresaModel empresaSession = Provider.of<LocalSettingsViewModel>(
      contextP,
      listen: false,
    ).selectedEmpresa!;

    final ByteData logoEmpresa = await pictureService.getLogo(
      empresaSession.absolutePathPicture,
    );

    //Logos para el pdf
    final ByteData imgFel = await rootBundle.load('assets/fel.png');
    final ByteData imgDemo = await rootBundle.load('assets/logo_demosoft.png');

    //formato de imagenes valido
    Uint8List logoData = (logoEmpresa).buffer.asUint8List();
    Uint8List logoFel = (imgFel).buffer.asUint8List();
    Uint8List logoDemo = (imgDemo).buffer.asUint8List();

    //Estilos para el pdf
    pw.TextStyle font8 = const pw.TextStyle(fontSize: 8);

    pw.TextStyle font8Bold = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    pw.TextStyle font8BoldWhite = pw.TextStyle(
      color: PdfColors.white,
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
    );

    PdfColor backCell = PdfColor.fromHex("134895");

    bool isFel = data.documento.autorizacion.isNotEmpty ? true : false;

    //Docuemnto pdf nuevo
    final pdf = pw.Document();

    // Agrega páginas con encabezado y pie de página
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginBottom: 20,
          marginLeft: 20,
          marginTop: 20,
          marginRight: 20,
        ),
        build: (pw.Context context) {
          return [
            // Contenido de la página 1
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                //No interno y vendedor
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${AppLocalizations.of(contextP)!.translate(BlockTranslate.tiket, 'interno')} ${data.documento.noInterno}',
                      style: font8,
                    ),
                    pw.Text("Usuario: ${data.usuario}", style: font8),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Serie Interna: ${data.documento.serieInterna}',
                      style: font8,
                    ),
                    pw.Text(
                      '${AppLocalizations.of(contextP)!.translate(BlockTranslate.tiket, 'vendedor')} ${data.vendedor}',
                      style: font8,
                    ),
                  ],
                ),
                //No interno y vendedor
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Cons. Interno: ${data.documento.consecutivoInterno}',
                      style: font8,
                    ),
                    pw.Text("Registros: ${data.items.length}", style: font8),
                  ],
                ),
                pw.SizedBox(height: 10),
                //Datos del cliente
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black, // Color del borde
                      width: 1, // Ancho del borde
                    ),
                  ),
                  width: double.infinity,
                  child: pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        width: PdfPageFormat.letter.width * 0.70,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Text(
                                  AppLocalizations.of(
                                    contextP,
                                  )!.translate(BlockTranslate.tiket, 'nombre'),
                                  style: font8Bold,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(data.cliente.nombre, style: font8),
                              ],
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              children: [
                                pw.Text(
                                  AppLocalizations.of(contextP)!.translate(
                                    BlockTranslate.tiket,
                                    'direccion',
                                  ),
                                  style: font8Bold,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(data.cliente.direccion, style: font8),
                              ],
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              children: [
                                pw.Text("NIT:", style: font8Bold),
                                pw.SizedBox(width: 5),
                                pw.Text(data.cliente.nit, style: font8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Text(
                                  AppLocalizations.of(
                                    contextP,
                                  )!.translate(BlockTranslate.fecha, 'fecha'),
                                  style: font8Bold,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(data.cliente.fecha, style: font8),
                              ],
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              children: [
                                pw.Text(
                                  AppLocalizations.of(
                                    contextP,
                                  )!.translate(BlockTranslate.tiket, 'tel'),
                                  style: font8Bold,
                                ),
                                pw.SizedBox(width: 5),
                                pw.Text(data.cliente.tel, style: font8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                //Detalles del documento
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black, // Color del borde
                      width: 1, // Ancho del borde
                    ),
                    // borderRadius: pw.BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      //Titulos de las columnas
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          color: backCell,
                          border: const pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.10,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'codigo'),
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.10,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'cantidadT'),
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.10,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'uniMedida'),
                                textAlign: pw.TextAlign.center,
                                style: font8BoldWhite,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.40,
                              child: pw.Text(
                                AppLocalizations.of(contextP)!.translate(
                                  BlockTranslate.general,
                                  'descripcion',
                                ),
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.10,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'unitario'),
                                textAlign: pw.TextAlign.center,
                                style: font8BoldWhite,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.10,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'totalT'),
                                textAlign: pw.TextAlign.center,
                                style: font8BoldWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      //Deatlles (Prductos/transacciones)
                      ...data.items
                          .map(
                            (detalle) => pw.Row(
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.10,
                                  child: pw.Text(
                                    detalle.sku,
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.10,
                                  child: pw.Text(
                                    "${detalle.cantidad}",
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.10,
                                  child: pw.Text(
                                    detalle.um,
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.40,
                                  child: pw.Text(
                                    detalle.descripcion,
                                    textAlign: pw.TextAlign.left,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.10,
                                  child: pw.Text(
                                    detalle.unitario,
                                    textAlign: pw.TextAlign.right,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.10,
                                  child: pw.Text(
                                    detalle.total,
                                    textAlign: pw.TextAlign.right,
                                    style: font8,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),

                      pw.SizedBox(height: 5),
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              width: PdfPageFormat.letter.width * 0.80,
                              child: pw.Text("Subtotal:", style: font8),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  currencyFormat.format(data.montos.subtotal),
                                  style: font8,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Total del documento
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              width: PdfPageFormat.letter.width * 0.80,
                              child: pw.Text("Cargos:", style: font8),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  currencyFormat.format(data.montos.cargos),
                                  style: font8,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              width: PdfPageFormat.letter.width * 0.80,
                              child: pw.Text("Descuentos:", style: font8),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  currencyFormat.format(data.montos.descuentos),
                                  style: font8,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Total del documento
                      pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                color: backCell,
                                border: const pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              width: PdfPageFormat.letter.width * 0.80,
                              child: pw.Text("TOTAL:", style: font8BoldWhite),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  currencyFormat.format(data.montos.total),
                                  style: font8Bold,
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Container(
                        width: PdfPageFormat.letter.width,
                        padding: const pw.EdgeInsets.all(5),
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        child: pw.Text(
                          "${AppLocalizations.of(contextP)!.translate(BlockTranslate.tiket, 'letrasTotal')} ${data.montos.totalLetras}."
                              .toUpperCase(),
                          style: font8Bold,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Center(
                  child: pw.Text(
                    "Forma de Pago",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                //Detalles de pago del documento
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black, // Color del borde
                      width: 1, // Ancho del borde
                    ),
                    // borderRadius: pw.BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      //Titulos de las columnas
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          color: backCell,
                          border: const pw.Border(
                            bottom: pw.BorderSide(
                              color: PdfColors.black, // Color del borde
                              width: 1.0, // Ancho del borde
                            ),
                          ),
                        ),
                        width: PdfPageFormat.letter.width,
                        child: pw.Row(
                          children: [
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.49,
                              child: pw.Text(
                                'Descripción',
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.15,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'recibido'),
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Container(
                              decoration: const pw.BoxDecoration(
                                border: pw.Border(
                                  right: pw.BorderSide(
                                    color: PdfColors.black, // Color del borde
                                    width: 1.0, // Ancho del borde
                                  ),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.15,
                              child: pw.Text(
                                AppLocalizations.of(
                                  contextP,
                                )!.translate(BlockTranslate.tiket, 'monto'),
                                textAlign: pw.TextAlign.center,
                                style: font8BoldWhite,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              width: PdfPageFormat.letter.width * 0.15,
                              child: pw.Text(
                                'Cambio',
                                style: font8BoldWhite,
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      //Deatlles (pagos)
                      ...data.pagos
                          .map(
                            (detalle) => pw.Row(
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.49,
                                  child: pw.Text(
                                    detalle.tipoPago,
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.15,
                                  child: pw.Text(
                                    currencyFormat.format(detalle.pago),
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.15,
                                  child: pw.Text(
                                    currencyFormat.format(detalle.monto),
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  width: PdfPageFormat.letter.width * 0.15,
                                  child: pw.Text(
                                    currencyFormat.format(detalle.cambio),
                                    textAlign: pw.TextAlign.center,
                                    style: font8,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),

                if (data.observacion != "") pw.SizedBox(height: 10),
                if (data.observacion != "")
                  pw.Text("Observacion: ${data.observacion}", style: font8),

                pw.SizedBox(height: 10),

                pw.Center(
                  child: pw.Text(
                    data.mensajes[0],
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    data.mensajes[1],
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        //encabezado
        header: (pw.Context context) => buildHeader(contextP, logoData, isFel),
        //pie de pagina
        footer: (pw.Context context) =>
            buildFooter(contextP, logoDemo, logoFel, isFel),
      ),
    );

    await PdfUtils.sharePdf(
      contextP,
      pdf,
      AppLocalizations.of(contextP)!.translate(BlockTranslate.tiket, 'pdf'),
    );
  }

  //encabezado del pdf
  pw.Widget buildHeader(BuildContext context, Uint8List logo, bool isFel) {
    final DocPrintModel data = FacturaProvider.data!;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Item 1 (50%)
          pw.Container(
            height: 65,
            width: PdfPageFormat.letter.width * 0.20,
            child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
          ),

          // Item 2 (25%)
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  data.empresa.razonSocial,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  data.empresa.nombre,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  data.empresa.direccion,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "NIT: ${data.empresa.nit}",
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
                pw.Text(
                  "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'tel')} ${data.empresa.tel}",
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),

          // Item 3 (25%)
          pw.Container(
            child: isFel
                ? pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        data.documento.descripcion,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        data.documento.titulo,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '${AppLocalizations.of(context)!.translate(BlockTranslate.general, 'serie')}: ${data.documento.serie}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'numero')} ${data.documento.no}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        '${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, 'certificacion')} ${data.documento.fechaCert}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tiket, 'firma'),
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        data.documento.autorizacion,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tiket, 'generico'),
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        data.documento.titulo,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  pw.Widget buildFooter(
    BuildContext context,
    Uint8List logoDemo,
    Uint8List logoFel,
    bool isFel,
  ) {
    final DocPrintModel data = FacturaProvider.data!;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        children: [
          // Item 1 (50%)
          pw.Container(
            width: PdfPageFormat.letter.width * 0.20,
            height: 35,
            child: pw.Image(pw.MemoryImage(logoFel)),
          ),

          // Item 2 (25%)
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 15),
            width: PdfPageFormat.letter.width * 0.70,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                if (isFel)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tiket, 'certificador'),
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "NIT: ${data.certificador.nit}",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'nombre')} ${data.certificador.nombre}",
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Powered By:",
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      "Desarrollo Moderno de Software S.A",
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      "www.demosoft.com.gt",
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      data.procedimientoAlmacenado,
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Item 3 (25%)
          pw.Container(
            width: PdfPageFormat.letter.width * 0.20,
            height: 45,
            child: pw.Image(pw.MemoryImage(logoDemo)),
          ),
        ],
      ),
    );
  }
}
