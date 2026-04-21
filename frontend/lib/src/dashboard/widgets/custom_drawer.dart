import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF007BFF),
                    child: Text("AK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Ahmed Khan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Free Member", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),
              _drawerItem(Icons.settings_outlined, "Settings"),
              _drawerItem(Icons.chat_bubble_outline, "Feedback"),
              _drawerItem(Icons.notifications_none_outlined, "Notifications"),
              _drawerItem(Icons.star_outline, "Rate App"),
              const Spacer(),
              _logoutBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) => ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    onTap: () {},
  );

  Widget _logoutBtn() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 20),
    child: OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout, color: Colors.redAccent),
      label: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(color: Color(0xFFFFEBEE)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xFFFFFBFC),
      ),
    ),
  );
}