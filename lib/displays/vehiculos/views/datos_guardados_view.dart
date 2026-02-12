import 'dart:io';
import 'dart:typed_data';
import 'package:fl_business/displays/vehiculos/model_views/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/models/marcar_vehiculo_model.dart';
import 'package:fl_business/displays/vehiculos/views/widgets/vehiculo_marcado_widget.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/view_models/elemento_asignado_view_model.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';

// ViewModel
import '../model_views/inicio_model_view.dart';

class DatosGuardadosScreen extends StatefulWidget {
  const DatosGuardadosScreen({super.key});

  @override
  State<DatosGuardadosScreen> createState() => _DatosGuardadosScreenState();
}

class _DatosGuardadosScreenState extends State<DatosGuardadosScreen> {
  late SignatureController _firmaMecanico;
  late SignatureController _firmaCliente;

  @override
  void initState() {
    super.initState();
    _firmaMecanico = SignatureController(penStrokeWidth: 2);
    _firmaCliente = SignatureController(penStrokeWidth: 2);
  }

  @override
  void dispose() {
    _firmaMecanico.dispose();
    _firmaCliente.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InicioVehiculosViewModel>();
    final items = vm.itemsAsignados;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff134895),
            title: const Text(
              'Datos guardados',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Consumer<InicioVehiculosViewModel>(
                builder: (_, vm, __) => IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: vm.isLoading
                      ? null
                      : () async {
                          await _enviarDocumento(context);
                        },
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DATOS CLIENTE =================
                _titulo('Datos del Cliente'),
                _dato('NIT', vm.clienteSelect?.facturaNit ?? ""),
                _dato('Nombre', vm.clienteSelect?.facturaNombre ?? ""),
                _dato('Dirección', vm.clienteSelect?.facturaDireccion ?? ""),
                _dato('Celular', vm.clienteSelect?.telefono ?? ""),
                _dato('Email', vm.clienteSelect?.eMail ?? ""),
                const SizedBox(height: 20),

                // ================= DATOS VEHÍCULO =================
                _titulo('Datos del Vehículo'),
                _dato('Chasis', vm.recepcionGuardada?.chasis ?? '—'),
                _dato('Placa', vm.recepcionGuardada?.placa ?? '—'),
                _dato('Marca', vm.marcaSeleccionada?.descripcion ?? '—'),
                _dato('Línea', vm.modeloSeleccionado?.descripcion ?? '—'),
                _dato(
                  'Modelo (Año)',
                  vm.anioSeleccionado?.anio.toString() ?? '—',
                ),
                _dato('Color', vm.colorSeleccionado?.descripcion ?? '—'),
                const SizedBox(height: 20),

                // ================= VEHÍCULO MARCADO =================
                if (vm.imagenTipoVehiculo != null) ...[
                  VehiculoMarcadoWidget(
                    imagePath: vm.imagenTipoVehiculo!,
                    marcas: vm.marcasVehiculo,
                    onTap: vm.agregarMarca, // 👈 edición activa
                  ),
                  const SizedBox(height: 12),

                  // ================= BOTONES MARCAS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.undo),
                        label: const Text('Eliminar última'),
                        onPressed: vm.marcasVehiculo.isEmpty
                            ? null
                            : vm.eliminarUltimaMarca,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Eliminar todas'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: vm.marcasVehiculo.isEmpty
                            ? null
                            : vm.limpiarMarcas,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                // ================= FECHAS =================
                _titulo('📅 Fechas'),
                _dato('Fecha recibido', vm.fechaRecibido),
                _dato('Fecha estimada de entrega', vm.fechaSalida),
                const SizedBox(height: 20),

                // ================= OBSERVACIONES =================
                _titulo('Observaciones'),
                _dato(
                  'Detalle del trabajo',
                  vm.recepcionGuardada?.detalleTrabajo ?? '—',
                ),
                _dato('Kilometraje', vm.recepcionGuardada?.kilometraje ?? '—'),
                _dato('CC', vm.recepcionGuardada?.cc ?? '—'),
                _dato('CIL', vm.recepcionGuardada?.cil ?? '—'),
                const SizedBox(height: 30),

                // ================= ÍTEMS =================
                _titulo('Ítems del Vehículo'),
                if (items.isEmpty)
                  const Text('No se asignaron ítems')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _itemCard(items[i]),
                  ),
                const SizedBox(height: 30),

                // ================= FIRMAS =================
                _titulo(' Firmas'),
                const Text('Firma del Mecánico'),
                _firmaBox(_firmaMecanico),
                const SizedBox(height: 20),
                const Text('Firma del Dueño'),
                _firmaBox(_firmaCliente),
                const SizedBox(height: 30),

                // ================= PDF =================
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff134895),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _prepararYGenerarPdf,
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      'Generar PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'Enviar Documento',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            await _enviarDocumento(context);
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }

