import 'package:flutter/material.dart';
import 'widgets/progress_graph.dart';
import '../../../widgets/logout_dialog.dart';
import '../dashboard/widgets/custom_drawer.dart';
import 'widgets/edit_profile_modal.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pushNotify = true, emailNotify = false, darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const ProfileHeader(),
            const SizedBox(height: 25),
            const StatsSection(),
            const SizedBox(height: 25),
            const ProgressGraph(),
            const SizedBox(height: 25),
            _sectionTitle('Preferences'),
            _buildPreferenceBox(),
            const SizedBox(height: 20),
            _buildSupportBox(),
            const SizedBox(height: 25),
            _premiumBanner(),
            const SizedBox(height: 30),
            const LogoutButton(),
            const SizedBox(height: 30),
            const Center(child: Text('Testiva v1.0.0 - © 2026', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.menu, color: Color(0xFF1E293B)),
      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
    ),
    title: const Text('Testiva', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 15),
        child: CircleAvatar(radius: 18, backgroundColor: Color(0xFF007BFF), child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 12))),
      )
    ],
  );

  Widget _premiumBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF9E7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFE58F)),
    ),
    child: const Row(
      children: [
        Icon(Icons.workspace_premium_outlined, color: Color(0xFFD48806), size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Unlock IELTS & PTE - Get Premium',
            style: TextStyle(color: Color(0xFF874D00), fontWeight: FontWeight.w600),
          ),
        ),
        Icon(Icons.chevron_right, color: Color(0xFFD48806)),
      ],
    ),
  );

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _buildPreferenceBox() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      children: [
        _switchTile(Icons.notifications_none, 'Push Notifications', pushNotify, (v) => setState(() => pushNotify = v)),
        _switchTile(Icons.mail_outline, 'Email Notifications', emailNotify, (v) => setState(() => emailNotify = v)),
        _switchTile(Icons.dark_mode_outlined, 'Dark Mode', darkMode, (v) => setState(() => darkMode = v)),
      ],
    ),
  );

  Widget _buildSupportBox() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: const Column(
      children: [
        ProfileTile(icon: Icons.chat_bubble_outline, title: 'Feedback & Suggestions'),
        ProfileTile(icon: Icons.help_outline, title: 'Help Center & FAQ'),
        ProfileTile(icon: Icons.shield_outlined, title: 'Privacy & Security'),
      ],
    ),
  );

  Widget _switchTile(IconData icon, String title, bool val, Function(bool) onChanged) => ListTile(
    leading: Icon(icon, color: const Color(0xFF64748B)),
    title: Text(title),
    trailing: Switch(value: val, onChanged: onChanged, activeTrackColor: const Color(0xFF007BFF)),
  );
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(color: const Color(0xFF007BFF), borderRadius: BorderRadius.circular(15)),
          child: const Center(child: Text('AK', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 15),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ahmed Khan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('freeuser@example.com', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const EditProfileModal(),
            );
          },
          icon: const Icon(Icons.edit_outlined, size: 20),
        )
      ],
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatCard(label: 'Tests Done', value: '5', color: Color(0xFF007BFF)),
        StatCard(label: 'Est. Band', value: '6.5', color: Color(0xFF10B981)),
        StatCard(label: 'Best Score', value: '7.0', color: Color(0xFFF59E0B)),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const StatCard({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const ProfileTile({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {},
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog(context: context, builder: (c) => const LogoutDialog()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: const Color(0xFFFFFBFC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFFEBEE))),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 18),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}