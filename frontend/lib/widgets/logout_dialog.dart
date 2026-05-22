import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Direct token flushing injection

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  // 🚀 Centralized execution session cleanup pipeline
  Future<void> _handleSecureLogout(BuildContext context) async {
    try {
      // 1. Directly flush secure tokens and authentication keys from local cache memory
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Removes raw bearer token string securely
      await prefs.remove('user_data'); // Removes metadata dictionary string if saved

      // Agar aap pure cache ko wipeout karna chahte hain toh single execution bhee run kar sakte hain:
      // await prefs.clear();
    } catch (e) {
      debugPrint("Local cache tracking flush error: ${e.toString()}");
    } finally {
      // 2. Clear routing histories stack and push context back down cleanly to root route '/'
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/', // Safely remapped to root matching your main.dart paths setup
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to log out of Testiva AI? Your current active learning session parameters will be saved securely.',
        style: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 14,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      actions: [
        // Cancel Operation Interaction Button
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.white60 : Colors.black54,
          ),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),

        // Destructive Action Logout Processing Button
        ElevatedButton(
          onPressed: () {
            // Close active overlay dialog modal interface
            Navigator.pop(context);
            // Run state-machine pipeline logic engine
            _handleSecureLogout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}