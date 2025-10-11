// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:fl_business/displays/tareas/models/models.dart';
import 'package:http/http.dart' as http;

import 'package:fl_business/shared_preferences/preferences.dart';

class FilesService {
  final String _baseUrl = Preferences.urlApi;

  //Consumo api para actualizar el estado de la tarea.
  Future<ApiResModel> posFilesComent(
    String token,
    String user,
    List<File> files,
    int tarea,
    int tareaComentario,
    String urlCarpeta,
  ) async {
    Uri url = Uri.parse("${_baseUrl}FilesComment");
    try {
      var request = http.MultipartRequest('POST', url);

      // Agregar encabezados a la solicitud
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
        "user": user,
        "tarea": tarea.toString(),
        "tareaComentario": tareaComentario.toString(),
        "urlCarpeta": urlCarpeta,
      });

      // Agregar archivos a la solicitud
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      // Agregar cualquier dato adicional si es necesario
      request.fields['additionalField'] = 'additionalValue';

      var response = await request.send();

      // Obtener body como String
      var responseString = await response.stream.bytesToString();

      ResponseModel res = ResponseModel.fromMap(jsonDecode(responseString));

      // Manejar la respuesta
      if (response.statusCode == 200) {
        //Archivos subidos exitosamente
        return ApiResModel(
          url: url.toString(),
          succes: true,
          response: res.data,
          storeProcedure: null,
        );
      } else {
        // 'Error al subir archivos. Código de estado: ${response.statusCode}',
        return ApiResModel(
          url: url.toString(),
          succes: false,
          response: res.data,
          storeProcedure: res.storeProcedure,
        );
      }
    } catch (e) {
      //'Error al subir archivos: $e'
      return ApiResModel(
        url: url.toString(),
        succes: false,
        response: e.toString(),
        storeProcedure: null,
      );
    }
  }
}
