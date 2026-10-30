import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../../core/services/api_service.dart';
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
  bool _quietHours = false;
  bool _savingQuiet = false;

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
      _quietHours = prefs.getBool('pref_quiet_hours') ?? false;
    });
  }

  Future<void> _setToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// L7 — sync quiet hours into server notif_prefs (FCM gated backend-side)
  Future<void> _setQuietHours(bool enabled) async {
    setState(() {
      _quietHours = enabled;
      _savingQuiet = true;
    });
    await _setToggle('pref_quiet_hours', enabled);
    try {
      final res = await ApiService.put('/user/settings', {
        'notif_prefs': {
          'quietHoursEnabled': enabled,
          'quietStart': '22:00',
          'quietEnd': '07:00',
          'timezone': 'Asia/Karachi',
          'digestEnabled': false,
        },
      });
      if (res.statusCode != 200 && mounted) {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message']?.toString() ?? 'Could not save quiet hours'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiet hours saved locally; sync when online'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingQuiet = false);
    }
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
            Icons.bedtime_outlined,
            'Quiet hours (10pm–7am)',
            _quietHours,
            _savingQuiet ? null : (value) => _setQuietHours(value),
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
