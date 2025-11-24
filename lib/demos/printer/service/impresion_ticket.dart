import 'dart:typed_data';
import 'package:fl_business/demos/printer/models/estado_cuenta.dart';
import 'package:fl_business/demos/printer/utils/ticket_utils.dart';
import 'package:fl_business/demos/printer/utils/utils.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/document_view_model.dart';
import 'package:fl_business/displays/report/reports/factura/provider.dart';
import 'package:fl_business/displays/report/utils/tmu_utils.dart';
import 'package:fl_business/displays/report/view_models/printer_view_model.dart';
import 'package:fl_business/displays/shr_local_config/models/empresa_model.dart';
import 'package:fl_business/displays/shr_local_config/view_models/local_settings_view_model.dart';
import 'package:fl_business/models/api_res_model.dart';
import 'package:fl_business/models/doc_print_model.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/services/notification_service.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:fl_business/view_models/home_view_model.dart';
import 'package:fl_business/view_models/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ImpresionTicket {
  //imrimir factura
  Future<void> getReport(BuildContext context) async {
    try {
      final PrinterViewModel printerVM = Provider.of<PrinterViewModel>(
        context,
        listen: false,
      );

      final HomeViewModel vmHome = Provider.of<HomeViewModel>(
        context,
        listen: false,
      );

      final EmpresaModel empresa = Provider.of<LocalSettingsViewModel>(
        context,
        listen: false,
      ).selectedEmpresa!;

      // Crear una instancia de NumberFormat para el formato de moneda
      final currencyFormat = NumberFormat.currency(
        symbol: vmHome
            .moneda, // Símbolo de la moneda (puedes cambiarlo según tu necesidad)
        decimalDigits: 2, // Número de decimales a mostrar
      );
      final docVM = Provider.of<DocumentViewModel>(context, listen: false);

      final DocPrintModel data = FacturaProvider.data!;

      final bool existImage = empresa.absolutePathPicture.isEmpty;

      final bool isFel = docVM.printFel();

      final TicketUtils ticketUtils = TicketUtils();
      final UtilitiesService utils = UtilitiesService();
      final bluetooth = ticketUtils.bluetooth;

      // Verificar Bluetooth
      if (!await ticketUtils.verificarBluetoothDisponible(context)) return;

      // Seleccionar impresora
      BluetoothDevice? impresora = await ticketUtils.seleccionarImpresora(
        context,
      );
      if (impresora == null) return;

      // Conectar impresora
      bool conectado = await ticketUtils.conectarImpresora(context, impresora);
      if (!conectado) return;

      // Cargar e imprimir logo automáticamente
      bluetooth.printNewLine();

      // if (existImage) {
      //   //TODO:verificar imagen
      //   //Con este codigo se agregaría el logo:
      //   final Uint8List? logoBytesEmp = await UtilitiesService.loadLogoImage(
      //     '', //path completo generado con el campo de la empresa seleccionada
      //   );

      //   if (logoBytesEmp != null) {
      //     final Uint8List? imagenReducida = await utils
      //         .prepararImagenParaImpresion(logoBytesEmp);
      //     if (imagenReducida != null) {
      //       await bluetooth.printImageBytes(imagenReducida);
      //     }
      //   }

      //   bluetooth.printNewLine();
      // }

      await ticketUtils.imprimirTexto(
        data.empresa.razonSocial,
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(data.empresa.nombre, size: 1, align: 1);
      await ticketUtils.imprimirTexto(
        data.empresa.direccion,
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        'NIT: ${data.empresa.nit}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'tel')} ${data.empresa.tel}',
        size: 1,
        align: 1,
      );
      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto(data.documento.titulo, size: 1, align: 1);

      if (!isFel) {
        await ticketUtils.imprimirTexto(
          'DOCUMENTO GENERICO',
          size: 1,
          align: 1,
        );
      }

      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'serie')} ${data.documento.serieInterna}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'interno'),
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        data.documento.noInterno,
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'consInt')} ${data.documento.consecutivoInterno}',
        size: 1,
        align: 1,
      );

      if (isFel) {
        bluetooth.printNewLine();

        await ticketUtils.imprimirTexto(
          data.documento.descripcion,
          size: 1,
          align: 1,
        );
        bluetooth.printNewLine();

        await ticketUtils.imprimirTexto(
          'Serie: ${data.documento.serie}',
          size: 1,
          align: 1,
        );
        await ticketUtils.imprimirTexto(
          'No: ${data.documento.no}',
          size: 1,
          align: 1,
        );
        await ticketUtils.imprimirTexto(
          'Fecha: ${data.documento.fechaCert}',
          size: 1,
          align: 1,
        );
        await ticketUtils.imprimirTexto('Autorizacion:', size: 1, align: 1);
        await ticketUtils.imprimirTexto(
          data.documento.autorizacion,
          size: 1,
          align: 1,
        );
      }
      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'cliente'),
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'nombre')} ${data.cliente.nombre}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        'NIT: ${data.cliente.nit}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'direccion')} ${data.cliente.direccion}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        '${AppLocalizations.of(context)!.translate(BlockTranslate.fecha, 'fecha')} ${data.cliente.fecha}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto('Lugar de entrega:', size: 1, align: 1);
      await ticketUtils.imprimirTexto(
        data.direccionEntrega ?? "",
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        'Registros: ${data.items.length}',
        size: 1,
        align: 1,
      );
      bluetooth.printNewLine();

      for (var element in data.items) {
        await ticketUtils.imprimirTexto('Cant: ${element.cantidad}');
        await ticketUtils.imprimirTexto('Desc: ${element.descripcion}');
        await ticketUtils.imprimirTexto('P/U: ${element.unitario}');
        await ticketUtils.imprimirTexto('Total: ${element.total}');
        bluetooth.printNewLine();
      }

      await ticketUtils.imprimirTexto(
        'Subtotal: ${currencyFormat.format(data.montos.subtotal)}',
      );
      await ticketUtils.imprimirTexto(
        'Cargos: ${currencyFormat.format(data.montos.cargos)}',
      );
      await ticketUtils.imprimirTexto(
        'Descuentos: ${currencyFormat.format(data.montos.descuentos)}',
      );
      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto(
        'TOTAL: ${currencyFormat.format(data.montos.total)}',
      );
      await ticketUtils.imprimirTexto(data.montos.totalLetras);
      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto(
        AppLocalizations.of(
          context,
        )!.translate(BlockTranslate.tiket, 'detallePago'),
      );

      for (var pago in data.pagos) {
        bluetooth.printNewLine();

        await ticketUtils.imprimirTexto(pago.tipoPago);
        await ticketUtils.imprimirTexto(
          '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'recibido')}: ${currencyFormat.format(pago.pago)}',
        );
        await ticketUtils.imprimirTexto(
          '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'monto')}: ${currencyFormat.format(pago.monto)}',
        );
        await ticketUtils.imprimirTexto(
          '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'cambio')}: ${currencyFormat.format(pago.cambio)}',
        );

        bluetooth.printNewLine();
      }

      if (data.vendedor != "") {
        await ticketUtils.imprimirTexto(
          '${AppLocalizations.of(context)!.translate(BlockTranslate.tiket, 'vendedor')} ${data.vendedor}',
          size: 1,
          align: 1,
        );
        bluetooth.printNewLine();
      }

      for (var mensaje in data.mensajes) {
        await ticketUtils.imprimirTexto(mensaje, size: 1, align: 1);
      }

      bluetooth.printNewLine();

      if (isFel) {
        await ticketUtils.imprimirTexto('Ceritificador:', size: 1, align: 1);
        await ticketUtils.imprimirTexto(
          data.certificador.nombre,
          size: 1,
          align: 1,
        );
        await ticketUtils.imprimirTexto(
          data.certificador.nit,
          size: 1,
          align: 1,
        );
      }

      if (data.observacion != "") {
        bluetooth.printNewLine();

        await ticketUtils.imprimirTexto('Observacion:', size: 1, align: 1);
        await ticketUtils.imprimirTexto(data.observacion, size: 1, align: 1);
      }

      await ticketUtils.imprimirTexto(
        'Usuario: ${data.usuario}',
        size: 1,
        align: 1,
      );
      bluetooth.printNewLine();

      await ticketUtils.imprimirTexto('Powered by', size: 1, align: 1);
      await ticketUtils.imprimirTexto(data.poweredBy.nombre, size: 1, align: 1);
      await ticketUtils.imprimirTexto(
        data.poweredBy.website,
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        'Version: ${SplashViewModel.versionLocal}',
        size: 1,
        align: 1,
      );
      await ticketUtils.imprimirTexto(
        data.procedimientoAlmacenado,
        size: 1,
        align: 1,
      );
      // Línea final y desconexión
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      await ticketUtils.desconectarSiConectado();
    } catch (e) {
      final ApiResModel res = ApiResModel(
        succes: false,
        response: e.toString(),
        url: '',
        storeProcedure: '',
      );

      NotificationService.showErrorView(context, res);
    }
  }

  /// Método estático para imprimir directamente en ticket
  static Future<void> imprimirTicket({
    required BuildContext context,
    required List<EstadoCuenta> movimientos,
  }) async {
    final TicketUtils ticketUtils = TicketUtils();
    final UtilitiesService utils = UtilitiesService();
    final bluetooth = ticketUtils.bluetooth;

    // Verificar Bluetooth
    if (!await ticketUtils.verificarBluetoothDisponible(context)) return;

    // Seleccionar impresora
    BluetoothDevice? impresora = await ticketUtils.seleccionarImpresora(
      context,
    );
    if (impresora == null) return;

    // Conectar impresora
    bool conectado = await ticketUtils.conectarImpresora(context, impresora);
    if (!conectado) return;

    // Cargar e imprimir logo automáticamente
    bluetooth.printNewLine();

    //Con este codigo se agregaría el logo:
    final Uint8List? logoBytesEmp = await UtilitiesService.loadLogoImage(
      '', //path completo generado con el campo de la empresa seleccionada
    );
    if (logoBytesEmp != null) {
      final Uint8List? imagenReducida = await utils.prepararImagenParaImpresion(
        logoBytesEmp,
      );
      if (imagenReducida != null) {
        await bluetooth.printImageBytes(imagenReducida);
      }
    }

    bluetooth.printNewLine();

    // Imprimir encabezado (empresa, NIT, dirección) de la empresa seleccionada
    await ticketUtils.imprimirTexto('ILGUA', size: 2, align: 1);
    await ticketUtils.imprimirTexto('NIT: 15613-7', size: 1, align: 1);
    await ticketUtils.imprimirTexto('Zona 14-7', size: 1, align: 1);
    bluetooth.printNewLine();

    // Imprimir cada movimiento
    for (final m in movimientos) {
      await ticketUtils.imprimirTexto('Fecha: ${m.fecha}');
      await ticketUtils.imprimirTexto('Detalle: ${m.detalle}');
      await ticketUtils.imprimirTexto(
        'Débito: ${m.debito.toStringAsFixed(2)}  Crédito: ${m.credito.toStringAsFixed(2)}',
      );
      await ticketUtils.imprimirTexto('Saldo: ${m.saldo.toStringAsFixed(2)}');
      await ticketUtils.imprimirTexto(
        'Documento: ${m.documento}  Tipo: ${m.tipo}',
      );
      await ticketUtils.imprimirTexto('Referencia: ${m.referencia}');
      bluetooth.printNewLine();
    }
    await ticketUtils.imprimirTexto(
      'Generado por: ${UtilitiesService.nombreEmpresa}',
      size: 0,
      align: 1,
    );
    await ticketUtils.imprimirTexto(
      '${UtilitiesService.version}',
      size: 0,
      align: 1,
    );

    // Línea final y desconexión
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    await ticketUtils.desconectarSiConectado();
  }
}
