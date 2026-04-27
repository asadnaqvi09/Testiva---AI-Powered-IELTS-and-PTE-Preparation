import 'package:flutter/material.dart';
import '../../../../widgets/logout_dialog.dart';
import '../../profile/profile_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              _drawerItem(
                context,
                Icons.settings_outlined,
                'Settings',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              _drawerItem(
                context,
                Icons.chat_bubble_outline,
                'Feedback',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              _drawerItem(context, Icons.notifications_none_outlined, 'Notifications', onTap: () {}),
              _drawerItem(context, Icons.star_outline, 'Rate App', onTap: () {}),
              const Spacer(),
              _logoutBtn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFF007BFF),
          child: Text('AK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ahmed Khan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Free Member', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xFF007BFF)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: onTap,
    ),
  );

  Widget _logoutBtn(BuildContext context) => InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) => const LogoutDialog(),
      );
    },
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFEBEE)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.redAccent, size: 20),
          SizedBox(width: 10),
          Text(
            'Logout',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}