import 'dart:typed_data';

import 'package:fl_business/displays/shr_local_config/models/models.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/services/picture_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class TmuUtils {
  Future<Uint8List> compressPicture(Uint8List original) async {
    return await FlutterImageCompress.compressWithList(
      original,
      minHeight: 100,
      minWidth: 200,
      quality: 50, // Baja calidad para impresión
      format: CompressFormat.png,
    );
  }

  Future<img.Image> getMyCompanyLogo() async {
    final ByteData logo = await rootBundle.load('assets/logo_demosoft.png');

    // Convertir ByteData a Uint8List
    final Uint8List logoBytes = logo.buffer.asUint8List();

    final Uint8List pictureResize = await compressPicture(logoBytes);

    return img.decodeImage(pictureResize)!;
  }

  Future<img.Image> getEnterpriseLogo(BuildContext context) async {
    final EmpresaModel empresa = Provider.of<LocalSettingsViewModel>(
      context,
      listen: false,
    ).selectedEmpresa!;

    PictureService pictureService = PictureService();
    final ByteData logo = await pictureService.getLogo(
      empresa.absolutePathPicture,
    );

    // Convertir ByteData a Uint8List
    final Uint8List logoBytes = logo.buffer.asUint8List();

    final Uint8List pictureResize = await compressPicture(logoBytes);

    return img.decodeImage(pictureResize)!;
  }
}
