import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// ViewModel
import '../model_views/inicio_model_view.dart';

class DatosGuardadosScreen extends StatelessWidget {
  final InicioVehiculosViewModel vm;

  const DatosGuardadosScreen({super.key, required this.vm});

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
            // Datos del Cliente
            // ---------------------------
            _titulo('Datos del Cliente'),
            _dato('NIT', vm.nit),
            _dato('Nombre', vm.nombre),
            _dato('Dirección', vm.direccion),
            _dato('Celular', vm.celular),
            _dato('Email', vm.email),
            const SizedBox(height: 20),

            // ---------------------------
            // Datos del Vehículo
            // ---------------------------
            _titulo('Datos del Vehículo'),
            _dato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
            _dato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
            _dato('Modelo (Año)', vm.anioSeleccionado?.anio.toString() ?? '—'),
            _dato('Color', vm.colorSeleccionado?.descripcion ?? '—'),
            const SizedBox(height: 20),

            // ---------------------------
            // Fechas
            // ---------------------------
            _titulo('📅 Fechas'),
            _dato('Fecha recibido', vm.fechaRecibido.isEmpty ? '—' : vm.fechaRecibido),
            _dato('Fecha salida', vm.fechaSalida.isEmpty ? '—' : vm.fechaSalida),
            const SizedBox(height: 20),

            // ---------------------------
            // Observaciones
            // ---------------------------
            _titulo('Observaciones'),
            _dato('Detalle del trabajo', vm.detalleTrabajo),
            _dato('Kilometraje', vm.kilometraje),
            _dato('CC', vm.cc),
            _dato('CIL', vm.cil),
            const SizedBox(height: 30),

            // ---------------------------
            // Ítems del Vehículo
            // ---------------------------
            _titulo('Ítems del Vehículo'),
            if (items.isEmpty)
              const Text('No se asignaron ítems al vehículo.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return _itemCard(item);
                },
              ),

            const SizedBox(height: 30),

            // ---------------------------
            // Botón Generar PDF
            // ---------------------------
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff134895),
                ),
                onPressed: () => _generarPdf(context),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'Generar PDF',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // Widgets Reutilizables
  // ----------------------------

  Widget _titulo(String titulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
      ],
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  Widget _itemCard(item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_rounded, color: Color(0xff134895)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.desProducto,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              const Text('📝 Detalle:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(item.detalle),
            ],

            if (item.fotos.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('📷 Fotos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.fotos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, fotoIndex) {
                    final foto = item.fotos[fotoIndex];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(foto),
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
  }

  // ----------------------------
  // Generación de PDF
  // ----------------------------
  Future<void> _generarPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Center(
            child: pw.Text(
              '📋 Reporte de Vehículo',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          _pdfDato('NIT', vm.nit),
          _pdfDato('Nombre', vm.nombre),
          _pdfDato('Dirección', vm.direccion),
          _pdfDato('Celular', vm.celular),
          _pdfDato('Email', vm.email),

          pw.SizedBox(height: 20),
          _pdfDato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
          _pdfDato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
          _pdfDato('Modelo (Año)', vm.anioSeleccionado?.anio.toString() ?? '—'),
          _pdfDato('Color', vm.colorSeleccionado?.descripcion ?? '—'),

          pw.SizedBox(height: 20),
          _pdfDato('Fecha recibido', vm.fechaRecibido),
          _pdfDato('Fecha salida', vm.fechaSalida),

          pw.SizedBox(height: 20),
          _pdfDato('Detalle del trabajo', vm.detalleTrabajo),
          _pdfDato('Kilometraje', vm.kilometraje),
          _pdfDato('CC', vm.cc),
          _pdfDato('CIL', vm.cil),

          pw.SizedBox(height: 25),

          pw.Text('🧩 Ítems del Vehículo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),

          ...vm.itemsAsignados.map((item) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.desProducto, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('ID: ${item.idProducto}'),
                if (item.detalle.isNotEmpty) pw.Text('Detalle: ${item.detalle}'),
                pw.SizedBox(height: 5),

                if (item.fotos.isNotEmpty)
                  pw.Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.fotos.map((f) {
                      final file = File(f);
                      if (!file.existsSync()) return pw.Container();
                      final img = pw.MemoryImage(file.readAsBytesSync());
                      return pw.Image(img, width: 80, height: 80);
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
      SnackBar(content: Text('PDF generado: ${file.path}')),
    );
  }

  pw.Widget _pdfDato(String titulo, String valor) {
    return pw.Row(
      children: [
        pw.Container(width: 120, child: pw.Text('$titulo:')),
        pw.Expanded(child: pw.Text(valor.isEmpty ? '—' : valor)),
      ],
    );
  }
}
