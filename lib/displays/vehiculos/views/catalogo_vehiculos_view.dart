import 'package:flutter/material.dart';

class CatalogoVehiculosView extends StatelessWidget {
  const CatalogoVehiculosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Vehículos'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado verde
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              width: double.infinity,
              child: const Text(
                'Descripción',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tabla de datos
            Table(
              columnWidths: const {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(300),
              },
              children: [
                _buildTableRow('ID', ''),
                _buildTableRow('Estado', ''),
                _buildTableRow('Página', ''),
                _buildTableRow('Orden', ''),
                _buildTableRow('Secuencia', ''),
                _buildTableRow('Marca', ''),
                _buildTableRow('Modelo', ''),
                _buildTableRow('Sección', ''),
                _buildTableRow('Año', ''),
                _buildTableRow('Motor', ''),
                _buildTableRow('Chasis', ''),
                _buildTableRow('Calor', ''),
                _buildTableRow('Placa', ''),
                _buildTableRow('Opción Detalle', ''),
                _buildTableRow('Empresa', ''),
                _buildTableRow('Usuario', ''),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Marca específica (ejemplo estático)
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AUDI'),
                  SizedBox(height: 4),
                  Text('BMW'),
                  SizedBox(height: 4),
                  Text('SUZUKI'),
                ],
              ),
            ),
            
            // Modelo específico (ejemplo estático)
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Text('ALTO'),
            ),
            
            // Chasis específico (ejemplo estático)
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Text('Q123PR5CJF122'),
            ),
            
            // Fecha específica (ejemplo estático)
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Text('13/11/2025 08:57:14'),
            ),
            
            // Opción Detalle (check)
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 120),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Empresa y Usuario (ejemplo estático)
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Text('1'),
            ),
            
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 120),
              child: Text('SA'),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}






























