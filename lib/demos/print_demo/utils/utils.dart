import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class UtilitiesService {
  static String version = "v4.1.1";
  static String nombreEmpresa = "\u00A9 Desarrollo Moderno de Software S.A.";
  static String logo = "packages/core/assets/logo.png";
  static final Map<String, Uint8List> _cache = {};
  static final List<String> _cacheKeys = [];
  static const int _cacheLimit = 5;

  int _backGestureCount = 0;

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  void dispose() {}

  /// Formatea un número agregando comas como separadores de miles y asegurando que tenga dos decimales.
  String formatNumberCustom(double number) {
    String num = number.toStringAsFixed(2); // Asegura 2 decimales
    List<String> parts = num.split('.'); // Separa enteros de decimales
    String integerPart = parts[0];
    String decimalPart = parts[1];

    // Añade comas cada 3 dígitos (por la derecha)
    RegExp reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    String formattedInteger = integerPart.replaceAllMapped(
      reg,
      (match) => ',${match.group(0)}',
    );

    return '$formattedInteger.$decimalPart';
  }

  String validarCampo(String? valor) {
    return (valor == null || valor.trim().isEmpty) ? "N/A" : valor;
  }

  String formatearFecha(String? fechaOriginal) {
    if (fechaOriginal == null || fechaOriginal.isEmpty) return '';
    try {
      DateTime fecha = DateTime.parse(fechaOriginal);
      return '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    } catch (e) {
      // Si no es fecha válida, devolver el valor original
      return fechaOriginal;
    }
  }

  String formatearFechaHora(String? fechaOriginal) {
    if (fechaOriginal == null || fechaOriginal.isEmpty) return '';
    try {
      DateTime fecha = DateTime.parse(fechaOriginal);

      final formatter = DateFormat('MM/dd/yy, h:mm a');
      return formatter.format(fecha);
    } catch (e) {
      return fechaOriginal;
    }
  }

  // Función para manejar el evento de "back"
  Future<bool> onWillPop(BuildContext context) async {
    if (_backGestureCount == 0) {
      _backGestureCount++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Si vuelves a regresar se cerrará la aplicación"),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );

      // Evita que el closure pierda referencia
      Future.delayed(const Duration(seconds: 2), () {
        _backGestureCount = 0;
      });

      return false;
    } else {
      _backGestureCount = 0;
      SystemNavigator.pop();
      return true;
    }
  }

  Future<Uint8List?> prepararImagenParaImpresion(Uint8List original) async {
    // Redimensiona y comprime la imagen
    return await FlutterImageCompress.compressWithList(
      original,
      minHeight: 100,
      minWidth: 200,
      quality: 50, // Baja calidad para impresión
      format: CompressFormat.jpeg,
    );
  }

  static Future<File> _getLocalFile(String url) async {
    final dir = await getTemporaryDirectory();
    final filename = Uri.parse(url).pathSegments.last;
    return File('${dir.path}/$filename');
  }

  static Future<Uint8List?> loadLogoImage(String pathImage) async {
    try {
      // Si la imagen ya está en caché, la retornamos y actualizamos orden
      if (_cache.containsKey(pathImage)) {
        // Actualizamos la posición de la clave para mantenerla al final (más reciente)
        _cacheKeys.remove(pathImage);
        _cacheKeys.add(pathImage);
        return _cache[pathImage];
      }

      Uint8List? imageData;

      if (pathImage.startsWith('http')) {
        final File localFile = await _getLocalFile(pathImage);
        if (await localFile.exists()) {
          imageData = await localFile.readAsBytes();
        } else {
          final response = await http.get(Uri.parse(pathImage));
          if (response.statusCode == 200) {
            imageData = response.bodyBytes;
            await localFile.writeAsBytes(imageData);
          } else {
            throw Exception(
              'Error al descargar la imagen: ${response.statusCode}',
            );
          }
        }
      } else if (pathImage.startsWith('assets/') ||
          pathImage.startsWith('packages/')) {
        final ByteData data = await rootBundle.load(pathImage);
        imageData = data.buffer.asUint8List();
      } else {
        final File file = File(pathImage);
        if (await file.exists()) {
          imageData = await file.readAsBytes();
        } else {
          throw Exception('La imagen no existe en la ruta: $pathImage');
        }
      }

      if (imageData != null && imageData.isNotEmpty) {
        // Si el cache ya está lleno, eliminamos la imagen menos usada (la primera en _cacheKeys)
        if (_cacheKeys.length >= _cacheLimit) {
          String oldestKey = _cacheKeys.removeAt(0);
          _cache.remove(oldestKey);
        }

        // Agregamos la nueva imagen a cache y actualizamos las keys
        _cache[pathImage] = imageData;
        _cacheKeys.add(pathImage);

        return imageData;
      } else {
        throw Exception('La imagen cargada está vacía o es nula.');
      }
    } catch (e) {
      debugPrint('Error al cargar imagen: $e');
      return null;
    }
  }
}
