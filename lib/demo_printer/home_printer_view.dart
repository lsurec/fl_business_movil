import 'package:fl_business/demo_printer/home_printer_view_model.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class HomePrinterView extends StatelessWidget {
  const HomePrinterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomePrinterViewModel vm = Provider.of<HomePrinterViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              shadowColor: Colors.transparent, // Sin sombra
              surfaceTintColor:
                  Colors.grey.shade300, // Color de fondo del AppBar
              title: Text("Vista Previa"), // Título
              leading: IconButton(
                // Botón de retroceso
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Muestra alerta antes de regresar
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Aviso"),
                      content: Text(
                        "Asegurate de compartir o imprimir el documento, antes de regresar",
                      ),
                      actions: <Widget>[
                        TextButton(
                          // Opción para regresar
                          onPressed: () {
                            // Navigator.of(context).pop();

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => TablaDemoPage(),
                            //   ),
                            // );
                          },
                          child: Text(
                            "Regresar",
                            style: TextStyle(color: Colors.grey[500]!),
                          ),
                        ),
                        TextButton(
                          // Opción para continuar a imprimir / compartir
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // Cierra el AlertDialog
                          },
                          child: Text("Imprimir/Compartir"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      // Botón para imprimir ticket físico
                      onPressed: () => vm.imprimirTicket(context: context),
                      icon: Icon(Icons.receipt),
                      label: Text("Imprimir Ticket"),
                    ),
                    TextButton.icon(
                      // Botón para imprimir PDF
                      onPressed: () async {
                        if (vm.formatoSeleccionado != null) {
                          // Ajusta márgenes antes de generar PDF
                          final adjustedFormat = vm.formatoSeleccionado!
                              .copyWith(
                                marginLeft: 10,
                                marginRight: 10,
                                marginTop: 10,
                                marginBottom: 10,
                              );

                          // Llamada al servicio GenerarPdf
                          final pdfBytes = await vm.generar(
                            format: adjustedFormat,
                          );
                          // Imprime PDF usando paquete printing
                          await Printing.layoutPdf(
                            onLayout: (_) => pdfBytes,
                            format: adjustedFormat,
                          );
                        } else {
                          // Mensaje si no hay formato seleccionado
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selecciona un formato antes de imprimir',
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.print),
                      label: Text('Imprimir PDF'),
                    ),
                  ],
                ),
                Expanded(
                  // Previsualización del PDF
                  child: PdfPreview(
                    pdfFileName: "Documento.pdf",
                    pageFormats: {
                      'Carta (a4)': PdfPageFormat.a4,
                      'Ticket': PdfPageFormat(
                        57 * PdfPageFormat.mm, // Ancho típico de ticket
                        double.infinity, // Altura infinita
                        marginAll: 10, // Márgenes
                      ),
                    },
                    canDebug: false, // Oculta opciones de debug
                    canChangeOrientation: false, // No permite rotar página
                    build: (format) {
                      // Guarda el formato seleccionado
                      final adjustedFormat = format.copyWith(
                        marginLeft: 10,
                        marginRight: 10,
                        marginTop: 10,
                        marginBottom: 10,
                      );
                      vm.formatoSeleccionado = adjustedFormat;
                      // Genera PDF para vista previa
                      return vm.generar(format: adjustedFormat);
                    },
                    allowPrinting:
                        false, // No imprime directamente desde preview
                    allowSharing: true, // Permite compartir PDF
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
