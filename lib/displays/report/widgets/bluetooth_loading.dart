import 'package:fl_business/themes/app_theme.dart';
import 'package:flutter/material.dart';

class BluetoothLoadingWidget extends StatelessWidget {
  const BluetoothLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_searching,
                size: 80,
                color: AppTheme.primary,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 20),
              //TODO:Translate
              Text(
                'Buscando dispositivos Bluetooth...',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
