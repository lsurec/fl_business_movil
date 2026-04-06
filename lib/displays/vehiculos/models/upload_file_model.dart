class FileNameModel {
  final String original;
  final String system;

  FileNameModel({
    required this.original,
    required this.system,
  });

  factory FileNameModel.fromJson(Map<String, dynamic> json) {
    return FileNameModel(
      original: json['original'] ?? '',
      system: json['system'] ?? '',
    );
  }
}
