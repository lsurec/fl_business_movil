import 'dart:convert';
import 'package:fl_business/displays/prc_documento_3/models/mensaje_model.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:http/http.dart' as http;

class PagoService {
  // Url del servidor
  final String _baseUrl = Preferences.urlApi;

  Future<ApiResModel> getValidatePayment(
    String token,
    String user,
    int doc,
    String serie,
    int enterprise,
    int warehouse,
    int account,
    String accountAccount,
    int payment,
    double amount,
    double amountUSD,
    double exchangeRate,
    int coin,
    int bankAccount,
    String reference,
    String auth,
    int bank,
  ) async {
    //URL completa
    Uri url = Uri.parse("${_baseUrl}Pago/validate");
    try {
      //Configuraciones del api
      final response = await http.get(
        url,
        headers: {
          "Authorization": "bearer $token",
          "user": user,
          "doc": "$doc",
          "serie": serie,
          "enterprise": "$enterprise",
          "warehouse": "$warehouse",
          "account": "$account",
          "accountAccount": accountAccount,
          "payment": "$payment",
          "amount": "$amount",
          "amountUSD": "$amountUSD",
          "exchangeRate": "$exchangeRate",
          "coin": "$coin",
          "bankAccount": "$bankAccount",
          "reference": reference,
          "auth": auth,
          "bank": "$bank",
        },
      );

      ResponseModel res = ResponseModel.fromMap(jsonDecode(response.body));

      //si el api no responde
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          res.data != '1 ') {
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }

      //Lista para almacenar la respuesta del api
      List<MensajeModel> mensajes = [];

      if (res.data == '1 ') {
        mensajes.add(MensajeModel(mensaje: '', resultado: true));

        //retornar respuesta correcta del api
        return ApiResModel(
          url: url.toString(),
          succes: true,
          response: mensajes,
          storeProcedure: null,
        );
      }

      //recorrer lista api Y  agregar a lista local
      for (var item in res.data) {
        //Tipar a map
        final responseFinally = MensajeModel.fromMap(item);
        //agregar item a la lista
        mensajes.add(responseFinally);
      }
      //retornar respuesta correcta del api
      return ApiResModel(
        url: url.toString(),
        succes: true,
        response: mensajes,
        storeProcedure: null,
      );
    } catch (e) {
      //en caso de error retornar el error
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }

  //obtener formas de pago
  Future<ApiResModel> getFormas(
    int doc,
    String serie,
    int empresa,
    String token,
  ) async {
    Uri url = Uri.parse("${_baseUrl}Pago/formas");
    try {
      //url completa

      //configiracion del api
      final response = await http.get(
        url,
        headers: {
          "Authorization": "bearer $token",
          "empresa": empresa.toString(),
          "doc": doc.toString(),
          "serie": serie,
        },
      );

      ResponseModel res = ResponseModel.fromMap(jsonDecode(response.body));

      //si el api no responde
      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }

      //formas de pago disponibles
      List<PaymentModel> payments = [];

      //recorrer lista api Y  agregar a lista local
      for (var item in res.data) {
        //Tipar a map
        final responseFinally = PaymentModel.fromMap(item);
        //agregar item a la lista
        payments.add(responseFinally);
      }

      //respuesta correcta
      return ApiResModel(
        url: url.toString(),
        succes: true,
        response: payments,
        storeProcedure: null,
      );
    } catch (e) {
      //respuesta incorrecta
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }

  //obtner bancos
  Future<ApiResModel> getBancos(String user, int empresa, String token) async {
    Uri url = Uri.parse("${_baseUrl}Pago/bancos");
    try {
      //url completa

      //configuracion del api
      final response = await http.get(
        url,
        headers: {
          "Authorization": "bearer $token",
          "user": user,
          "empresa": empresa.toString(),
        },
      );

      ResponseModel res = ResponseModel.fromMap(jsonDecode(response.body));

      //si el api no responde
      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }

      //bancos disponibles
      List<BankModel> banks = [];

      //recorrer lista api Y  agregar a lista local
      for (var item in res.data) {
        //Tipar a map
        final responseFinally = BankModel.fromMap(item);
        //agregar item a la lista
        banks.add(responseFinally);
      }

      //Respuesta correcta
      return ApiResModel(
        url: url.toString(),
        succes: true,
        response: banks,
        storeProcedure: null,
      );
    } catch (e) {
      //Respuesta incorrecta
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }

  //obtener cuentas bancarias
  Future<ApiResModel> getCuentas(
    String user,
    int empresa,
    int banco,
    String token,
  ) async {
    Uri url = Uri.parse("${_baseUrl}Pago/banco/cuentas");
    try {
      //url completa

      //configuracion del api
      final response = await http.get(
        url,
        headers: {
          "Authorization": "bearer $token",
          "user": user,
          "empresa": empresa.toString(),
          "banco": banco.toString(),
        },
      );
      ResponseModel res = ResponseModel.fromMap(jsonDecode(response.body));

      //si el api no responde
      if (response.statusCode != 200 && response.statusCode != 201) {
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }

      //Cuentas bancarias disponbles
      List<AccountModel> accounts = [];

      //recorrer lista api Y  agregar a lista local
      for (var item in res.data) {
        //Tipar a map
        final responseFinally = AccountModel.fromMap(item);
        //agregar item a la lista
        accounts.add(responseFinally);
      }

      //respeusdata correcta
      return ApiResModel(
        url: url.toString(),
        succes: true,
        response: accounts,
        storeProcedure: null,
      );
    } catch (e) {
      //respuesta incorrecta
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }
}
