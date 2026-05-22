import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService ka path verify kar lein
import '../../../../providers/theme_provider.dart';

class PreferenceTiles extends StatefulWidget {
  final bool isDarkMode;
  const PreferenceTiles({super.key, required this.isDarkMode});

  @override
  State<PreferenceTiles> createState() => _PreferenceTilesState();
}

class _PreferenceTilesState extends State<PreferenceTiles> {
  bool _pushNotifications = true; // Default fallback state
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences();
  }

  // 🚀 Server se user ki preferences settings fetch karna
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

  // 🔄 Notification preferences change hone par backend hit karna
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
        // Agar fail ho jaye to UI wapas purani state par revert kar dein
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!widget.isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
            'Push Notifications',
            _pushNotifications,
            _isUpdating ? null : _toggleNotification, // Switch disable ho jayega loading ke dauran
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildSwitchTile(
            context,
            Icons.dark_mode_outlined,
            'Dark Mode',
            widget.isDarkMode,
                (value) {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, Function(bool)? onChanged) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
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