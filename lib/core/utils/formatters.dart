import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Ne garder que les chiffres
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limiter à 8 chiffres
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;
    
    // Formater: XX XX XX XX
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 2 == 0) {
        buffer.write(' ');
      }
      buffer.write(limited[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Première lettre en majuscule, reste en minuscule
    if (newValue.text.isEmpty) return newValue;
    
    final text = newValue.text;
    final formatted = text[0].toUpperCase() + 
        (text.length > 1 ? text.substring(1).toLowerCase() : '');
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: TextSelection.collapsed(offset: newValue.text.length),
    );
  }
}

class NoSpecialCharsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Autoriser lettres, chiffres, espaces et tirets
    final filtered = newValue.text.replaceAll(RegExp(r'[^\w\s\-]'), '');
    
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
