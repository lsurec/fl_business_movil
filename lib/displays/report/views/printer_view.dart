import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/displays/report/widgets/bluetooth_loading.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/themes/styles.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/load_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrinterView extends StatelessWidget {
  const PrinterView({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterViewModel vm = Provider.of<PrinterViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 80,
            child: ElevatedButton(
              onPressed: () => vm.printTest(context),
              // onPressed: () => vm.printTestV2(context),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.impresora, "prueba"),
                    style: StyleApp.whiteBold,
                  ),
                ),
              ),
            ),
          ),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.impresora, "impresion"),
              style: StyleApp.title,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  NotificationService.showInfoPrint(context);
                },
                icon: const Icon(Icons.help_outline, size: 20),
                tooltip: "Ayuda",
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.impresora, "conectado"),
                  style: StyleApp.title,
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    Preferences.printer == null
                        ? "Sin impresora"
                        : Preferences.printer!.name ?? "Desconocido",
                    style: StyleApp.normal,
                  ),
                  subtitle: Text(
                    "${Preferences.printer == null ? "Sin impresora" : Preferences.printer!.address ?? "Desconocido"} | ${AppLocalizations.of(context)!.translate(BlockTranslate.impresora, "papelT")} ${Preferences.paperSize} mm",
                    style: StyleApp.subTitle,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: Preferences.printer == null
                            ? () => NotificationService.showSnackbar(
                                "No hay impresora",
                              )
                            : () =>
                                  vm.savePrinter(context, Preferences.printer!),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => vm.deletePrinter(),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.bluetooth,
                    color: AppTheme.primary, //cambia color segun la conexion
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.translate(BlockTranslate.impresora, "disponibles")} (${vm.devices.length})",
                      style: StyleApp.title,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Volver a buscar',
                      onPressed: () => vm.getDevices(),
                      color: AppTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: vm.devices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bluetooth_disabled,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No hay dispositivos vinculados",
                                style: StyleApp.normal,
                              ),
                              TextButton(
                                child: Text(
                                  "Ir a configuracion",
                                  style: StyleApp.enlace,
                                ),
                                onPressed: () => vm.goSettings(),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: vm.devices.length,
                          itemBuilder: (context, index) {
                            BluetoothDevice device = vm.devices[index];

                            return ListTile(
                              title: Text(
                                device.name ?? "Desconocido", //TODO:Translate
                                style: StyleApp.normal,
                              ),
                              subtitle: Text(
                                device.address ??
                                    "Desconocido", //TODO:Translate
                                style: StyleApp.subTitle,
                              ),
                              onTap: () => vm.savePrinter(context, device),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoadingDevices || vm.isLoading)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoadingDevices) const BluetoothLoadingWidget(),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }
}
