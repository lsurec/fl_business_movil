import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:fl_business/displays/shr_local_config/models/models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/services/picture_service.dart';

import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class UtilitiesTMU {
  //style for center text
  static PosStyles center = const PosStyles(align: PosAlign.center);

  //syle for center and bold text
  static PosStyles centerBold = const PosStyles(
    align: PosAlign.center,
    bold: true,
  );

  //bold an left or start text
  static PosStyles startBold = const PosStyles(
    align: PosAlign.left,
    bold: true,
  );

  Future<img.Image> loadLogo(BuildContext context) async {
    final EmpresaModel empresa = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEmpresa!;

    PictureService pictureService = PictureService();
    final ByteData logo = await pictureService.getLogo(
      empresa.absolutePathPicture,
    );

    // Convertir ByteData a Uint8List
    final Uint8List list = logo.buffer.asUint8List();

    // Decodificar imagen
    final img.Image decoded = img.decodeImage(list)!;

    // Redimensionar al alto deseado
    final img.Image resized = img.copyResize(decoded, height: 200);

    return resized;
  }
}
