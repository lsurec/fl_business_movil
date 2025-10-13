import 'dart:io';
import 'dart:typed_data';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fl_business/displays/report/reports/test/tmu.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/alert_widget.dart';
import 'package:flutter/material.dart';

//TODO:Translate
class PrinterViewModel extends ChangeNotifier {
  PrinterViewModel() {
    getDevices();
  }

  //carga generica
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  //manejo carga de dispositivos
  bool _isLoadingDevices = false;
  bool get isLoadingDevices => _isLoadingDevices;

  set isLoadingDevices(bool value) {
    _isLoadingDevices = value;
    notifyListeners();
  }

  //Guardar como predeterminada
  bool _savePrint = true;
  bool get savePrint => _savePrint;

  set savePrint(bool value) {
    _savePrint = value;
    notifyListeners();
  }

  // Instancia de la impresora
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final List<BluetoothDevice> devices = [];

  Future<void> getDevices() async {
    isLoadingDevices = true;

    devices.clear();

    devices.addAll(
      await bluetooth.getBondedDevices().timeout(Duration(seconds: 8)),
    );

    isLoadingDevices = false;
  }

  deletePrinter() {
    Preferences.clearPrinter();
    notifyListeners();
  }

  Future<void> savePrinter(BuildContext context, BluetoothDevice device) async {
    final int? paperSize = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.impresora, "papelT"),
          style: StyleApp.title,
        ),
        backgroundColor: AppTheme.isDark()
            ? AppTheme.darkBackroundColor
            : AppTheme.backroundColor,

        children: [
          ...[58, 72, 80].map(
            (size) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, size),
              child: Text("$size mm", style: StyleApp.normal),
            ),
          ),
        ],
      ),
    );

    if (paperSize == null) return;

    Preferences.printer = device;
    Preferences.paperSize = paperSize;

    NotificationService.showSnackbar("Impresora guardada");
  }

  Future<void> printTest(BuildContext context) async {
    final TestTMU testTMU = TestTMU();

    isLoading = true;
    final bool resReport = await testTMU.getReport(context);

    isLoading = false;
    if (!resReport) {
      return;
    }
    await printTMU(context, testTMU.report, true);
  }

  Future<bool> printTMU(
    BuildContext context,
    List<int> report,
    bool isTest,
  ) async {
    try {
      if (Preferences.printer == null) {
        final String message = "No hay ninguna impresora configurada";

        if (!isTest) {
          setPrinter(context, report, isTest, message);
          return false;
        }

        NotificationService.showSnackbar(message);
        return false;
      }

      final bool isAvailable = await isAvailableBluetooth(context);

      if (!isAvailable) return false;

      //Desconectar instancias
      await disconnectPrint();

      bool isConnect = await connectPrint(context);

      if (!isConnect) {
        final bool viewPrints = await showInfoPrint(context);

        if (viewPrints) {
          setPrinter(context, report, isTest, "Dispositivos");

          return false;
        }

        return false;
      }

      //imprimir reporte
      await bluetooth.writeBytes(Uint8List.fromList(report));

      //desconectar impresora
      await disconnectPrint();

      return true;
    } catch (e) {
      NotificationService.showSnackbar("Algo salió mal, intenta más tarde.");
      return false;
    }
  }

  /// 🔹 Mostrar error de conexión y opción para ir a ajustes
  void showSettings(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Aceptar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (Platform.isAndroid) {
                final intent = AndroidIntent(
                  action: 'android.settings.BLUETOOTH_SETTINGS',
                  flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
                );
                intent.launch();
              }
            },
            child: Text('Ir a configuración'),
          ),
        ],
      ),
    );
  }

  Future<bool> showInfoPrint(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(
                  context,
                )!.translate(BlockTranslate.impresora, "problema"),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "pasos"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "encendida"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "modo"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "vinculada"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "papel"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "salidaPapel"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "usarCorrecta"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "correcta"),
                  ),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "dispositivo"),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "soporte"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.botones, "cerrar"),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Ver Impresoras'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// 🔹 Obtener y seleccionar impresora
  Future<void> setPrinter(
    BuildContext context,
    List<int> report,
    bool isTest,
    String message,
  ) async {
    await getDevices();

    if (devices.isEmpty) {
      showSettings(context, "No hay dispositivos vinculados.");
      return;
    }

    // Si hay varias, mostrar lista
    final BluetoothDevice? device = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(message),
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

    if (device == null) return;

    //Obtner impresora guardada en preferencias
    final BluetoothDevice? defaultPrint = Preferences.printer;
    final int? defaultSizePaper = Preferences.paperSize;

    Preferences.printer = device;
    Preferences.paperSize = 58;

    final bool succesPrint = await printTMU(context, report, isTest);

    if (succesPrint) {
      //Solicitar guardar como predeterminado
      final bool savePrint = await setPrintDefault(context, device);

      if (!savePrint && defaultPrint != null) {
        Preferences.printer = defaultPrint;
        Preferences.paperSize = defaultSizePaper ?? 58;
      }
    }
  }

  //Estbalecer impresora como predeterminada
  Future<bool> setPrintDefault(
    BuildContext context,
    BluetoothDevice device,
  ) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertWidget(
            title: "Establecer como predeterminada",
            description:
                "¿Establecer ${device.name} como impresora predeterminada?",
            onOk: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
        ) ??
        false;
  }

  //Conectar impresora
  Future<bool> connectPrint(BuildContext context) async {
    try {
      await bluetooth.connect(Preferences.printer!);
      await Future.delayed(const Duration(seconds: 2));

      bool? isConnected = await bluetooth.isConnected;
      if (isConnected != true) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  //desconectar bluethoth si está conectado
  Future<void> disconnectPrint() async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == true) {
      await bluetooth.disconnect();
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  //Validar si el bluetooth está encendido y disponible
  Future<bool> isAvailableBluetooth(BuildContext context) async {
    bool? isAvailable = await bluetooth.isAvailable;
    if (isAvailable == false) {
      showSettings(
        context,
        "El Bluetooth del dispositivo no está disponible o está desactivado.",
      );

      return false;
    }
    return true;
  }
}
