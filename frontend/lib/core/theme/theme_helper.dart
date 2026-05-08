import 'package:flutter/material.dart';

class ThemeHelper {
  static Color getCardColor(BuildContext context) {
   return Theme.of(context).brightness == Brightness.dark
       ? const Color(0xFF1E1E1E)
     : Colors.white;
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }
}