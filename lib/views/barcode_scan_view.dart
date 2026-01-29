import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanView extends StatelessWidget {
  const BarcodeScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          formats: [
            BarcodeFormat.code128,
            BarcodeFormat.ean13,
            BarcodeFormat.ean8,
          ],
        ),
        onDetect: (barcode) {
          final String? code = barcode.barcodes.first.rawValue;
          if (code != null) {
            Navigator.pop(context, code); // ← DEVUELVE EL RESULTADO
          }
        },
      ),
    );
  }
}
