import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../../providers/theme_provider.dart';

class PreferenceTiles extends StatefulWidget {
  final bool isDarkMode;
  const PreferenceTiles({super.key, required this.isDarkMode});

  @override
  State<PreferenceTiles> createState() => _PreferenceTilesState();
}

class _PreferenceTilesState extends State<PreferenceTiles> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadToggles();
  }

  Future<void> _loadToggles() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _pushNotifications = prefs.getBool('pref_push_notifications') ?? true;
      _emailNotifications = prefs.getBool('pref_email_notifications') ?? false;
    });
  }

  Future<void> _setToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            context,
            Icons.notifications_outlined,
            'Push Notifications',
            _pushNotifications,
            (value) {
              setState(() => _pushNotifications = value);
              _setToggle('pref_push_notifications', value);
            },
          ),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          _buildSwitchTile(
            context,
            Icons.mail_outline,
            'Email Notifications',
            _emailNotifications,
            (value) {
              setState(() => _emailNotifications = value);
              _setToggle('pref_email_notifications', value);
            },
          ),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          _buildSwitchTile(
            context,
            Icons.dark_mode_outlined,
            'Dark Mode',
            themeProvider.isDarkMode,
            (value) => themeProvider.toggleTheme(value),
          ),
        ],
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
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: AppTheme.primaryText(context)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: Colors.blue,
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}
