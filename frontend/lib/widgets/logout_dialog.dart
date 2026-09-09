import 'package:flutter/material.dart';
import 'package:frontend/core/services/logout_helper.dart';
import 'app_theme.dart';

class LogoutDialog extends StatelessWidget {
  final BuildContext hostContext;

  const LogoutDialog({
    super.key,
    required this.hostContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.dialogBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.logout_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText(context),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to log out of Testiva AI? Your current active learning session parameters will be saved securely.',
            style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 14),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await LogoutHelper.performLogoutAllDevices(hostContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB91C1C),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Logout all devices',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.secondaryText(context),
          ),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await LogoutHelper.performLogout(hostContext);
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
