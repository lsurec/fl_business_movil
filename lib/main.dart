import 'package:fl_business/widgets/tabla_demo.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Método build que construye la UI
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Tabla',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Color primario de la app
      ),
      home: TablaDemoPage(), // Página inicial de la app: tabla demo
    );
  }
}
