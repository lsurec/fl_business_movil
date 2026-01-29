class MarcaVehiculo {
  final double x;
  final double y;

  MarcaVehiculo({required this.x, required this.y});

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory MarcaVehiculo.fromJson(Map<String, dynamic> json) {
    return MarcaVehiculo(
      x: json['x'],
      y: json['y'],
    );
  }
}