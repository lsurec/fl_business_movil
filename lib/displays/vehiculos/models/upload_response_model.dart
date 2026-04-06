import 'upload_file_model.dart';

class UploadResponseModel {
  final bool status;
  final String message;
  final List<FileNameModel> data;

  UploadResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => FileNameModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
