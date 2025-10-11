class Usuario {
  final String email;
  final String userName;
  final String name;

  Usuario({
    required this.email,
    required this.userName,
    required this.name,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