  // ================= FIRMA UI =================
  Widget _firmaBox(SignatureController controller) {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Signature(
            controller: controller,
            backgroundColor: Colors.white,
          ),
        ),
        TextButton(
          onPressed: controller.clear,
          child: const Text('Limpiar firma'),
        ),
      ],
    );
  }

  /// Carga la imagen del vehículo (asset) y la convierte en ImageProvider para PDF
  Future<pw.ImageProvider?> _cargarImagenPdf(BuildContext context) async {
    final vm = context.read<InicioVehiculosViewModel>();
    final path = vm.imagenTipoVehiculo;
    if (path == null) return null;
    final bytes = await DefaultAssetBundle.of(context).load(path);
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  pw.Widget _vehiculoConMarcasPdf(
    pw.ImageProvider imagen,
    List<MarcaVehiculo> marcas,
  ) {
    // Tamaño fijo del contenedor en el PDF
    const double containerWidth = 300;
    const double containerHeight = 200;

    // 🔹 Ratio REAL de la imagen
    final double imageRatio = imagen.width! / imagen.height!;
    double imageWidth;
    double imageHeight;

    // 🔹 Replicar BoxFit.contain (igual que en Flutter)
    if (containerWidth / containerHeight > imageRatio) {
      imageHeight = containerHeight;
      imageWidth = imageHeight * imageRatio;
    } else {
      imageWidth = containerWidth;
      imageHeight = imageWidth / imageRatio;
    }

    // 🔹 Offsets para centrar la imagen
    final double offsetX = (containerWidth - imageWidth) / 2;
    final double offsetY = (containerHeight - imageHeight) / 2;

    return pw.Center(
      child: pw.Container(
        width: containerWidth,
        height: containerHeight,
        child: pw.Stack(
          children: [
            // ================= IMAGEN =================
            pw.Positioned(
              left: offsetX,
              top: offsetY,
              child: pw.Image(
                imagen,
                width: imageWidth,
                height: imageHeight,
                fit: pw.BoxFit.contain,
              ),
            ),

            // ================= MARCAS =================
            ...marcas.map((m) {
              final double dx = offsetX + (m.x * imageWidth);
              final double dy = offsetY + (m.y * imageHeight);
              return pw.Positioned(
                left: dx - 6,
                top: dy - 6,
                child: pw.Container(
                  width: 12,
                  height: 12,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.red,
                    shape: pw.BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ================= PDF =================
  Future<void> _generarPdf(
    
    BuildContext context, {
    Uint8List? firmaMecanico,
    Uint8List? firmaCliente,
  }) async {
    final vm = context.read<InicioVehiculosViewModel>();
    final pdf = pw.Document();
    final imagenVehiculoPdf = await _cargarImagenPdf(context);
    final pw.ImageProvider? firmaMecanicoPdf = firmaMecanico != null
        ? pw.MemoryImage(firmaMecanico)
        : null;
    final pw.ImageProvider? firmaClientePdf = firmaCliente != null
        ? pw.MemoryImage(firmaCliente)
        : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          // ===================== ENCABEZADO =====================
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Cliente: ${vm.nombre}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Dirección: ${vm.direccion}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    'Marca: ${vm.marcaSeleccionada?.descripcion ?? '—'}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    'Línea: ${vm.modeloSeleccionado?.descripcion ?? '—'}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    'Modelo: ${vm.anioSeleccionado?.anio.toString() ?? '—'}',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              // Solo las etiquetas sin contenido
              pw.Text('Combustible:', style: pw.TextStyle(fontSize: 12)),
              pw.Text('Obs. Generales:', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
            ],
          ),

          // ===================== TÍTULO =====================
          pw.Center(
            child: pw.Text(
              'DETALLE DEL TRABAJO',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 15),

          // ===================== TABLA DE ITEMS (SKU + OBSERVACIÓN) =====================
          if (vm.itemsAsignados.isNotEmpty)
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              headers: ['Observación', 'SKU'],
              data: vm.itemsAsignados.map((item) {
                // Usar el detalle como observación
                return [
                  item.detalle.isEmpty ? '—' : item.detalle,
                  item.desProducto, // SKU es la descripción del producto
                  
                ];
              }).toList(),
            )
          else
            pw.Text('No se asignaron ítems'),
          pw.SizedBox(height: 20),

          // ===================== OBSERVACIONES ADICIONALES =====================
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Observación: Combustible:',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Obs. Vehículo:', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 30),

          // ===================== IMÁGENES DE LOS ITEMS =====================
          if (vm.itemsAsignados.any((item) => item.fotos.isNotEmpty))
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Fotografías Del Vehículo',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 10),
                ...vm.itemsAsignados.expand((item) {
                  if (item.fotos.isEmpty) return <pw.Widget>[];
                  return [
                    // Encabezado del item con SKU
                    pw.Text(
                      'SKU: ${item.desProducto}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),

                    // Fotos del item
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.fotos.map((fotoPath) {
                        try {
                          final file = File(fotoPath);
                          if (file.existsSync()) {
                            final imgBytes = file.readAsBytesSync();
                            return pw.Container(
                              width: 80,
                              height: 80,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey300),
                                borderRadius: pw.BorderRadius.circular(5),
                              ),
                              child: pw.Image(
                                pw.MemoryImage(imgBytes),
                                fit: pw.BoxFit.cover,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Error cargando imagen: $e');
                        }
                        return pw.Container(
                          width: 80,
                          height: 80,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'Error',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    pw.SizedBox(height: 20),
                  ];
                }).toList(),
              ],
            ),
          pw.SizedBox(height: 20),

          // ===================== DATOS CLIENTE COMPLETOS =====================
          pw.Text(
            'DATOS COMPLETOS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          _pdfDato('NIT', vm.nit),
          _pdfDato('Nombre', vm.nombre),
          _pdfDato('Dirección', vm.direccion),
          _pdfDato('Celular', vm.celular),
          _pdfDato('Email', vm.email),
          pw.SizedBox(height: 20),

          // ===================== DATOS VEHÍCULO =====================
          _pdfDato('Chasis', vm.recepcionGuardada?.chasis ?? '—'),
          _pdfDato('Placa', vm.recepcionGuardada?.placa ?? '—'),
          _pdfDato('Color', vm.colorSeleccionado?.descripcion ?? '—'),
          _pdfDato('Kilometraje', vm.recepcionGuardada?.kilometraje ?? '—'),
          _pdfDato('CC', vm.recepcionGuardada?.cc ?? '—'),
          _pdfDato('CIL', vm.recepcionGuardada?.cil ?? '—'),
          _pdfDato(
            'Detalle del trabajo',
            vm.recepcionGuardada?.detalleTrabajo ?? '—',
          ),

          // ===================== IMAGEN VEHÍCULO + MARCAS =====================
          if (imagenVehiculoPdf != null) ...[
            pw.SizedBox(height: 15),
            pw.Text(
              'ESTADO DEL VEHÍCULO',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _vehiculoConMarcasPdf(imagenVehiculoPdf, vm.marcasVehiculo),
          ],
          pw.SizedBox(height: 20),

          // ===================== FECHAS =====================
          _pdfDato('Fecha recibido', vm.fechaRecibido),
          _pdfDato('Fecha Estimada de Salida', vm.fechaSalida),
          pw.SizedBox(height: 30),

          // ===================== FIRMAS =====================
          pw.Text(
            'FIRMAS',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                children: [
                  pw.Container(
                    width: 180,
                    height: 80,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: firmaMecanicoPdf != null
                        ? pw.Image(firmaMecanicoPdf, fit: pw.BoxFit.contain)
                        : pw.Center(child: pw.Text('Firma Mecánico')),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Mecánico'),
                ],
              ),
              pw.Column(
                children: [
                  pw.Container(
                    width: 180,
                    height: 80,
                    decoration: pw.BoxDecoration(border: pw.Border.all()),
                    child: firmaClientePdf != null
                        ? pw.Image(firmaClientePdf, fit: pw.BoxFit.contain)
                        : pw.Center(child: pw.Text('Firma Cliente')),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text('Propietario'),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ReporteVehiculo.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF generado: ${file.path}')));
  }

  Future<void> _prepararYGenerarPdf() async {
    if (_firmaMecanico.isEmpty || _firmaCliente.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ambas firmas son obligatorias')),
      );
      return;
    }

    final Uint8List? firmaMecanicoBytes = await _firmaMecanico.toPngBytes();
    final Uint8List? firmaClienteBytes = await _firmaCliente.toPngBytes();

    debugPrint('Firma mecánico bytes: ${firmaMecanicoBytes?.length}');
    debugPrint('Firma cliente bytes: ${firmaClienteBytes?.length}');

    await _generarPdf(
      context,
      firmaMecanico: firmaMecanicoBytes,
      firmaCliente: firmaClienteBytes,
    );
  }

  Future<void> _enviarDocumento(BuildContext context) async {
    final vm = context.read<InicioVehiculosViewModel>();
    final itemsVM = Provider.of<ItemsVehiculoViewModel>(context, listen: false);
    final elVM = context.read<ElementoAsigandoViewModel>();

    try {
      vm.setLoading(true);

      // ================= PASO 1: CARGAR TRANSAcCIONES =================
      print('=== PASO 1: Verificar transacciones ===');
      print('Transacciones cargadas: ${itemsVM.transaciciones.length}');

      // 🔥 CARGAR TRANSAcCIONES SI ESTÁN VACÍAS
      if (itemsVM.transaciciones.isEmpty) {
        print('Cargando transacciones desde API...');
        await itemsVM.loadItems();
        print(
          'Transacciones después de carga: ${itemsVM.transaciciones.length}',
        );
      }

      // ================= PASO 2: SINCRONIZAR =================
      print('=== PASO 2: Sincronizar ===');
      await vm.sincronizarTransacciones(context);

      // ================= PASO 3: ENVIAR DOCUMENTO =================
      print('=== PASO 3: Enviar documento ===');
      final res = await vm.sendDocument(context);

      if (res.succes) {
        // ✅ Guardar referencias ANTES de cualquier cambio
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        // ✅ Mostrar mensaje (usando la referencia guardada)
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Documento enviado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Limpiar datos (esto NO afecta el contexto)
        vm.cancelar();
        elVM.cancelar();

        // ✅ Ejecutar los pops DESPUÉS del frame actual
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Verificar que el navigator todavía sea válido
          try {
            // Pop 2 veces para regresar al inicio
            navigator.pop(); // Cierra DatosGuardadosScreen
            navigator.pop(); // Cierra ItemsVehiculoScreen
          } catch (e) {
            print('Error al navegar: $e');
            // Fallback: intentar con popUntil
            navigator.popUntil((route) => route.isFirst);
          }
        });
      } else {
        // ❌ ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.response?.toString() ?? '❌ Error al enviar documento',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      vm.setLoading(false);
    }
  }

  // Future<void> _enviarDocumento(BuildContext context) async {
  //   final vm = context.read<InicioVehiculosViewModel>();
  //   try {
  //     vm.setLoading(true);
  //     final res = await vm.sendDocument(context);
  //     if (res.succes) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Documento enviado correctamente')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             res.response?.toString() ??
  //                 'Debe seleccionar al menos una transacción',
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
  //     );
  //   } finally {
  //     vm.setLoading(false);
  //   }
  // }
}

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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item.completado)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${item.idProducto}',
            style: const TextStyle(color: Colors.black54),
          ),
          if (item.detalle.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Detalle:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(item.detalle),
          ],
          if (item.fotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Fotos:', style: TextStyle(fontWeight: FontWeight.bold)),
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

pw.Widget _pdfDato(String titulo, String valor) {
  return pw.Row(
    children: [
      pw.Container(width: 120, child: pw.Text('$titulo:')),
      pw.Expanded(child: pw.Text(valor.isEmpty ? '—' : valor)),
    ],
  );
}
