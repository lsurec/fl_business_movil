import 'package:flutter/material.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/language_service.dart';
import 'package:fl_business/themes/app_theme.dart';
import 'package:fl_business/utilities/translate_block_utilities.dart';
import 'package:provider/provider.dart';
import 'package:fl_business/displays/tareas/view_models/detalle_tarea_view_model.dart';
import 'package:fl_business/displays/tareas/models/models.dart';
import '../models/tarea_model.dart';

// 🔹 Convierte código hex (#RRGGBB) a Color
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class TareaCard extends StatelessWidget {
  final String id;
  final String descripcion;
  final String prioridad;
  final String backColor;
  final String descripcionTipoTarea;
  final String descripcionReferencia;
  final int referencia;
  final DateTime fechaInicial;
  final DateTime fechaFinal;
  final Tarea tarea;

  const TareaCard({
    Key? key,
    required this.id,
    required this.descripcion,
    required this.prioridad,
    required this.backColor,
    required this.descripcionTipoTarea,
    required this.descripcionReferencia,
    required this.referencia,
    required this.fechaInicial,
    required this.fechaFinal,
    required this.tarea,
  }) : super(key: key);

  Color _getFranjaColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case "CRITICO":
        return hexToColor("#FA5858");
      case "ALTO":
        return hexToColor("#5858FA");
      case "NORMAL":
        return hexToColor("#F4FA58");
      case "BAJO":
        return hexToColor("#2EFE2E");
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color franjaColor = _getFranjaColor(prioridad);
    Color circuloColor = hexToColor(backColor);
    final bool isDark = AppTheme.isDark();
    final Color textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => _navegarADetalle(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBackroundColor : AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: franjaColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRichText("ID: ", id, textColor),
                      const SizedBox(height: 5),
                      _buildRichText(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tablero, 'Descripcion'),
                        descripcion,
                        textColor,
                      ),
                      const SizedBox(height: 5),
                      _buildRichText(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tablero, 'FechaInicial'),
                        _formatearFecha(fechaInicial),
                        textColor,
                      ),
                      _buildRichText(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tablero, 'FechaFinal'),
                        _formatearFecha(fechaFinal),
                        textColor,
                      ),
                      _buildRichText(
                        AppLocalizations.of(
                          context,
                        )!.translate(BlockTranslate.tablero, 'Referencia'),
                        ": $descripcionReferencia ($referencia)",
                        textColor,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(radius: 10, backgroundColor: circuloColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Navegar al detalle de la tarea - SOLUCIÓN OPTIMIZADA
  void _navegarADetalle(BuildContext context) async {
    final vmDetalle = Provider.of<DetalleTareaViewModel>(
      context,
      listen: false,
    );

    // Convertir la tarea
    final tareaModel = _convertToTareaModel(tarea);

    // Asignar la tarea al ViewModel del detalle
    vmDetalle.tarea = tareaModel;

    // 🔹 ACTIVAR LOADING INMEDIATAMENTE
    vmDetalle.isLoading = true;

    // Navegar inmediatamente para que se vea el loading
    Navigator.pushNamed(context, AppRoutes.detailsTask);

    // 🔹 EJECUTAR LA CARGA DE DATOS DESPUÉS DE LA NAVEGACIÓN
    // Esto hará que el loading se muestre en la vista del detalle
    try {
      await vmDetalle.loadData(context);
    } catch (e) {
      print("Error al cargar datos del detalle: $e");
      // Asegurarse de desactivar el loading incluso si hay error
      vmDetalle.isLoading = false;
    }
  }

  /// 🔹 Convertir Tarea a TareaModel - USANDO fromMap
  TareaModel _convertToTareaModel(Tarea tarea) {
    final Map<String, dynamic> jsonMap = {
      "id": tarea.id,
      "tarea": tarea, // 🔹 PARÁMETRO REQUERIDO - pasamos la tarea completa
      "iD_Tarea": tarea.iDTarea,
      "usuario_Creador": tarea.usuarioCreador,
      "email_Creador": tarea.emailCreador,
      "usuario_Responsable": tarea.usuarioResponsable,
      "descripcion": tarea.descripcion,
      "fecha_Inicial": tarea.fechaInicial.toIso8601String(),
      "fecha_Final": tarea.fechaFinal.toIso8601String(),
      "referencia": tarea.referencia,
      "iD_Referencia": tarea.iDReferencia,
      "descripcion_Referencia": tarea.descripcionReferencia,
      "ultimo_Comentario": tarea.ultimoComentario,
      "fecha_Ultimo_Comentario": tarea.fechaUltimoComentario?.toIso8601String(),
      "usuario_Ultimo_Comentario": tarea.usuarioUltimoComentario,
      "tarea_Observacion_1": tarea.tareaObservacion1,
      "tarea_Fecha_Ini": tarea.tareaFechaIni.toIso8601String(),
      "tarea_Fecha_Fin": tarea.tareaFechaFin.toIso8601String(),
      "tipo_Tarea": tarea.tipoTarea,
      "descripcion_Tipo_Tarea": tarea.descripcionTipoTarea,
      "estado_Objeto": tarea.estadoObjeto,
      "tarea_Estado": tarea.tareaEstado,
      "usuario_Tarea": tarea.usuarioTarea,
      "backColor": tarea.backColor,
      "nivel_Prioridad": tarea.nivelPrioridad,
      "nom_Nivel_Prioridad": tarea.nomNivelPrioridad,
      "registros": tarea.registros,
      "filtroTodasTareas": tarea.filtroTodasTareas,
      "filtroMisTareas": tarea.filtroMisTareas,
      "filtroMisResponsabilidades": tarea.filtroMisResponsabilidades,
      "filtroMisInvitaciones": tarea.filtroMisInvitaciones,
    };

    return TareaModel.fromMap(jsonMap);
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildRichText(String label, String value, Color textColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
