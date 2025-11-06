import 'package:flutter/material.dart';

class DateModelView {
  // Método para mostrar el DatePicker y TimePicker
  static Future<DateTime?> selectDateTime({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    // Primero seleccionar la fecha
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    // Si el usuario seleccionó una fecha, ahora seleccionar la hora
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      // Si el usuario seleccionó una hora, combinar fecha y hora
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    
    return null;
  }

  // Método para formatear la fecha y hora a un string legible
  static String formatDateTime(DateTime date) {
    final String period = date.hour < 12 ? 'am' : 'pm';
    final int hour12 = date.hour > 12 ? date.hour - 12 : date.hour;
    
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year} ${_twoDigits(hour12)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)} $period';
  }

  // Método para formatear solo la fecha (sin hora)
  static String formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  // Método para formatear solo la hora
  static String formatTime(DateTime date) {
    final String period = date.hour < 12 ? 'am' : 'pm';
    final int hour12 = date.hour > 12 ? date.hour - 12 : date.hour;
    
    return '${_twoDigits(hour12)}:${_twoDigits(date.minute)}:${_twoDigits(date.second)} $period';
  }

  // Método auxiliar para asegurar 2 dígitos
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // Método para obtener la fecha y hora actual formateada
  static String getCurrentDateTimeFormatted() {
    return formatDateTime(DateTime.now());
  }

  // Método para seleccionar solo fecha (mantener compatibilidad)
  static Future<DateTime?> selectDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await selectDateTime(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
}