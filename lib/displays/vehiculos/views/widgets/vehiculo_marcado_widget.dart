import 'package:fl_business/displays/vehiculos/models/marcar_vehiculo_model.dart';
import 'package:flutter/material.dart';

class VehiculoMarcadoWidget extends StatelessWidget {
  final String imagePath;
  final List<MarcaVehiculo> marcas;
  final void Function(double x, double y) onTap;

  const VehiculoMarcadoWidget({
    super.key,
    required this.imagePath,
    required this.marcas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) {
        final pos = d.localPosition;
        onTap(pos.dx, pos.dy);
      },
      child: Stack(
        children: [
          Image.asset(imagePath, height: 250, fit: BoxFit.contain),
          CustomPaint(
            size: const Size(double.infinity, 250),
            painter: _MarcasPainter(marcas),
          ),
        ],
      ),
    );
  }
}

class _MarcasPainter extends CustomPainter {
  final List<MarcaVehiculo> marcas;

  _MarcasPainter(this.marcas);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final m in marcas) {
      canvas.drawCircle(Offset(m.x, m.y), 12, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}