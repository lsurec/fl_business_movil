// ignore_for_file: use_build_context_synchronously

import 'package:fl_business/displays/report/reports/estado_cuenta/estado_cuenta_model.dart';
import 'package:fl_business/displays/report/services/report_service.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/models/api_response_model.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:fl_business/displays/restaurant/models/models.dart';
import 'package:fl_business/displays/restaurant/view_models/view_models.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:provider/provider.dart';
import 'package:fl_business/libraries/app_data.dart'
    // ignore: library_prefixes
    as AppData;

class SelectAccountViewModel extends ChangeNotifier {
  // final PrinterManager instanceManager = PrinterManager.instance;

  bool isSelectedMode = false;

  setIsSelectedMode(BuildContext context, bool value) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    if (!value) {
      for (var i = 0; i < orderVM.orders.length; i++) {
        orderVM.orders[i].selected = value;
      }
    }

    isSelectedMode = value;

    notifyListeners();
  }

  Future<void> printStatusAccount(BuildContext context, int consecutivo) async {
    //Proveedores externos
    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    //usario
    String user = loginVM.user;
    //token
    String token = loginVM.token;

    final ReportService reportService = ReportService();

    ApiResponseModel res = await reportService.getEstadoCuenta(
      token,
      user,
      consecutivo,
    );

    //valid succes response
    if (!res.status) {
      //finalozar el proceso
      await NotificationService.showInfoErrorView(context, res);
      return;
    }

    final List<EstadoCuentaModel> data = res.data;

    if (data.isEmpty) {
      NotificationService.showSnackbar("No hay datos para imprimir");
      return;
    }

    try {
      PosStyles center = const PosStyles(align: PosAlign.center);

      List<int> bytes = [];
      final generator = Generator(
        AppData.paperSize[Preferences.paperSize],
        await CapabilityProfile.load(),
      );

      bytes += generator.setGlobalCodeTable('CP1252');

      bytes += generator.text(
        "Club campestre la montaña",
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        "Barra mirablosque",
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        "Mesa: ${data[0].desMesa}",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
        ),
      );

      bytes += generator.text(
        "MIRALBOLSQUE - 1",
        styles: const PosStyles(
          bold: true,
          align: PosAlign.center,
          height: PosTextSize.size2,
        ),
      );

      bytes += generator.emptyLines(1);

      for (var item in data) {
        bytes += generator.text("Cant: ${item.cantidad}");
        bytes += generator.text(item.desProducto);
        bytes += generator.hr();
      }

      bytes += generator.emptyLines(1);

      bytes += generator.row([
        PosColumn(
          text: "Propina:",
          width: 8,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: "_______________",
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.text("Propina:");
      bytes += generator.hr();

      bytes += generator.text("Nombre:");
      bytes += generator.hr();
      bytes += generator.text("NIT:");
      bytes += generator.hr();

      bytes += generator.text("Celular:");
      bytes += generator.hr();

      bytes += generator.text("Email:");
      bytes += generator.hr();

      bytes += generator.text("Le atendió: ");
      bytes += generator.emptyLines(1);
      bytes += generator.text(Utilities.getDateDDMMYYYY());

      bytes += generator.emptyLines(1);
      bytes += generator.hr();

      bytes += generator.emptyLines(1);

      bytes += generator.text("Powered By:", styles: center);

      bytes += generator.text(Utilities.author.nombre, styles: center);
      bytes += generator.text(Utilities.author.website, styles: center);

      bytes += generator.cut();

      final PrinterViewModel vmPrint = Provider.of<PrinterViewModel>(
        context,
        listen: false,
      );

      await vmPrint.printTMU(context, bytes, false);
    } catch (e) {
      // isLoading = false;
      NotificationService.showSnackbar(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'noImprimio'),
      );

      return;
    }
  }

  navigatePermisionView(BuildContext context) {
    final TablesViewModel tablesVM = Provider.of<TablesViewModel>(
      context,
      listen: false,
    );

    final LocationsViewModel locVM = Provider.of<LocationsViewModel>(
      context,
      listen: false,
    );

    final TransferSummaryViewModel transerVM =
        Provider.of<TransferSummaryViewModel>(context, listen: false);

    transerVM.tableOrigin = tablesVM.table;
    transerVM.locationOrigin = locVM.location;

    Navigator.pushNamed(
      context,
      AppRoutes.permisions,
      arguments: 32, // 45 trasladar transaccion
    );
  }

  navigateDetails(BuildContext context, int index) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    if (orderVM.orders[index].transacciones.isEmpty) {
      NotificationService.showSnackbar(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.notificacion, 'sinTransaccionesMostrar'),
      );

      return;
    }

    Navigator.pushNamed(context, AppRoutes.order, arguments: index);
  }

  tapCard(
    BuildContext context,
    int screen,
    int index,
    TraRestaurantModel? transaction,
    int tipoAccion,
  ) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    switch (screen) {
      case 1: //Agreagr Transacion
        orderVM.addTransactionToOrder(context, transaction!, index);
        break;

      case 2: //Detalles
        navigateDetails(context, index);
        break;

      case 3: //traslado

        final TransferSummaryViewModel transferVM =
            Provider.of<TransferSummaryViewModel>(context, listen: false);

        if (transferVM.tableOrigin!.elementoAsignado ==
                transferVM.tableDest!.elementoAsignado &&
            transferVM.locationOrigin!.elementoAsignado ==
                transferVM.locationDest!.elementoAsignado &&
            transferVM.indexOrderOrigin == index) {
          NotificationService.showSnackbar(
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.notificacion, 'traExisteCuenta'),
          );
          return;
        }

        transferVM.indexOrderDest = index;

        Navigator.pushNamed(
          context,
          AppRoutes.transferSummary,
          arguments: tipoAccion,
        );
        break;
      default:
    }
  }

  selectedItem(BuildContext context, int indexOrder) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    orderVM.orders[indexOrder].selected = !orderVM.orders[indexOrder].selected;
    notifyListeners();

    if (getSelectedItems(context) == 0) setIsSelectedMode(context, false);
  }

  onLongPress(BuildContext context, int indexOrder) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    orderVM.orders[indexOrder].selected = true;

    setIsSelectedMode(context, true);
  }

  deleteItemsRecursive(BuildContext context) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    final TablesViewModel tablesVM = Provider.of<TablesViewModel>(
      context,
      listen: false,
    );

    for (var i = 0; i < orderVM.orders.length; i++) {
      if (orderVM.orders[i].selected) {
        int comandada = 0;

        for (var element in orderVM.orders[i].transacciones) {
          if (element.processed) {
            comandada++;
          }
        }

        if (comandada == 0) {
          orderVM.orders.removeAt(i);
          deleteItemsRecursive(context);
          break;
        }
      }
    }

    tablesVM.updateOrdersTable(context);

    notifyListeners();
  }

  deleteItems(BuildContext context) {
    final TablesViewModel tablesVM = Provider.of<TablesViewModel>(
      context,
      listen: false,
    );

    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertWidget(
        title: "¿Estás seguro?",
        description:
            "Estas a punto de eliminar las cuentas seleccionadas. Esta accion no se puede deshacer.",
        onOk: () {
          //Cerrar sesión, limpiar datos
          Navigator.of(context).pop();

          int comandada = 0;

          for (var element in orderVM.orders) {
            for (var i = 0; i < element.transacciones.length; i++) {
              if (element.transacciones[i].processed) {
                comandada++;
                break;
              }
            }
          }

          deleteItemsRecursive(context);

          if (tablesVM.table!.orders!.isEmpty) {
            Navigator.of(context).pop();
          }

          setIsSelectedMode(context, false);
          notifyListeners();

          if (comandada != 0) {
            NotificationService.showSnackbar(
              AppLocalizations.of(context)!.translate(
                BlockTranslate.notificacion,
                'comandadasNoModificar',
              ),
            );
            return;
          }

          NotificationService.showSnackbar(
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.notificacion, 'cuentasEliminadas'),
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  selectedAll(BuildContext context) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    final TablesViewModel tablesVM = Provider.of<TablesViewModel>(
      context,
      listen: false,
    );

    if (getSelectedItems(context) == tablesVM.table!.orders!.length) {
      for (var element in tablesVM.table!.orders!) {
        orderVM.orders[element].selected = false;
      }

      // isSelectedMode = false;
    } else {
      for (var element in tablesVM.table!.orders!) {
        orderVM.orders[element].selected = true;
      }
    }

    notifyListeners();
  }

  getSelectedItems(BuildContext context) {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    return orderVM.orders.where((order) => order.selected).toList().length;
  }

  //Salir de la pantalla
  Future<bool> backPage(BuildContext context) async {
    final OrderViewModel orderVM = Provider.of<OrderViewModel>(
      context,
      listen: false,
    );

    if (!isSelectedMode) return true;

    setIsSelectedMode(context, false);

    for (var element in orderVM.orders) {
      element.selected = false;
    }

    notifyListeners();

    return false;
  }
}
