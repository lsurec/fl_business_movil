import 'dart:io';
import 'package:flutter/material.dart';

class VistaImagenScreen extends StatelessWidget {
  final String imagePath;

  const VistaImagenScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // 💡 Obtenemos el ancho físico real de la pantalla del dispositivo
    final double anchoPantalla = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale:
                4.0, // Reducir ligeramente de 5 a 4 ayuda a no sobrecargar los pixeles en memoria
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              cacheWidth: anchoPantalla.toInt(),
            ),
          ),
        ),
      ),
    );
  }
}
