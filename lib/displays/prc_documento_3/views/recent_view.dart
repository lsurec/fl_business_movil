import 'package:flutter/material.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecentView extends StatefulWidget {
  const RecentView({Key? key}) : super(key: key);

  @override
  State<RecentView> createState() => _RecentViewState();
}

class _RecentViewState extends State<RecentView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => loadData(context));
  }

  loadData(BuildContext context) {
    final vm = Provider.of<RecentViewModel>(context, listen: false);
    vm.loadDocs(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RecentViewModel>(context);
    final homeVM = Provider.of<HomeViewModel>(context);
    final vmTheme = Provider.of<ThemeViewModel>(context);

    // Crear una instancia de NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(
      // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
      symbol: homeVM.moneda,
      // Número de decimales a mostrar
      decimalDigits: 2,
    );

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(
                context,
              )!.translate(BlockTranslate.factura, 'docRecientes'),
              style: StyleApp.title,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.translate(BlockTranslate.general, 'registro')} (${vm.documents.length})",
                      style: StyleApp.normalBold,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => vm.loadDocs(context),
                    child: ListView.separated(
                      itemCount: vm.documents.length,
                      separatorBuilder: (context, index) =>
                          const Divider(), // Agregar el separador
                      itemBuilder: (context, index) {
                        final DocumentoResumenModel doc = vm.documents[index];

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Id. Ref: ${doc.estructura.docIdDocumentoRef}",
                                    style: StyleApp.normalBold,
                                  ),
                                  Text(
                                    "Cons. Interno: ${doc.item.consecutivoInterno}",
                                    style: StyleApp.normalBold,
                                  ),
                                  Text(
                                    vm.strDate(doc.item.fechaHora),
                                    style: StyleApp.normal,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currencyFormat.format(doc.subtotal),
                                    style: StyleApp.normalColor15.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "(+) ${currencyFormat.format(doc.cargo)}",
                                    style: StyleApp.cargo,
                                  ),
                                  Text(
                                    "(-) ${currencyFormat.format(doc.descuento)}",
                                    style: StyleApp.descuento,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 1,
                                    color: Colors.transparent,
                                  ),
                                  Text(
                                    currencyFormat.format(doc.total),
                                    style: StyleApp.normalBold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => vm.reprintDoc(context, 2, doc),
                                icon: const Icon(Icons.share),
                              ),
                              IconButton(
                                onPressed: () => vm.reprintDoc(context, 1, doc),
                                icon: const Icon(Icons.print),
                              ),
                            ],
                          ),
                          onTap: () => vm.navigateView(context, doc),
                          // onTap: () {},
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoading || vm.isLoadingDTE)
          ModalBarrier(
            dismissible: false,
            // color: Colors.black.withOpacity(0.3),
            color: AppTheme.isDark()
                ? AppTheme.darkBackroundColor
                : AppTheme.backroundColor,
          ),
        if (vm.isLoading) const LoadWidget(),
        if (vm.isLoadingDTE)
          // const LoadWidget(),
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo_demosoft.png",
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.translate(BlockTranslate.general, 'tareasCompletas')} ${vm.stepsSucces}/${vm.steps.length}",
                          style: StyleApp.greyText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: vm.steps.length,
                      separatorBuilder: (_, __) {
                        return const Column(
                          children: [
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                          ],
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final LoadStepModel step = vm.steps[index];

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(step.text, style: StyleApp.normal),
                                if (step.status == 1) //Cargando
                                  const Icon(
                                    Icons.pending_outlined,
                                    color: AppTheme.grey,
                                  ),
                                if (step.status == 2) //exitoso
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: AppTheme.verde,
                                  ),
                                if (step.status == 3) //error
                                  const Icon(
                                    Icons.cancel_outlined,
                                    color: AppTheme.rojo,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (step.isLoading)
                              LinearProgressIndicator(
                                color: vmTheme.colorPref(AppTheme.idColorTema),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    if (vm.viewMessage) Text(vm.error, style: StyleApp.red),
                    if (vm.viewSucces)
                      Text(
                        AppLocalizations.of(context)!.translate(
                          BlockTranslate.notificacion,
                          'docProcesado',
                        ),
                        style: StyleApp.green,
                      ),
                    if (vm.viewError)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => vm.navigateError(context),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.translate(BlockTranslate.botones, 'verError'),
                            style: StyleApp.normalColor15.copyWith(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (vm.viewErrorFel) _OptionsError(),
                    if (vm.viewErrorProcess) _OptionsErrorAll(),
                    if (vm.viewSucces)
                      SizedBox(
                        height: 75,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  vm.isLoadingDTE = false;
                                  vm.showPrint = true;
                                  vm.printOrShaherDoc(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    right: 10,
                                  ),
                                  color: vmTheme.colorPref(
                                    AppTheme.idColorTema,
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.translate(
                                        BlockTranslate.botones,
                                        'Imprimir sin firma',
                                      ),
                                      style: StyleApp.whiteNormal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OptionsError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RecentViewModel>(context);

    final vmTheme = Provider.of<ThemeViewModel>(context);

    return SizedBox(
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.isLoadingDTE = false,
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                color: vmTheme.colorPref(AppTheme.idColorTema),
                child: const Center(
                  child: Text(
                    'Aceptar', //TODO: Translate
                    style: StyleApp.whiteNormal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => vm.reloadCert(context),
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                color: vmTheme.colorPref(AppTheme.idColorTema),
                child: Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.botones, 'reintentar'),
                    style: StyleApp.whiteNormal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsErrorAll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<RecentViewModel>(context);

    final vmTheme = Provider.of<ThemeViewModel>(context);

    return SizedBox(
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.isLoadingDTE = false,
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
                color: vmTheme.colorPref(AppTheme.idColorTema),
                child: Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.botones, 'aceptar'),
                    style: StyleApp.whiteNormal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                //TODO:no es necesario
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                color: vmTheme.colorPref(AppTheme.idColorTema),
                child: Center(
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(BlockTranslate.botones, 'reintentar'),
                    style: StyleApp.whiteNormal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
