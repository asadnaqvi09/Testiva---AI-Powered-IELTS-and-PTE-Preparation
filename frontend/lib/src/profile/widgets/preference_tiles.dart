import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../../providers/theme_provider.dart';

class PreferenceTiles extends StatefulWidget {
  // isDarkMode param kept for backward compat — AppTheme used internally
  final bool isDarkMode;
  const PreferenceTiles({super.key, required this.isDarkMode});

  @override
  State<PreferenceTiles> createState() => _PreferenceTilesState();
}

class _PreferenceTilesState extends State<PreferenceTiles> {
  bool _pushNotifications = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences();
  }

  Future<void> _fetchUserPreferences() async {
    try {
      final response = await ApiService.get('/user/preferences');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['preferences'] != null) {
          setState(() {
            _pushNotifications = data['preferences']['pushNotifications'] ?? true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching preferences: $e");
    }
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _pushNotifications = value;
      _isUpdating = true;
    });

    try {
      final response = await ApiService.post('/user/update-preferences', {
        'pushNotifications': value,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        setState(() {
          _pushNotifications = !value;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to update settings'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _pushNotifications = !value;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error: Server failure'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
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
            Icons.notifications_none,
            'Push Notifications',
            _pushNotifications,
            _isUpdating ? null : _toggleNotification,
          ),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          _buildSwitchTile(
            context,
            Icons.dark_mode_outlined,
            'Dark Mode',
            themeProvider.isDarkMode,
            (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, Function(bool)? onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: TextStyle(fontSize: 14, color: AppTheme.primaryText(context))),
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