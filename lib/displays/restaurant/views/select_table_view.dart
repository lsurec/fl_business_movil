import 'package:flutter/material.dart';
import 'package:fl_business/displays/restaurant/models/models.dart';
import 'package:fl_business/displays/restaurant/view_models/view_models.dart';
import 'package:fl_business/displays/restaurant/widgets/widgets.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:provider/provider.dart';

class SelectTableView extends StatelessWidget {
  const SelectTableView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final int tipoAccion = ModalRoute.of(context)!.settings.arguments as int;

    final vm = Provider.of<TablesViewModel>(context);
    final vmLoc = Provider.of<LocationsViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(vmLoc.location!.descripcion, style: StyleApp.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.restaurante, 'nuevaMesa'),
                  style: StyleApp.title,
                ),
                RegisterCountWidget(count: vm.tables.length),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => vm.loadData(context),
                    child: ListView.builder(
                      itemCount: vm.tables.length,
                      itemBuilder: (BuildContext context, int index) {
                        TableModel table = vm.tables[index];
                        return CardTableWidget(
                          mesa: table,
                          onTap: () {
                            //Al terminar restaurar mesa

                            final TablesViewModel tableVM =
                                Provider.of<TablesViewModel>(
                                  context,
                                  listen: false,
                                );

                            final TransferSummaryViewModel transferVM =
                                Provider.of<TransferSummaryViewModel>(
                                  context,
                                  listen: false,
                                );

                            tableVM.selectNewtable(table);

                            transferVM.setTableDest(table);

                            if (tipoAccion == 45) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.selectAccount,
                                arguments: {"screen": 3, "action": tipoAccion},
                              );
                              return;
                            }

                            if (transferVM.locationDest!.elementoAsignado ==
                                    transferVM
                                        .locationOrigin!
                                        .elementoAsignado &&
                                transferVM.tableDest!.elementoAsignado ==
                                    transferVM.tableOrigin!.elementoAsignado) {
                              NotificationService.showSnackbar(
                                AppLocalizations.of(context)!.translate(
                                  BlockTranslate.restaurante,
                                  'cuentaExisteMesa',
                                ),
                              );
                              return;
                            }

                            if (tipoAccion == 32) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.transferSummary,
                                arguments: tipoAccion,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoading)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
      ],
    );
  }
}
