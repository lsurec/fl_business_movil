// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_business/displays/restaurant/view_models/select_account_view_model.dart';
import 'package:fl_business/displays/restaurant/widgets/button_details_widget.dart';
import 'package:fl_business/displays/restaurant/models/classification_model.dart';
import 'package:fl_business/displays/restaurant/view_models/classification_view_model.dart';
import 'package:fl_business/displays/restaurant/view_models/locations_view_model.dart';
import 'package:fl_business/displays/restaurant/view_models/tables_view_model.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ClassificationView extends StatelessWidget {
  const ClassificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final vmLoc = Provider.of<LocationsViewModel>(context);
    final vmTables = Provider.of<TablesViewModel>(context);
    final vm = Provider.of<ClassificationViewModel>(context);
    final SelectAccountViewModel selectAccountVM =
        Provider.of<SelectAccountViewModel>(context);

    return WillPopScope(
      onWillPop: () => vm.backPage(context),
      child: Stack(
        children: [
          Scaffold(
            bottomNavigationBar: vmTables.table!.orders!.isEmpty
                ? null
                : const ButtonDetailsWidget(),
            appBar: AppBar(
              title: Text(vmTables.table!.descripcion, style: StyleApp.title),
              actions: [
                PopupMenuButton<int>(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: Text(
                        AppLocalizations.of(context)!.translate(
                          BlockTranslate.restaurante,
                          'trasladarMesa',
                        ),
                      ),
                    ),
                  ],
                  // color: AppTheme.backroundColor,
                  elevation: 2,
                  // on selected we show the dialog box
                  onSelected: (value) =>
                      selectAccountVM.navigatePermisionView(context),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => vmLoc.backLocationsView(context),
                                child: Text(
                                  AppLocalizations.of(context)!.translate(
                                    BlockTranslate.restaurante,
                                    'ubicaciones',
                                  ),
                                  style: StyleApp.normal,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => vmTables.backTablesView(context),
                                child: Text(
                                  "${vmLoc.location!.descripcion}/",
                                  style: StyleApp.normal,
                                ),
                              ),
                              Text(
                                vmTables.table!.descripcion,
                                style: StyleApp.normalBold,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RegisterCountWidget(count: vm.totalLength),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => vm.loadData(context),
                      child: ListView.builder(
                        itemCount: vm.menu.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _RowMenu(classification: vm.menu[index]);
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
      ),
    );
  }
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({Key? key, required this.classification}) : super(key: key);

  final List<ClassificationModel> classification;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CardViewMore(classification: classification[0]),
        if (classification.length == 2)
          CardViewMore(classification: classification[1]),
        if (classification.length == 1) Expanded(child: Container()),
      ],
    );
  }
}

class CardViewMore extends StatelessWidget {
  const CardViewMore({super.key, required this.classification});

  final ClassificationModel classification;

  @override
  Widget build(BuildContext context) {
    final ClassificationViewModel vm = Provider.of<ClassificationViewModel>(
      context,
    );

    return Expanded(
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            InkWell(
              onTap: () => vm.navigateProduct(context, classification),

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen superior
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: classification.urlImg!.isEmpty
                          ? Image.asset(
                              "assets/image_not_available.png",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : FadeInImage(
                              placeholder: const AssetImage("assets/load.gif"),
                              image: NetworkImage(classification.urlImg!),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                // Aquí se maneja el error y se muestra una imagen alternativa
                                return Image.asset(
                                  'assets/image_not_available.png',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classification.desClasificacion,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: StyleApp.normal,
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.backroundColor,
                      title: Text("Categoría", style: StyleApp.normalBold),
                      content: SingleChildScrollView(
                        child: Text(
                          classification.desClasificacion,
                          style: StyleApp.normal,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.visibility),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
