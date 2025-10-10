import 'package:fl_business/service/generar_pdf.dart';
import 'package:fl_business/service/impresion_ticket.dart';
import 'package:fl_business/utils/utils.dart';
import 'package:fl_business/widgets/tabla_demo.dart';
import 'package:flutter/material.dart'; // Librería principal de Flutter para UI
import 'package:pdf/pdf.dart'; // Librería PDF
import 'package:pdf/widgets.dart' as pw; // Widgets PDF
import 'package:printing/printing.dart'; // Para mostrar y exportar PDF
import 'package:intl/intl.dart'; // Para formateo de fechas

// Widget principal de la vista previa del PDF / ticket
class VistaPrevia extends StatefulWidget {
  const VistaPrevia({super.key});
  @override
  _VistaPreviaState createState() => _VistaPreviaState();
}

class _VistaPreviaState extends State<VistaPrevia>
    with TickerProviderStateMixin {
  PdfPageFormat? _formatoSeleccionado; // Guarda el formato actual de la página
  UtilitiesService utils = UtilitiesService(); // Instancia de utilidades
  TablaDemoPage mov =
      TablaDemoPage(); // Instancia de tabla con movimientos simulados

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercepta el botón de regresar para mostrar aviso
      onWillPop: () async {
        return await utils.onWillPop(context);
      },
      child: Stack(
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
                            Navigator.of(context).pop();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TablaDemoPage(),
                              ),
                            );
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
                      onPressed: () => ImpresionTicket.imprimirTicket(
                        context: context,
                        movimientos: mov.movimientos,
                      ),
                      icon: Icon(Icons.receipt),
                      label: Text("Imprimir Ticket"),
                    ),
                    TextButton.icon(
                      // Botón para imprimir PDF
                      onPressed: () async {
                        if (_formatoSeleccionado != null) {
                          // Ajusta márgenes antes de generar PDF
                          final adjustedFormat = _formatoSeleccionado!.copyWith(
                            marginLeft: 10,
                            marginRight: 10,
                            marginTop: 10,
                            marginBottom: 10,
                          );

                          // Llamada al servicio GenerarPdf
                          final pdfBytes = await GenerarPdf.generar(
                            movimientos: mov.movimientos,
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
                    pdfFileName:
                        "Documento ${DateFormat("dd-MM-yyyy").format(DateTime.now())}.pdf",
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
                      _formatoSeleccionado = adjustedFormat;
                      // Genera PDF para vista previa
                      return GenerarPdf.generar(
                        movimientos: mov.movimientos,
                        format: adjustedFormat,
                      );
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
