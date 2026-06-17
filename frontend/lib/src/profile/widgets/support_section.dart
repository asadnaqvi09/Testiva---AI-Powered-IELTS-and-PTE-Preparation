import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../features/settings/presentation/feedback_screen.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppTheme.cardShadow(context),
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
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          _actionTile(context, Icons.help_outline, 'Help Center & FAQ', () {}),
          Divider(height: 1, color: AppTheme.dividerColor(context)),
          _actionTile(context, Icons.shield_outlined, 'Privacy & Security', () {}),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryText(context)),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, color: AppTheme.primaryText(context)),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.secondaryText(context), size: 14),
      dense: true,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}