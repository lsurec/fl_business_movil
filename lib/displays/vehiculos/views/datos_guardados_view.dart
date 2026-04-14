import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/vehiculos/models/FotosporItemModel.dart';
import 'package:fl_business/displays/vehiculos/services/upload_service.dart';
import 'package:fl_business/displays/vehiculos/view_models/items_model_view.dart';
import 'package:fl_business/displays/vehiculos/models/marcar_vehiculo_model.dart';
import 'package:fl_business/displays/vehiculos/views/widgets/vehiculo_marcado_widget.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/elemento_asignado_view_model.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:share_plus/share_plus.dart';

// ViewModel
import '../view_models/inicio_model_view.dart';

class DatosGuardadosScreen extends StatefulWidget {
  const DatosGuardadosScreen({super.key});

  @override
  State<DatosGuardadosScreen> createState() => _DatosGuardadosScreenState();
}

class _DatosGuardadosScreenState extends State<DatosGuardadosScreen> {
  final GlobalKey _vehiculoKey = GlobalKey();
  late SignatureController _firmaMecanico;
  late SignatureController _firmaCliente;
  bool _documentoEnviado = false; //  Bloquea el botón enviar
  bool _pdfGenerado = false;

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
    final t = AppLocalizations.of(context)!;

    final vm = context.watch<InicioVehiculosViewModel>();
    final items = vm.itemsAsignados;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff134895),
            title: Text(
              t.translate(BlockTranslate.vehiculos, 'vehiculos_datosGuardados'),
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= DATOS CLIENTE =================
                _titulo(
                  t.translate(
                    BlockTranslate.vehiculos,
                    'vehiculos_datosCliente',
                  ),
                ),

                _dato(
                  t.translate(BlockTranslate.vehiculos, 'vehiculos_nit'),
                  vm.clienteSelect?.facturaNit ?? "",
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'vehiculos_nombre'),
                  vm.clienteSelect?.facturaNombre ?? "",
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'vehiculos_direccion'),
                  vm.clienteSelect?.facturaDireccion ?? "",
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'celular'),
                  vm.clienteSelect?.telefono ?? vm.celularController.text,
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'email'),
                  vm.clienteSelect?.eMail ?? "",
                ),

                const SizedBox(height: 20),

                // ================= DATOS VEHÍCULO =================
                _titulo(t.translate(BlockTranslate.vehiculos, 'datosVehiculo')),

                _dato(
                  t.translate(BlockTranslate.vehiculos, 'chasis'),
                  vm.recepcionGuardada?.chasis ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'placa'),
                  vm.recepcionGuardada?.placa ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'marca'),
                  vm.marcaSeleccionada?.descripcion ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'linea'),
                  vm.modeloSeleccionado?.descripcion ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'vehiculos_modeloAnio'),
                  vm.anioSeleccionado?.anio.toString() ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'color'),
                  vm.colorSeleccionado?.descripcion ?? '—',
                ),

                const SizedBox(height: 20),

                // ================= VEHÍCULO MARCADO =================
                if (vm.imagenTipoVehiculo != null) ...[
                  RepaintBoundary(
                    key: _vehiculoKey,
                    child: VehiculoMarcadoWidget(
                      imagePath: vm.imagenTipoVehiculo!,
                      marcas: vm.marcasVehiculo,
                      onTap: vm.agregarMarca,
                    ),
                  ),
                  // VehiculoMarcadoWidget(
                  //   imagePath: vm.imagenTipoVehiculo!,
                  //   marcas: vm.marcasVehiculo,
                  //   onTap: vm.agregarMarca,
                  // ),
                  const SizedBox(height: 12),
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
                _titulo(t.translate(BlockTranslate.vehiculos, 'fechas')),

                _dato(
                  t.translate(BlockTranslate.vehiculos, 'fechaRecibido'),
                  vm.fechaRecibido,
                ),
                _dato(
                  t.translate(
                    BlockTranslate.vehiculos,
                    'vehiculos_fechaEntregaEstimada',
                  ),
                  vm.fechaSalida,
                ),

                const SizedBox(height: 20),

                // ================= OBSERVACIONES =================
                _titulo(t.translate(BlockTranslate.vehiculos, 'observaciones')),

                _dato(
                  t.translate(BlockTranslate.vehiculos, 'detalleTrabajo'),
                  vm.recepcionGuardada?.detalleTrabajo ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'kilometraje'),
                  vm.recepcionGuardada?.kilometraje ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'cc'),
                  vm.recepcionGuardada?.cc ?? '—',
                ),
                _dato(
                  t.translate(BlockTranslate.vehiculos, 'cil'),
                  vm.recepcionGuardada?.cil ?? '—',
                ),

                const SizedBox(height: 30),

                // ================= ÍTEMS =================
                _titulo(
                  t.translate(BlockTranslate.vehiculos, 'itemsVehiculo_titulo'),
                ),

                if (items.isEmpty)
                  Text(t.translate(BlockTranslate.vehiculos, 'noItems'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _itemCard(items[i]),
                  ),

                const SizedBox(height: 30),

                // ================= FIRMAS =================
                _titulo(
                  t.translate(BlockTranslate.vehiculos, 'vehiculos_firmas'),
                ),

                Text(
                  t.translate(
                    BlockTranslate.vehiculos,
                    'vehiculos_firmaMecanico',
                  ),
                ),
                _firmaBox(_firmaMecanico),

                const SizedBox(height: 20),

                Text(
                  t.translate(
                    BlockTranslate.vehiculos,
                    'vehiculos_firmaCliente',
                  ),
                ),
                _firmaBox(_firmaCliente),

                const SizedBox(height: 30),

                // ================= BOTONES ACCIÓN =================
                Center(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.send, color: Colors.white),
                        label: Text(
                          t.translate(
                            BlockTranslate.vehiculos,
                            'vehiculos_enviarDocumento',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),

                        onPressed: (_documentoEnviado || vm.isLoading)
                            ? null
                            : () async {
                                await _enviarDocumento(context);
                              },
                      ),

                      const SizedBox(height: 16),

                      // Compartir Documento
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: Text(
                          t.translate(
                            BlockTranslate.vehiculos,
                            'vehiculos_compartirDocumento',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),

                        onPressed: () async {
                          final vm = context.read<InicioVehiculosViewModel>();
                          final firmaMecBytes = await _firmaMecanico
                              .toPngBytes();
                          final firmaCliBytes = await _firmaCliente
                              .toPngBytes();

                          // Generar PDF temporal
                          await _generarPdf(
                            context,
                            firmaMecanico: firmaMecBytes,
                            firmaCliente: firmaCliBytes,
                          );

                          // Compartir PDF
                          await _compartirDocumento();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nueva Orden
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          t.translate(
                            BlockTranslate.vehiculos,
                            'vehiculos_nuevaOrden',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),

                        onPressed: () {
                          final vm = context.read<InicioVehiculosViewModel>();
                          final elVM = context
                              .read<ElementoAsigandoViewModel>();

                          // ✅ Limpiar datos
                          vm.cancelar();
                          elVM.cancelar();

                          // ✅ Regresar al inicio
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final navigator = Navigator.of(context);
                            try {
                              navigator.pop(); // Cierra DatosGuardadosScreen
                              navigator.pop(); // Cierra ItemsVehiculoScreen
                            } catch (e) {
                              print('Error al navegar: $e');
                              navigator.popUntil((route) => route.isFirst);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
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
          child: Text(
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.vehiculos, 'vehiculos_limpiarFirma'),
          ),
        ),
      ],
    );
  }

  // FUNCIÓN PARA CAPTURAR IMAGen
  Future<Uint8List?> _capturarVehiculo() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final boundary =
          _vehiculoKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturando vehículo: $e');
      return null;
    }
  }

  // GUARDAR COMO ARCHIVO
  Future<String?> _guardarVehiculoTemp(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/vehiculo_marcado.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // Subir Imagen del vehiculo con marcas seleccionadas
  Future<void> _subirImagenVehiculo(BuildContext context) async {
    final user = Provider.of<LoginViewModel>(context, listen: false).user;
    final token = Provider.of<LoginViewModel>(context, listen: false).token;
    final destinoImagenes = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEmpresa!.uploadLocal;

    final vm = context.read<InicioVehiculosViewModel>();

    final bytes = await _capturarVehiculo();
    if (bytes == null) return;

    final path = await _guardarVehiculoTemp(bytes);

    final uploadService = UploadService(); // usa el tuyo real

    if (destinoImagenes == null || destinoImagenes.isEmpty) {
      NotificationService.showSnackbar(
        "Error: No se ha configurado la ruta de destino para las imágenes. Por favor, configure 'uploadLocal' en la sección empresa.",
      );
      return;
    }

    final uploaded = await uploadService.uploadImages(
      imagePaths: [path!],
      token: token,
      user: user,
      urlCarpeta: destinoImagenes,
    );

    //  GUARDAR EN docGlobal (AJUSTA SEGÚN TU MODELO)
    vm.docGlobal?.vehiculoImagen = uploaded.map((e) {
      return TraFileUploadModel(system: e.system, original: e.original);
    }).toList();
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

  Future<void> _compartirDocumento() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/ReporteVehiculo.pdf');

      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Primero debes generar el PDF'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Documento del vehículo');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir documento: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    setState(() {
      _pdfGenerado = true;
    });
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

      //  CARGAR TRANSAcCIONES SI ESTÁN VACÍAS
      if (itemsVM.transaciciones.isEmpty) {
        print('Cargando transacciones desde API...');
        await itemsVM.loadItems(context);
        print(
          'Transacciones después de carga: ${itemsVM.transaciciones.length}',
        );
      }

      // ================= PASO 2: SINCRONIZAR =================
      print('=== PASO 2: Sincronizar ===');
      await vm.sincronizarTransacciones(context);
      // ================= PASO 2.5: SUBIR FOTOS =================
      print('=== PASO 2.5: Subiendo fotos ===');

      print('Total transacciones: ${itemsVM.transaciciones.length}');

      for (var t in itemsVM.transaciciones) {
        print('Producto: ${t.producto.productoId}');
        print('Fotos locales: ${t.files?.length ?? 0}');
      }

      await itemsVM.subirTodasLasFotos(context);

      print('Subida de fotos completada');
      print('=== PASO 2.6: Subiendo imagen vehículo ===');

      await _subirImagenVehiculo(context);
      // Verificar que ahora existan los uploads
      for (var t in itemsVM.transaciciones) {
        print('Producto: ${t.producto.productoId}');
        print('FilesUpload: ${t.filesUpload?.length ?? 0}');
      }
      // ================= DEBUG JSON FINAL =================
      print('=== JSON FINAL A ENVIAR ===');

      final documentoJson = vm.docGlobal?.toJson();
      print(documentoJson);

      // ================= PASO 3: ENVIAR DOCUMENTO =================
      print('=== PASO 3: Enviar documento ===');
      final res = await vm.sendDocument(context);

      if (res.succes) {
        // ✅ Guardar referencias ANTES de cualquier cambio
        final navigator = Navigator.of(context);
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        for (var t in itemsVM.transaciciones) {
          print({
            "producto": t.producto.productoId,
            "filesUpload": t.filesUpload?.map((e) => e.system).toList(),
          });
        }

        // ✅ Mostrar mensaje (usando la referencia guardada)
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Documento enviado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          _documentoEnviado = true;
        });
      } else {
        //  ERROR
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              res.response?.toString() ?? ' Error al enviar documento',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      vm.setLoading(false);
    }
  }
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
