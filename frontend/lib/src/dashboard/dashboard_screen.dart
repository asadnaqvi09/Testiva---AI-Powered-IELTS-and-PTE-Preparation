import 'dart:convert';
import 'package:flutter/material.dart';
import 'home/home_page.dart';
import '../../widgets/custom_drawer.dart';
import '../profile/profile_screen.dart';
import '../mocks/mocks_screen.dart';
import '../prep/prep_screen.dart';
import '../features/community/presentation/community_screen.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndCheckPreference();
  }

  Future<void> _fetchUserProfileAndCheckPreference() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          final newUserData = {
            'name': user['full_name'] ?? user['name'] ?? 'User Name',
            'email': user['email'] ?? 'user@email.com',
            'isPremium': (user['subscription'] ?? '').toString().toLowerCase() == 'premium',
            'preference': user['preference'],
            'role': user['role'] ?? 'user',
            'subscription': user['subscription'] ?? 'free',
          };
          UserNotifier.notifier.value = newUserData;

          if (user['preference'] == null) {
            if (mounted) {
              _showTrackSelectionDialog();
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Dashboard profile fetch error: $e");
    }
  }

  void _showTrackSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              'Choose Your Exam Track',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: const Text(
              'Welcome to Testiva! Please select your target exam track to customize your IELTS or PTE preparation journey.\n\nNote: This track will be locked once selected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actionsPadding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
            actions: [
              _buildTrackButton('IELTS', Colors.blue),
              _buildTrackButton('PTE', Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackButton(String track, Color color) {
    bool isBtnLoading = false;
    return StatefulBuilder(
      builder: (context, setBtnState) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: isBtnLoading ? null : () async {
            setBtnState(() => isBtnLoading = true);
            try {
              final response = await ApiService.post('/auth/user/preferences', {
                'preference': track,
              });
              if (response.statusCode == 200) {
                final body = jsonDecode(response.body);
                if (body['success'] == true) {
                  if (body['accessToken'] != null) {
                    await ApiService.setToken(body['accessToken']);
                  }
                  
                  final currentData = Map<String, dynamic>.from(UserNotifier.notifier.value);
                  currentData['preference'] = track;
                  if (body['user'] != null) {
                    currentData['name'] = body['user']['full_name'] ?? currentData['name'];
                  }
                  UserNotifier.notifier.value = currentData;
                  
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to lock preference. Please try again.')),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Connection error: $e')),
                );
              }
            } finally {
              setBtnState(() => isBtnLoading = false);
            }
          },
          child: isBtnLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(track, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        );
      }
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleStartTestFlow() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(
        scaffoldKey: _scaffoldKey,
        onActionTap: _onTabChanged,
        onNavigateToPrep: () => _onTabChanged(2),
      ),
      MocksScreen(onStartTestRequested: _handleStartTestFlow),
      const PrepScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF007BFF),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mocks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Prep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}