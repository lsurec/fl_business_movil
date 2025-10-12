import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:flutter/material.dart';

class PrinterViewModel extends ChangeNotifier {
  PrinterViewModel() {
    getDevices();
  }
  //manejo carga de dispositivos
  bool _isLoading = false;
  bool get isLoadingDevices => _isLoading;

  set isLoadingDevices(bool value) {
    _isLoading = value;
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

    //TODO:Guardar impresora y papel en preferencias
  }
}
