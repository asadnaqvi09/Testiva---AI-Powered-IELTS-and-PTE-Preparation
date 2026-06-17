import 'package:flutter/material.dart';

/// Central dark mode helper for the entire Testiva app.
/// Import this file in any screen: import 'package:frontend/widgets/app_theme.dart';
/// Then use AppTheme.isDark(context), AppTheme.cardBg(context), etc.
class AppTheme {
  // ── Boolean check ────────────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Background colors ────────────────────────────────────────────────────
  static Color scaffoldBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : const Color(0xFFF8FAFC);

  static Color cardBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color surfaceBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF2C2C2C) : const Color(0xFFF8FAFC);

  static Color inputFill(BuildContext context) =>
      isDark(context) ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

  static Color appBarBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color drawerBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF121212) : Colors.white;

  static Color dialogBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.white;

  static Color tipBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E293B) : const Color(0xFFE3F2FD);

  static Color tileItemBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E1E1E) : Colors.grey.shade50;

  // ── Text colors ───────────────────────────────────────────────────────────
  static Color primaryText(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF0F172A);

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? Colors.grey.shade400 : Colors.grey.shade600;

  static Color iconColor(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black87;

  // ── Border / divider colors ───────────────────────────────────────────────
  static Color borderColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF3A3A3A) : const Color(0xFFE2E8F0);

  static Color dividerColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF2C2C2C) : const Color(0xFFE2E8F0);

  // ── Tag / chip colors ─────────────────────────────────────────────────────
  static Color tagBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A2A40) : const Color(0xFFEDF5FF);

  static Color tagText(BuildContext context) =>
      isDark(context) ? Colors.lightBlueAccent : Colors.blue;

  // ── Utility shadows ───────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow(BuildContext context) => isDark(context)
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ];
}
