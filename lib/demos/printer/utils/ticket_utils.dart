import 'dart:io';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class TicketUtils {
  // Instancia de la impresora
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  /// 🔹 Verificar si el dispositivo tiene Bluetooth
  Future<bool> verificarBluetoothDisponible(BuildContext context) async {
    bool? isAvailable = await bluetooth.isAvailable;
    if (isAvailable == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("El dispositivo no tiene Bluetooth disponible."),
        ),
      );
      return false;
    }
    return true;
  }

  /// 🔹 Desconectar si ya estaba conectado
  Future<void> desconectarSiConectado() async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      await bluetooth.disconnect();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// 🔹 Obtener y seleccionar impresora
  Future<BluetoothDevice?> seleccionarImpresora(BuildContext context) async {
    List<BluetoothDevice> devices = await bluetooth.getBondedDevices();

    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ No hay dispositivos vinculados.')),
      );
      return null;
    }

    // Si solo hay una impresora vinculada, seleccionarla directamente
    if (devices.length == 1) {
      return devices.first;
    }

    // Si hay varias, mostrar lista
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Seleccionar impresora"),
        children: devices
            .map(
              (device) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, device),
                child: Text(device.name ?? device.address ?? "Desconocido"),
              ),
            )
            .toList(),
      ),
    );
  }

  /// 🔹 Conectar con la impresora seleccionada
  Future<bool> conectarImpresora(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    try {
      await bluetooth.connect(device);
      await Future.delayed(const Duration(seconds: 2));

      bool? isConnected = await bluetooth.isConnected;
      if (isConnected != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Impresora no conectada. No se puede imprimir.'),
          ),
        );
        return false;
      }
      return true;
    } catch (e) {
      _mostrarErrorConexion(context);
      return false;
    }
  }

  /// 🔹 Mostrar error de conexión y opción para ir a ajustes
  void _mostrarErrorConexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error de conexión'),
        content: Text(
          '❌ No se pudo conectar con la impresora.\n\n'
          'Presiona "Ir a configuración" para conectarla manualmente. '
          'Luego regresa y vuelve a intentar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              abrirConfiguracionBluetooth();
            },
            child: Text('Ir a configuración'),
          ),
        ],
      ),
    );
  }

  /// 🔹 Abrir configuración de Bluetooth
  void abrirConfiguracionBluetooth() {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.BLUETOOTH_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      intent.launch();
    }
  }

  //Función para omitir acentos en impresion
  String removeAccents(String input) {
    return input
        .replaceAll("á", "a")
        .replaceAll("é", "e")
        .replaceAll("í", "i")
        .replaceAll("ó", "o")
        .replaceAll("ú", "u")
        .replaceAll("ñ", "n")
        .replaceAll("Á", "A")
        .replaceAll("É", "E")
        .replaceAll("Í", "I")
        .replaceAll("Ó", "O")
        .replaceAll("Ú", "U")
        .replaceAll("Ñ", "N");
  }

  /// 🔹 Utilitario para imprimir texto personalizado
  Future<void> imprimirTexto(
    String texto, {
    int size = 1,
    int align = 0,
  }) async {
    final sanitized = removeAccents(texto);
    await bluetooth.printCustom(sanitized, size, align);
  }
}
