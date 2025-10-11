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

class SelectLocationView extends StatelessWidget {
  const SelectLocationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int tipoAccion = ModalRoute.of(context)!.settings.arguments as int;

    final vm = Provider.of<LocationsViewModel>(context);
    final TransferSummaryViewModel transferVM =
        Provider.of<TransferSummaryViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.restaurante, 'nuevaUbicacion'),
                  style: StyleApp.title,
                ),
                RegisterCountWidget(count: vm.locations.length),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => vm.loadData(context),
                    child: ListView.builder(
                      itemCount: vm.locations.length,
                      itemBuilder: (BuildContext context, int index) {
                        LocationModel location = vm.locations[index];
                        return CardLocationsWidget(
                          ubicacion: location,
                          onTap: () {
                            transferVM.setLocationDest(location);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.selectTable,
                              arguments: tipoAccion,
                            );
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
