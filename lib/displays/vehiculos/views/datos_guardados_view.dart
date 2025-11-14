import 'dart:io';
import 'package:fl_business/displays/vehiculos/model_views/inicio_model_view.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DatosGuardadosScreen extends StatelessWidget {
  final InicioVehiculosViewModel vm;

  const DatosGuardadosScreen({Key? key, required this.vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = vm.itemsAsignados;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff134895),
        title: const Text(
          'Datos guardados',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------
            //  Datos del Cliente
            // ---------------------------
            const Text(
              'Datos del Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _dato('NIT', vm.nit),
            _dato('Nombre', vm.nombre),
            _dato('Dirección', vm.direccion),
            _dato('Celular', vm.celular),
            _dato('Email', vm.email),
            const SizedBox(height: 16),

            // ---------------------------
            //  Datos del Vehículo
            // ---------------------------
            const Text(
              'Datos del Vehículo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _dato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
            _dato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
            _dato('Modelo (Año)', vm.anioSeleccionado?.anio.toString() ?? '—'),
            _dato('Color', vm.colorSeleccionado?.descripcion ?? '—'),
            const SizedBox(height: 16),

            // ---------------------------
            //  Fechas
            // ---------------------------
            const Text(
              '📅 Fechas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _dato('Fecha recibido', vm.fechaRecibido.isEmpty ? '—' : vm.fechaRecibido),
            _dato('Fecha salida', vm.fechaSalida.isEmpty ? '—' : vm.fechaSalida),
            const SizedBox(height: 16),

            // ---------------------------
            //  Observaciones
            // ---------------------------
            const Text(
              'Observaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _dato('Detalle del trabajo', vm.detalleTrabajo),
            _dato('Kilometraje', vm.kilometraje),
            _dato('CC', vm.cc),
            _dato('CIL', vm.cil),
            const SizedBox(height: 32),

            // ---------------------------
            //  Ítems del vehículo
            // ---------------------------
            const Text(
              'Ítems del Vehículo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            if (items.isEmpty)
              const Text('No se asignaron ítems a este vehículo.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_rounded,
                                color: Color(0xff134895),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.desProducto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (item.completado)
                                const Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('ID: ${item.idProducto}', style: const TextStyle(color: Colors.black54)),

                          if (item.detalle.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '📝 Detalle:',
                              style: TextStyle(
                                color: Colors.blueGrey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(item.detalle),
                          ],

                          if (item.fotos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '📷 Fotos:',
                              style: TextStyle(
                                color: Colors.blueGrey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.fotos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, fotoIndex) {
                                  final foto = item.fotos[fotoIndex];
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(foto.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // ---------------------------
            //  Botón de PDF
            // ---------------------------
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff134895),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => _generarPdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'Generar PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$titulo:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(valor.isEmpty ? '—' : valor)),
        ],
      ),
    );
  }

  // 🔹 Generación de PDF
  Future<void> _generarPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              '📋 Reporte de Vehículo',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Text('👤 Datos del Cliente', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _pdfDato('NIT', vm.nit),
          _pdfDato('Nombre', vm.nombre),
          _pdfDato('Dirección', vm.direccion),
          _pdfDato('Celular', vm.celular),
          _pdfDato('Email', vm.email),

          pw.SizedBox(height: 20),

          pw.Text('🚗 Datos del Vehículo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _pdfDato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
          _pdfDato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
          _pdfDato('Modelo (Año)', vm.anioSeleccionado?.anio.toString() ?? '—'),
          _pdfDato('Color', vm.colorSeleccionado?.descripcion ?? '—'),

          pw.SizedBox(height: 20),

          pw.Text('📅 Fechas', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _pdfDato('Fecha recibido', vm.fechaRecibido),
          _pdfDato('Fecha salida', vm.fechaSalida),

          pw.SizedBox(height: 20),

          pw.Text('📝 Observaciones', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          _pdfDato('Detalle del trabajo', vm.detalleTrabajo),
          _pdfDato('Kilometraje', vm.kilometraje),
          _pdfDato('CC', vm.cc),
          _pdfDato('CIL', vm.cil),

          pw.SizedBox(height: 25),

          pw.Text('🧩 Ítems del Vehículo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          if (vm.itemsAsignados.isEmpty)
            pw.Text('No se asignaron ítems.')
          else
            ...vm.itemsAsignados.map((item) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(item.desProducto, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text('ID: ${item.idProducto}'),
                  if (item.detalle.isNotEmpty) pw.Text('Detalle: ${item.detalle}'),
                  pw.SizedBox(height: 6),
                  if (item.fotos.isNotEmpty)
                    pw.Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.fotos.map((f) {
                        final file = File(f.path);
                        if (!file.existsSync()) return pw.Container();
                        final image = pw.MemoryImage(file.readAsBytesSync());
                        return pw.Image(image, width: 100, height: 100);
                      }).toList(),
                    ),
                  pw.SizedBox(height: 15),
                ],
              );
            }),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ReporteVehiculo.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📄 PDF generado: ${file.path}')),
    );
  }

  pw.Widget _pdfDato(String titulo, String valor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 120, child: pw.Text('$titulo:')),
        pw.Expanded(child: pw.Text(valor.isEmpty ? '—' : valor)),
      ],
    );
  }
}
