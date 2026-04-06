import 'dart:convert';
import 'dart:io';
import 'package:fl_business/displays/vehiculos/models/upload_file_model.dart';
import 'package:http/http.dart' as http;
import '../models/upload_response_model.dart';

class UploadService {
  final String baseUrl = "http://192.168.100.38:9085";

  Future<List<FileNameModel>> uploadImages({
  required List<String> imagePaths,
  required String token,
  required String urlCarpeta,
}) async {
  var uri = Uri.parse("$baseUrl/api/v2/Shared/files");

  var request = http.MultipartRequest("POST", uri);

  request.headers['Authorization'] = 'bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJhZG1pbiIsIm5iZiI6MTc1MDM0NjcyNCwiZXhwIjoxNzgxNDUwNzI0LCJpYXQiOjE3NTAzNDY3MjR9.NChZbZBfi3IZIVidfWujhmcwgtFYF4hDM1Xg7Z7z5J0';

  request.fields['urlCarpeta'] = urlCarpeta;

  for (var path in imagePaths) {
    request.files.add(
      await http.MultipartFile.fromPath('file', path),
    );
  }

  var response = await request.send();
  var responseBody = await response.stream.bytesToString();

  print("STATUS CODE: ${response.statusCode}");
  print("BODY: $responseBody");

  if (response.statusCode == 200) {
    final decoded = json.decode(responseBody);
    final uploadResponse = UploadResponseModel.fromJson(decoded);

    if (uploadResponse.status) {
      return uploadResponse.data;
    } else {
      throw Exception(uploadResponse.message);
    }
  } else {
    throw Exception("Error ${response.statusCode}: $responseBody");
  }
}
}
