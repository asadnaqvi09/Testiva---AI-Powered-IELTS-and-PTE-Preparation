import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';


class ThemeHelper {
  static Color getCardColor(BuildContext context) => AppTheme.cardBg(context);

  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      color: AppTheme.primaryText(context),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }
}