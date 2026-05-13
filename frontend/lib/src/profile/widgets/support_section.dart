import 'package:flutter/material.dart';
import '../../features/settings/presentation/feedback_screen.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (isLight)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5)
            )
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            context,
            Icons.feedback_outlined,
            'Feedback & Suggestions',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _actionTile(context, Icons.help_outline, 'Help Center & FAQ', () {}),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _actionTile(context, Icons.shield_outlined, 'Privacy & Security', () {}),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
      dense: true,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}