import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../../providers/theme_provider.dart';

/// Minimal preference tile — only contains the Dark Mode toggle.
/// Push Notifications have been removed (no backend endpoint).
/// Exam preference is now managed via the dedicated PreferenceTile in profile_screen.dart.
class PreferenceTiles extends StatelessWidget {
  final bool isDarkMode;
  const PreferenceTiles({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: _buildSwitchTile(
        context,
        Icons.dark_mode_outlined,
        'Dark Mode',
        themeProvider.isDarkMode,
        (value) => themeProvider.toggleTheme(value),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    IconData icon,
    String title,
    bool value,
    Function(bool)? onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title,
          style: TextStyle(
              fontSize: 14, color: AppTheme.primaryText(context))),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: Colors.blue,
      ),
      dense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}