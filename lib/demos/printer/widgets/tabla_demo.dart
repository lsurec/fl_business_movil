import 'package:fl_business/demos/printer/models/estado_cuenta.dart';
import 'package:fl_business/demos/printer/utils/utils.dart';
import 'package:fl_business/demos/printer/widgets/vista_previa.dart';
import 'package:flutter/material.dart';

// Página de demostración de tabla
class TablaDemoPage extends StatelessWidget {
  TablaDemoPage({super.key});

  UtilitiesService utils = UtilitiesService(); // Instancia de utilidades
  // Lista simulada de datos para el reporte
  final List<EstadoCuenta> movimientos = [
    EstadoCuenta(
      fecha: '2025-09-01',
      detalle: 'Depósito inicial',
      debito: 0,
      credito: 1000,
      saldo: 1000,
      documento: 'DOC001',
      tipo: 'Ingreso',
      referencia: 'REF001',
    ),
    EstadoCuenta(
      fecha: '2025-09-03',
      detalle: 'Pago proveedor',
      debito: 200,
      credito: 0,
      saldo: 800,
      documento: 'DOC002',
      tipo: 'Egreso',
      referencia: 'REF002',
    ),
    EstadoCuenta(
      fecha: '2025-09-05',
      detalle: 'Cobro cliente',
      debito: 0,
      credito: 500,
      saldo: 1300,
      documento: 'DOC003',
      tipo: 'Ingreso',
      referencia: 'REF003',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Estructura principal de la página
    return WillPopScope(
      // Intercepta el botón de regresar para mostrar aviso
      onWillPop: () async {
        return await utils.onWillPop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Color de fondo de la pantalla
        appBar: AppBar(
          backgroundColor: Colors.blueAccent, // Color de la barra superior
          title: const Text(
            "Estado de Cuenta", // Título de la página
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: SizedBox.shrink(), // Oculta el botón de regreso
          centerTitle: true, // Centra el título
        ),
        body: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Espaciado alrededor del contenido
          child: Column(
            children: [
              Card(
                elevation: 4, // Sombra del card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Bordes redondeados
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis
                      .horizontal, // Permite scroll horizontal si la tabla es ancha
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blue[50],
                    ), // Color de encabezado
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    columns: const [
                      // Definición de las columnas de la tabla
                      DataColumn(
                        label: Text(
                          'Fecha',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Detalle',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Débito',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Crédito',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Saldo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Documento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Tipo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Referencia',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: movimientos.asMap().entries.map((entry) {
                      // Itera sobre los movimientos para generar cada fila
                      int rowIndex = entry.key;
                      EstadoCuenta mov = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>((
                          Set<MaterialState> states,
                        ) {
                          // Alterna el color de las filas para mejor legibilidad
                          if (rowIndex.isEven) return Colors.grey[100];
                          return null;
                        }),
                        cells: [
                          DataCell(Text(mov.fecha)),
                          DataCell(Text(mov.detalle)),
                          DataCell(Text(mov.debito.toStringAsFixed(2))),
                          DataCell(Text(mov.credito.toStringAsFixed(2))),
                          DataCell(Text(mov.saldo.toStringAsFixed(2))),
                          DataCell(Text(mov.documento)),
                          DataCell(Text(mov.tipo)),
                          DataCell(Text(mov.referencia)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espacio entre la tabla y el botón
              SizedBox(
                width: double.infinity, // Botón ocupa todo el ancho disponible
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blueAccent, // Color de fondo del botón
                    foregroundColor: Colors.white, // Color del texto e icon
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Bordes redondeados
                    ),
                  ),
                  onPressed: () {
                    // Navega a la vista previa / PDF al presionar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VistaPrevia()),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf), // Icono del botón
                  label: const Text(
                    "Generar Reporte", // Texto del botón
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
