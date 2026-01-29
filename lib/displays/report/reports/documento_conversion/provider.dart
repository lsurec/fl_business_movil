import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/doc_destination_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/models/print_convert_model.dart';
import 'package:fl_business/displays/listado_Documento_Pendiente_Convertir/services/reception_service.dart';
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/models/doc_print_model.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/home_view_model.dart';
import 'package:fl_business/view_models/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DocumentoConversionProvider {
  static DocPrintModel? data;

  Future<bool> loaData(
    BuildContext context,
    DocDestinationModel document,
  ) async {
    data = null;

    //datos externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final String token = loginVM.token;
    final String user = loginVM.user;

    //Buscar datos paar imprimir
    final ReceptionService receptionService = ReceptionService();

    final ApiResModel res = await receptionService.getDataPrint(
      token, //token,
      user, //user,
      document.data.documento, //documento,
      document.data.tipoDocumento, //tipoDocumento,
      document.data.serieDocumento, //serieDocumento,
      document.data.empresa, //empresa,
      document.data.localizacion, //localizacion,
      document.data.estacion, //estacion,
      document.data.fechaReg, //fechaReg,
    );

    //si el consumo salió mal
    if (!res.succes) {
      await NotificationService.showErrorView(context, res);
      return false;
    }

    final List<PrintConvertModel> dataReport = res.response;

    if (dataReport.isEmpty) {
      res.response = AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.notificacion, "sinDatos");
      NotificationService.showErrorView(context, res);

      return false;
    }

    final vmHome = Provider.of<HomeViewModel>(context, listen: false);

    // Crear una instancia de NumberFormat para el formato de moneda
    final currencyFormat = NumberFormat.currency(
      symbol: vmHome
          .moneda, // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
      decimalDigits: 2, // Número de decimales a mostrar
    );

    final PrintConvertModel encabezado = dataReport.first;

    Empresa empresa = Empresa(
      razonSocial: encabezado.razonSocial ?? "",
      nombre: encabezado.empresaNombre ?? "",
      direccion: encabezado.empresaDireccion ?? "",
      nit: encabezado.empresaNit ?? "",
      tel: encabezado.empresaTelefono ?? "",
    );

    //TODO: Certificar
    Documento documento = Documento(
      consecutivoInterno: 0,
      titulo: encabezado.tipoDocumento!,
      descripcion:
          encabezado.documentoNombre ??
          AppLocalizations.of(
            context,
          )!.translate(BlockTranslate.tiket, "generico"),
      fechaCert: "",
      serie: "",
      no: "",
      autorizacion: "",
      noInterno: encabezado.idDocumento ?? "",
      serieInterna: encabezado.serieDocumento ?? "",
    );

    DateTime now = DateTime.now();

    // Formatear la fecha como una cadena
    String formattedDate =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";

    Cliente cliente = Cliente(
      nombre: encabezado.documentoNombre ?? "",
      direccion: encabezado.documentoDireccion ?? "",
      nit: encabezado.documentoNit ?? "",
      fecha: formattedDate,
      tel: encabezado.documentoTelefono ?? "",
      email: "", //Cambiar aqui,
    );

    List<Item> items = [];

    for (var detail in dataReport) {
      items.add(
        Item(
          descripcion: detail.desProducto ?? "",
          cantidad: detail.cantidad ?? 0,
          unitario: detail.montoUMTipoMoneda ?? "",
          total: detail.montoTotalTipoMoneda ?? "",
          sku: detail.productoId ?? "",
          precioDia: detail.montoTotalTipoMoneda ?? "",
          um: detail.simbolo ?? "",
        ),
      );
    }

    Montos montos = Montos(
      subtotal: encabezado.subTotal ?? 0,
      cargos: 0,
      descuentos: encabezado.descuento ?? 0,
      total: (encabezado.subTotal ?? 0) + (encabezado.descuento ?? 0),
      totalLetras: encabezado.montoLetras!.toUpperCase(),
    );

    String vendedor = encabezado.atendio ?? "";

    PoweredBy poweredBy = PoweredBy(
      nombre: "Desarrollo Moderno de Software S.A.",
      website: "www.demosoft.com.gt",
    );

    data = DocPrintModel(
      empresa: empresa,
      documento: documento,
      cliente: cliente,
      items: items,
      montos: montos,
      pagos: [],
      vendedor: vendedor,
      certificador: Certificador(nombre: "", nit: ""),
      observacion: encabezado.observacion1 ?? "",
      mensajes: [],
      poweredBy: poweredBy,
      noDoc: encabezado.refIdDocumento ?? "",
      usuario: user,
      procedimientoAlmacenado: res.storeProcedure ?? "",
      direccionEntrega: '',
    );

    return true;
  }
}
