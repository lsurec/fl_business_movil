// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fl_business/displays/prc_documento_3/models/models.dart';
import 'package:fl_business/displays/prc_documento_3/services/services.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/view_models.dart';
import 'package:fl_business/displays/report/models/author_model.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/utilities/utilities.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:provider/provider.dart';

class FacturaProvider {
  static DocPrintModel? data;

  Future<bool> loaData(BuildContext context, int consecutivoDoc) async {
    data = null;

    //instancia del servicio
    DocumentService documentService = DocumentService();
    //Proveedores externos
    final LoginViewModel loginVM = Provider.of<LoginViewModel>(
      context,
      listen: false,
    );

    //usario
    String user = loginVM.user;
    //token
    String token = loginVM.token;

    //consumir servicio
    ApiResModel resEncabezado = await documentService.getEncabezados(
      consecutivoDoc, // doc,
      user, // user,
      token, // token,
    );

    //valid succes response
    if (!resEncabezado.succes) {
      //finalozar el proceso

      resEncabezado.response =
          "Consucitivo: ($consecutivoDoc); Error: ${resEncabezado.response.toString()}";

      await NotificationService.showErrorView(context, resEncabezado);

      return false;
    }

    final List<EncabezadoModel> encabezadoTemplate = resEncabezado.response;

    //consumir servicio
    ApiResModel resDetalle = await documentService.getDetalles(
      consecutivoDoc, // doc,
      user, // user,
      token, // token,
    );

    //valid succes response
    if (!resDetalle.succes) {
      //finalozar el proceso
      resDetalle.response =
          "Consucitivo: ($consecutivoDoc); Error: ${resDetalle.response.toString()}";

      await NotificationService.showErrorView(context, resDetalle);
      return false;
    }

    final List<DetalleModel> detallesTemplate = resDetalle.response;

    //consumir servicio
    ApiResModel resPago = await documentService.getPagos(
      consecutivoDoc, // doc,
      user, // user,
      token, // token,
    );

    //valid succes response
    if (!resPago.succes) {
      //finalozar el proceso
      resPago.response =
          "Consucitivo: ($consecutivoDoc); Error: ${resPago.response.toString()}";

      await NotificationService.showErrorView(context, resPago);
      return false;
    }

    final List<PagoModel> pagosTemplate = resPago.response;

    //validar que haya datos
    if (encabezadoTemplate.isEmpty) {
      resEncabezado.response = AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.notificacion, 'sinEncabezados');
      NotificationService.showErrorView(context, resEncabezado);

      return false;
    }

    final EncabezadoModel encabezado = encabezadoTemplate.first;

    Empresa empresa = Empresa(
      razonSocial: encabezado.razonSocial!,
      nombre: encabezado.empresaNombre!,
      direccion: encabezado.empresaDireccion!,
      nit: encabezado.empresaNit!,
      tel: encabezado.empresaTelefono!,
    );

    Documento documento = Documento(
      titulo: encabezado.tipoDocumento!,
      descripcion: AppLocalizations.of(
        context,
      )!.translate(BlockTranslate.tiket, 'docTributario'),
      // fechaCert: formattedDateCert,
      fechaCert: encabezado.feLFechaCertificacion ?? "",
      serie: encabezado.feLSerie ?? "",
      no: encabezado.feLNumeroDocumento ?? "",
      autorizacion: encabezado.feLUuid ?? "",
      noInterno: encabezado.iDDocumentoRef ?? "",
      serieInterna: encabezado.serieDocumento ?? "",
      consecutivoInterno: consecutivoDoc,
    );

    DateTime now = DateTime.parse(
      encabezado.docFechaDocumento ?? DateTime.now().toString(),
    );

    // Formatear la fecha como una cadena
    String formattedDate =
        "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";

    Cliente cliente = Cliente(
      nombre: encabezado.ccFacturaNombre ?? "",
      direccion: encabezado.ccFacturaDireccion ?? "",
      nit: encabezado.ccFacturaNit ?? "",
      fecha: formattedDate,
      tel: encabezado.ccTelefono ?? "",
      email: encabezado.ccEMail ?? "", //Cambiar aqui,
    );

    //totales
    double cargo = 0;
    double descuento = 0;
    double subtotal = 0;
    double total = 0;

    List<Item> items = [];

    for (var detail in detallesTemplate) {
      int tipoTra = _findTipoProducto(context, detail.tipoTransaccion);

      if (tipoTra == 4) {
        //4 cargo
        cargo += detail.monto;
      } else if (tipoTra == 3) {
        //5 descuento
        descuento += detail.monto;
      } else {
        //cualquier otro
        subtotal += detail.monto;
      }

      items.add(
        Item(
          descripcion: detail.desProducto,
          cantidad: detail.cantidad,
          unitario: tipoTra == 3
              ? "- ${detail.montoUMTipoMoneda}"
              : detail.montoUMTipoMoneda,
          total: tipoTra == 3
              ? "- ${detail.montoTotalTipoMoneda}"
              : detail.montoTotalTipoMoneda,
          sku: detail.productoId,
          precioDia: tipoTra == 3
              ? "- ${detail.montoTotalTipoMoneda}"
              : detail.montoTotalTipoMoneda,
          um: detail.simbolo,
        ),
      );
    }

    total += (subtotal + cargo) + descuento;

    Montos montos = Montos(
      subtotal: subtotal,
      cargos: cargo,
      descuentos: descuento,
      total: total,
      totalLetras: encabezado.montoLetras!.toUpperCase(),
    );

    List<Pago> pagos = [];

    for (var pago in pagosTemplate) {
      pagos.add(
        Pago(
          tipoPago: pago.fDesTipoCargoAbono,
          monto: pago.monto,
          pago: pago.monto + pago.cambio,
          cambio: pago.cambio,
        ),
      );
    }

    Certificador certificador = Certificador(
      nombre: encabezado.certificadorDteNombre!,
      nit: encabezado.certificadorDteNit!,
    );

    List<String> mensajes = [
      encabezado.formaPagoIsr ?? "",
      encabezado.serieObervacion ?? "",
    ];

    AuthorModel author = Utilities.author;

    PoweredBy poweredBy = PoweredBy(
      nombre: author.nombre,
      website: author.website,
    );

    data = DocPrintModel(
      empresa: empresa,
      documento: documento,
      cliente: cliente,
      items: items,
      montos: montos,
      pagos: pagos,
      vendedor: encabezado.cuentaCorrentistaRefNombre ?? "",
      certificador: certificador,
      observacion: encabezado.observacion1 ?? "",
      mensajes: mensajes,
      poweredBy: poweredBy,
      noDoc: encabezado.iDDocumentoRef ?? "",
      usuario: user,
      direccionEntrega: encabezado.direccion1CuentaCta,
      procedimientoAlmacenado: resEncabezado.storeProcedure ?? "",
    );

    return true;
  }

  int _findTipoProducto(BuildContext context, tipoTra) {
    final DocumentViewModel docVM = Provider.of<DocumentViewModel>(
      context,
      listen: false,
    );

    for (var transaccion in docVM.tiposTransaccion) {
      if (transaccion.tipoTransaccion == tipoTra) {
        return transaccion.tipo;
      }
    }

    return 0;
  }
}
