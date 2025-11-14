import 'package:flutter/material.dart';
import 'package:fl_business/displays/restaurant/widgets/widgets.dart';
import 'package:fl_business/displays/restaurant/models/product_restaurant_model.dart';
import 'package:fl_business/displays/restaurant/view_models/view_models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProductClassView extends StatelessWidget {
  const ProductClassView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vmLoc = Provider.of<LocationsViewModel>(context);
    final vmTables = Provider.of<TablesViewModel>(context);
    final vmClass = Provider.of<ClassificationViewModel>(context);
    final vm = Provider.of<ProductsClassViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: vmTables.table!.orders!.isEmpty
              ? null
              : const ButtonDetailsWidget(),
          appBar: AppBar(
            title: Text(
              vmClass.classification!.desClasificacion,
              style: StyleApp.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "${vmTables.table!.descripcion}/",
                                style: StyleApp.normal,
                              ),
                            ),
                            Text(
                              vmClass.classification!.desClasificacion,
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
                        return _RowMenu(products: vm.menu[index]);
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

class _RowMenu extends StatelessWidget {
  const _RowMenu({Key? key, required this.products}) : super(key: key);

  final List<ProductRestaurantModel> products;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CardViewMore(product: products[0]),
        if (products.length == 2) CardViewMore(product: products[1]),
        if (products.length == 1) Expanded(child: Container()),
      ],
    );
  }
}

class CardViewMore extends StatelessWidget {
  const CardViewMore({super.key, required this.product});

  final ProductRestaurantModel product;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProductsClassViewModel>(context, listen: false);

    return Expanded(
      child: SizedBox(
        height: 230,
        child: Stack(
          children: [
            InkWell(
              onTap: () => vm.navigateDetails(context, product),

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
                      child: product.objetoImagen!.isEmpty
                          ? Image.asset(
                              "assets/image_not_available.png",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : FadeInImage(
                              placeholder: const AssetImage("assets/load.gif"),
                              image: NetworkImage(product.objetoImagen!),
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
                            product.desProducto,
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
                          product.desProducto,
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
