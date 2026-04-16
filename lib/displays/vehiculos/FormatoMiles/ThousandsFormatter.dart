import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si el texto está vacío, no aplicar formato
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Eliminar cualquier carácter que no sea número
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Evitar errores si no hay dígitos
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Convertir a número y formatear
    final number = int.parse(digitsOnly);
    final newText = _formatter.format(number);

    // Mantener el cursor al final
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}