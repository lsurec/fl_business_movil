// ignore_for_file: use_build_context_synchronously

import 'package:fl_business/displays/prc_documento_3/models/mensaje_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/services/pago_service.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/displays/tareas/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:flutter/material.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:fl_business/view_models/menu_view_model.dart';
import 'package:provider/provider.dart';

class AmountViewModel extends ChangeNotifier {
  //Contorlador para el input monto
  final TextEditingController montoController = TextEditingController();

  //formulario completo
  final Map<String, String> formValues = {
    'monto': '',
    'autorizacion': '',
    'referencia': '',
  };

  //Key for form
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //True if form is valid
  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  //agregar monto
  Future<void> addAmount(PaymentModel payment, BuildContext context) async {
    //validar formulario
    if (!isValidForm()) return;

    //view model externo
    final vmPayment = Provider.of<PaymentViewModel>(context, listen: false);

    //si la forma de pago requiere banco
    if (payment.banco) {
      //contar cientos bancos hay seleccionados
      int counter = 0;
      for (var bank in vmPayment.banks) {
        if (bank.isSelected) counter++;
      }

      //si no hay bancos seleccionados mostrar mmensaje
      if (counter == 0) {
        NotificationService.showSnackbar(
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.notificacion, 'seleccionarBanco'),
        );
        return;
      }

      //si hay cunetas bancarias requeridas
      if (vmPayment.accounts.isNotEmpty) {
        //contar cuentas bancarias seleccionadas
        counter = 0;
        for (var acc in vmPayment.accounts) {
          if (acc.isSelected) counter++;
        }

        //si no hay cuenta bancaria seleccionada mostrar mensaje
        if (counter == 0) {
          NotificationService.showSnackbar(
            AppLocalizations.of(
              context,
            )!.translate(BlockTranslate.notificacion, 'seleccionarCuenta'),
          );
          return;
        }
      }
    }

    //convertir monto string a double
    double monto = double.tryParse(formValues["monto"]!) ?? 0;
    double diference = 0;

    //Calcualar si hay diferencia (Cambio)
    if (monto > vmPayment.saldo) {
      diference = monto - vmPayment.saldo;
      monto = vmPayment.saldo;
    }

    //objeto monto que se va a agregar (asignar valores)
    AmountModel amount = AmountModel(
      checked: vmPayment.selectAllAmounts,
      amount: double.parse(monto.toStringAsFixed(2)),
      //si es requerido
      authorization: payment.autorizacion ? formValues["autorizacion"]! : "",
      //si es requerido
      reference: payment.referencia ? formValues["referencia"]! : "",
      payment: payment,
      //si es requerido
      bank: payment.banco ? getBank(context) : null,
      //si es requerido
      account: vmPayment.accounts.isNotEmpty ? getAccount(context) : null,
      diference: double.parse(diference.toStringAsFixed(2)),
    );

    PagoService pagoService = PagoService();

    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    final MenuViewModel menuVM = Provider.of<MenuViewModel>(
      context,
      listen: false,
    );

    final DocumentViewModel docVM = Provider.of<DocumentViewModel>(
      context,
      listen: false,
    );

    final LocalSettingsViewModel localVM = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    );

    final DetailsViewModel detailsVM = Provider.of<DetailsViewModel>(
      context,
      listen: false,
    );

    vmPayment.isLoading = true;
    //Validar forma de pago
    ApiResModel resValidate = await pagoService.getValidatePayment(
      loginVM.token,
      loginVM.user,
      menuVM.documento!,
      docVM.serieSelect!.serieDocumento!,
      localVM.selectedEmpresa!.empresa,
      localVM.selectedEstacion!.estacionTrabajo,
      docVM.clienteSelect!.cuentaCorrentista,
      docVM.clienteSelect!.cuentaCta,
      amount.payment.tipoCargoAbono,
      amount.amount,
      amount.amount / menuVM.tipoCambio,
      menuVM.tipoCambio,
      detailsVM.traInternas[0].precio!.moneda,
      amount.account != null ? amount.account!.cuentaBancaria : 0,
      amount.reference.isEmpty ? "empty" : amount.reference,
      amount.authorization.isEmpty ? "empty" : amount.authorization,
      amount.bank != null ? amount.bank!.banco : 0,
    );

    vmPayment.isLoading = false;

    if (!resValidate.succes) {
      //si algo salio mal mostrar alerta
      await NotificationService.showErrorView(context, resValidate);
      return;
    }

    final List<MensajeModel> resMensajes = resValidate.response;

    final List<String> mensajes = [];

    for (var element in resMensajes) {
      if (!element.resultado) {
        mensajes.add(element.mensaje ?? "");
      }
    }
    if (mensajes.isNotEmpty) {
      //aqui abre un dialogo con notificacion
      await NotificationService.showMessageValidationsPayment(
        context,
        mensajes,
      );

      return;
    }

    //Agregar monto a lista de montos
    vmPayment.addAmount(amount, context);

    //mensaje usuario
    NotificationService.showSnackbar(
      AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.notificacion, 'pagoAgregado'),
    );

    //regresar pantalla anterior
    Navigator.pop(context);
  }

  //Retorna banco seleccionado
  BankModel getBank(BuildContext context) {
    final vmPayment = Provider.of<PaymentViewModel>(context, listen: false);

    //filtrar banco seleccionado
    SelectBankModel selectedBank = vmPayment.banks.firstWhere(
      (bank) => bank.isSelected,
    );

    return selectedBank.bank;
  }

  //retorna cuenta bancaria seelccionada
  AccountModel getAccount(BuildContext context) {
    final vmPayment = Provider.of<PaymentViewModel>(context, listen: false);

    //filtrar cuenta bancaria seleccionada
    SelectAccountModel selectedBank = vmPayment.accounts.firstWhere(
      (account) => account.isSelected,
    );

    //restornar cuneta seleccionada
    return selectedBank.account;
  }
}
