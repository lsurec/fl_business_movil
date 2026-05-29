import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/view_models/view_models.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/themes/themes.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:fl_business/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentConvertView extends StatelessWidget {
  const PaymentConvertView({super.key});

  static const String routeName = 'paymentConvert';

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context, listen: false);

    // Crear una instancia de NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(
      // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
      symbol: homeVM.moneda,
      // Número de decimales a mostrar
      decimalDigits: 2,
    );

    final PaymentConvertViewModel vm = Provider.of<PaymentConvertViewModel>(
      context,
    );

    final vmTheme = Provider.of<ThemeViewModel>(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => vm.loadPayments(context),
                    child: ListView(
                      children: [
                        if (vm.paymentList.isEmpty)
                          NotFoundWidget(
                            text: AppLocalizations.of(context)!.translate(
                              BlockTranslate.notificacion,
                              'sinElementos',
                            ),
                            icon: const Icon(
                              Icons.browser_not_supported_outlined,
                              size: 250,
                            ),
                          ),
                        if (vm.paymentList.isNotEmpty)
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate(BlockTranslate.factura, 'agregarPago'),
                            style: StyleApp.title,
                          ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: vm.paymentList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final PaymentModel payment = vm.paymentList[index];

                            return GestureDetector(
                              onTap: () => vm.navigateAmount(context, payment),
                              child: PaymentCard(payment: payment),
                            );
                          },
                        ),
                        if (vm.amounts.isNotEmpty) const SizedBox(height: 20),
                        if (vm.amounts.isNotEmpty) const Divider(),
                        if (vm.amounts.isNotEmpty) const SizedBox(height: 10),
                        if (vm.amounts.isNotEmpty)
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Checkbox(
                                activeColor: AppTheme.hexToColor(
                                  Preferences.valueColor,
                                ),
                                value: vm.selectAllAmounts,
                                onChanged: (value) => vm.selectAllMounts(value),
                              ),
                              Text(
                                "${AppLocalizations.of(context)!.translate(BlockTranslate.factura, 'pagosAgregados')} (${vm.amounts.length})",
                                style: StyleApp.normalBold,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => vm.deleteAmounts(context),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: vm.amounts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final AmountModel amount = vm.amounts[index];

                            return Card(
                              color: AppTheme.isDark()
                                  ? AppTheme.backroundDarkSecondary
                                  : AppTheme.backroundSecondary,
                              elevation: 2.0,
                              child: ListTile(
                                leading: Checkbox(
                                  activeColor: AppTheme.hexToColor(
                                    Preferences.valueColor,
                                  ),
                                  value: amount.checked,
                                  onChanged: (value) =>
                                      vm.changeCheckedamount(value, index),
                                ),
                                title: Text(
                                  amount.payment.descripcion,
                                  style: StyleApp.normalBold,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (amount.payment.autorizacion)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.factura, 'autorizar')}: ${amount.authorization}',
                                        style: StyleApp.normal,
                                      ),
                                    if (amount.payment.referencia)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.factura, 'referencia')}: ${amount.reference}',
                                        style: StyleApp.normal,
                                      ),
                                    if (amount.payment.banco)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.factura, 'banco')}: ${amount.bank?.nombre}',
                                        style: StyleApp.normal,
                                      ),
                                    if (amount.account != null)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.factura, 'cuenta')}: ${amount.account!.descripcion}',
                                        style: StyleApp.normal,
                                      ),
                                    Text(
                                      '${AppLocalizations.of(context)!.translate(BlockTranslate.calcular, 'monto')}: ${currencyFormat.format(amount.amount)}',
                                      style: StyleApp.normal,
                                    ),
                                    if (amount.diference > 0)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.calcular, 'diferencia')}: ${currencyFormat.format(amount.diference)}',
                                        style: StyleApp.normal,
                                      ),
                                    if (amount.diference > 0)
                                      Text(
                                        '${AppLocalizations.of(context)!.translate(BlockTranslate.calcular, 'precioT')}: ${currencyFormat.format(amount.diference + amount.amount)}',
                                        style: StyleApp.normal,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => vm.confirmPayments(context),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: AppTheme.hexToColor(Preferences.valueColor),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Continuar',
                            style: StyleApp.whiteNormal.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                RowTotalWidget(
                  title: AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.calcular, 'total'),
                  value: vm.total,
                  color: AppTheme.hexToColor(Preferences.valueColor),
                ),
                RowTotalWidget(
                  title: AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.calcular, 'saldo'),
                  value: vm.saldo,
                  color: AppTheme.hexToColor(Preferences.valueColor),
                ),
                RowTotalWidget(
                  title: AppLocalizations.of(
                    context,
                  )!.translate(BlockTranslate.calcular, 'cambio'),
                  value: vm.cambio,
                  color: AppTheme.hexToColor(Preferences.valueColor),
                ),
              ],
            ),
          ),
        ),
        if (vm.isLoadingDTE || vm.isLoading)
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
                                        'aceptar',
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

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.payment});
  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.isDark()
          ? AppTheme.backroundDarkSecondary
          : AppTheme.backroundSecondary,
      elevation: 2.0,
      child: ListTile(
        trailing: const Icon(Icons.arrow_right),
        title: Text(payment.descripcion, style: StyleApp.normal),
      ),
    );
  }
}

class _OptionsError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PaymentConvertViewModel>(context);
    final vmTheme = Provider.of<ThemeViewModel>(context);

    return SizedBox(
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => vm.printWithoutFel(context),
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
    final vm = Provider.of<PaymentConvertViewModel>(context);
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
              onTap: () => vm.processDocument(context),
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
