import 'package:flutter/material.dart';
import '../models/tarea_model.dart';
import '../views/tarea_card.dart';

class KanbanPageView extends StatelessWidget {
  final List<Tarea> tareas;

  const KanbanPageView({super.key, required this.tareas});

  @override
  Widget build(BuildContext context) {
    // Agrupa por estado de la tarea (ej: ACTIVO, NO PROCEDE, etc.)
    final Map<String, List<Tarea>> porEstado = {};
    for (final t in tareas) {
      final key = t.tareaEstado; // título de la columna
      porEstado.putIfAbsent(key, () => []).add(t);
    }
    final estados = porEstado.keys.toList();

    if (estados.isEmpty) {
      return const Center(child: Text('Sin tareas'));
    }

    return PageView.builder(
      controller: PageController(viewportFraction: 0.94),
      itemCount: estados.length,
      itemBuilder: (context, index) {
        final estado = estados[index];
        final items = porEstado[estado]!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado de la columna
              Row(
                children: [
                  Text(
                    estado,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      items.length.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Lista de tarjetas dentro de la columna
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final tarea = items[i];
                    return TareaCard(
                      id: tarea.iDTarea.toString(),
                      descripcion: tarea.descripcion.toString(),
                      prioridad: tarea.nomNivelPrioridad,
                      backColor: tarea.backColor, 
                      descripcionTipoTarea: tarea.descripcionTipoTarea,
                      descripcionReferencia: tarea.descripcionReferencia,
                      referencia: tarea.referencia,
                      fechaInicial: tarea.fechaInicial,
                      fechaFinal: tarea.fechaFinal,
                      tarea: tarea, // 🔹 Esto es lo importante
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
