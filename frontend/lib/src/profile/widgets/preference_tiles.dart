import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart';

class PreferenceTiles extends StatelessWidget {
  final bool isDarkMode;
  const PreferenceTiles({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            Icons.notifications_none,
            "Push Notifications",
            true,
                (v) {},
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildSwitchTile(
            context,
            Icons.dark_mode_outlined,
            "Dark Mode",
            isDarkMode,
                (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}