import 'package:fl_business/displays/vehiculos/models/marcar_vehiculo_model.dart';
import 'package:flutter/material.dart';

class VehiculoMarcadoWidget extends StatefulWidget {
  final String imagePath;
  final List<MarcaVehiculo> marcas;
  final void Function(double x, double y)? onTap;
  final bool readOnly;

  const VehiculoMarcadoWidget({
    super.key,
    required this.imagePath,
    required this.marcas,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<VehiculoMarcadoWidget> createState() => _VehiculoMarcadoWidgetState();
}

class _VehiculoMarcadoWidgetState extends State<VehiculoMarcadoWidget> {
  double? _imageRatio;

  @override
  void initState() {
    super.initState();
    _loadImageRatio();
  }

  void _loadImageRatio() {
    final image = AssetImage(widget.imagePath);
    final stream = image.resolve(const ImageConfiguration());

    stream.addListener(
      ImageStreamListener((info, _) {
        final width = info.image.width.toDouble();
        final height = info.image.height.toDouble();

        if (mounted) {
          setState(() {
            _imageRatio = width / height;
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_imageRatio == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        const containerHeight = 250.0;
        final imageRatio = _imageRatio!;

        double imageWidth;
        double imageHeight;

        // 🔹 BoxFit.contain real
        if (containerWidth / containerHeight > imageRatio) {
          imageHeight = containerHeight;
          imageWidth = imageHeight * imageRatio;
        } else {
          imageWidth = containerWidth;
          imageHeight = imageWidth / imageRatio;
        }

        final offsetX = (containerWidth - imageWidth) / 2;
        final offsetY = (containerHeight - imageHeight) / 2;

        return GestureDetector(
          onTapDown: widget.readOnly
              ? null
              : (d) {
                  if (widget.onTap == null) return;

                  final pos = d.localPosition;

                  //  ignorar taps fuera de la imagen
                  if (pos.dx < offsetX ||
                      pos.dx > offsetX + imageWidth ||
                      pos.dy < offsetY ||
                      pos.dy > offsetY + imageHeight) {
                    return;
                  }

                  final dx = pos.dx - offsetX;
                  final dy = pos.dy - offsetY;

                  widget.onTap!(
                    dx / imageWidth,
                    dy / imageHeight,
                  );
                },
          child: SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: Stack(
              children: [
                // ================= IMAGEN =================
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  child: Image.asset(
                    widget.imagePath,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),

                // ================= MARCAS =================
                CustomPaint(
                  size: Size(containerWidth, containerHeight),
                  painter: _MarcasPainter(
                    widget.marcas,
                    offsetX,
                    offsetY,
                    imageWidth,
                    imageHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MarcasPainter extends CustomPainter {
  final List<MarcaVehiculo> marcas;
  final double offsetX;
  final double offsetY;
  final double imageWidth;
  final double imageHeight;

  _MarcasPainter(
    this.marcas,
    this.offsetX,
    this.offsetY,
    this.imageWidth,
    this.imageHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;

    for (int i = 0; i < marcas.length; i++) {
      final m = marcas[i];

      final dx = offsetX + (m.x * imageWidth);
      final dy = offsetY + (m.y * imageHeight);

      //  círculo
      canvas.drawCircle(Offset(dx, dy), 12, paint);

      //  número
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}', //  número consecutivo
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          dx - textPainter.width / 2,
          dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MarcasPainter oldDelegate) {
    return oldDelegate.marcas != marcas;
  }
}
