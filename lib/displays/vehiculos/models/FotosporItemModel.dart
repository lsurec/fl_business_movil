class TraFileUploadModel {
  String original;
  String system;

  TraFileUploadModel({
    required this.original,
    required this.system,
  });

  factory TraFileUploadModel.fromMap(Map<String, dynamic> json) =>
      TraFileUploadModel(
        original: json["original"],
        system: json["system"],
      );

  Map<String, dynamic> toMap() => {
        "original": original,
        "system": system,
      };
}
