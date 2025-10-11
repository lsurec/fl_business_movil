class Invitado {
  final int tareaUserName;
  final String eMail;
  final String userName;

  Invitado({
    required this.tareaUserName,
    required this.eMail,
    required this.userName,
  });

  factory Invitado.fromJson(Map<String, dynamic> json) {
    return Invitado(
      tareaUserName: json["tarea_UserName"],
      eMail: json["eMail"] ?? "",
      userName: json["userName"],
    );
  }
}
