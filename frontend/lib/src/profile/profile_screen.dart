import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/profile_header.dart';
import 'widgets/edit_profile_modal.dart';
import '../dashboard/home/widgets/stats_row.dart';
import 'widgets/progress_graph.dart';
import 'widgets/preference_tiles.dart';
import 'widgets/support_section.dart';
import 'all_tests_screen.dart';

import '../../widgets/custom_drawer.dart';
import '../../widgets/app_header.dart';
import '../../widgets/logout_dialog.dart';
import '../../widgets/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final bool asTab;

  const ProfileScreen({super.key, this.asTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  bool _avatarUploading = false;

  Map<String, dynamic> _userData = {
    'name': 'User',
    'email': '',
    'isPremium': false,
    'preference': null,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserProfileData();
  }

  Future<void> _fetchUserProfileData() async {
    try {
      final response = await ApiService.get('/user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'] as Map<String, dynamic>;
          final unlocked = user['unlocked_exam']?.toString();
          final subscription = (user['subscription'] ?? 'free').toString();
          final newUserData = {
            'id': user['id'],
            'name': user['full_name'] ?? user['name'] ?? 'User Name',
            'email': user['email'] ?? 'user@email.com',
            'isPremium':
                subscription.toLowerCase() == 'premium' ||
                unlocked?.toUpperCase() == 'BOTH',
            'preference': user['preference'],
            'role': user['role'] ?? 'user',
            'subscription': subscription,
            'unlocked_exam': unlocked,
            'avatar_url': user['avatar_url'],
            'created_at': user['created_at'] ?? user['member_since'],
          };
          setState(() {
            _userData = newUserData;
            _isLoading = false;
          });
          UserNotifier.notifier.value = {
            ...UserNotifier.notifier.value,
            ...newUserData,
          };
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _avatarUploading = true);
      final response = await ApiService.uploadAvatar(picked.path);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (response.statusCode == 200 && body['success'] == true) {
        final user = body['user'];
        if (user is Map) {
          setState(() {
            _userData = {
              ..._userData,
              'avatar_url': user['avatar_url'],
              'name': user['full_name'] ?? _userData['name'],
            };
          });
          UserNotifier.notifier.value = {
            ...UserNotifier.notifier.value,
            'avatar_url': user['avatar_url'],
          };
        } else {
          await _fetchUserProfileData();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message']?.toString() ?? 'Avatar upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _avatarUploading = false);
    }
  }

  // ── Preference Change Request Modal ──────────────────────────────────────
  void _showPreferenceChangeDialog() {
    final currentPref = _userData['preference']?.toString() ?? 'IELTS';
    final otherPref = currentPref.toUpperCase() == 'IELTS' ? 'PTE' : 'IELTS';
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppTheme.cardBg(context),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz,
                        color: Color(0xFF007BFF), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Request Preference Change',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9E6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE599)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFFD97706), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your preference ($currentPref) is a one-time selection. '
                              'To request a change to $otherPref, please provide a reason below. '
                              'Our admin will review your request.',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF92400E),
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Reason for changing to $otherPref *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: TextStyle(
                          color: AppTheme.primaryText(context), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Reason for changing preference...',
                        hintStyle: TextStyle(
                            color: AppTheme.secondaryText(context),
                            fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.scaffoldBg(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppTheme.borderColor(context)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF007BFF), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minimum 10 characters required',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.secondaryText(context)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.secondaryText(context)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final reason = reasonController.text.trim();
                          if (reason.length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please provide a reason (min 10 characters)'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            final resp = await ApiService.post(
                              '/user/request-preference-change',
                              {
                                'feedback': reason,
                                'targetPreference': otherPref,
                              },
                            );
                            final body = jsonDecode(resp.body);
                            if (!context.mounted) return;

                            Navigator.pop(dialogCtx);

                            if (resp.statusCode == 200 &&
                                body['success'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Your request has been sent to the admin for review.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(body['message'] ??
                                      'Failed to submit request'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connection error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setDialogState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Request',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Preference Tile ───────────────────────────────────────────────────────
  Widget _buildAllTestsTile() {
    return Material(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AllTestsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066F5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history, color: Color(0xFF0066F5)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Tests',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                    Text(
                      'View completed and offline-saved attempts',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.secondaryText(context)),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasFullTestAccess {
    final role = _userData['role']?.toString().toLowerCase();
    final sub = _userData['subscription']?.toString().toLowerCase();
    return role == 'admin' || sub == 'premium';
  }

  Widget _buildPreferenceTile() {
    final pref = _userData['preference']?.toString();
    final displayPref = _hasFullTestAccess
        ? 'All Tests'
        : ((pref != null && pref.isNotEmpty) ? pref : 'Not Set');
    final prefColor = _hasFullTestAccess
        ? const Color(0xFF6366F1)
        : displayPref == 'IELTS'
            ? const Color(0xFF007BFF)
            : const Color(0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppTheme.cardShadow(context),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: prefColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            displayPref.toUpperCase() == 'PTE' ? '🌐' : 'GB',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          displayPref,
          style: TextStyle(
              fontSize: 15,
              color: AppTheme.primaryText(context),
              fontWeight: FontWeight.w700),
        ),
        trailing: Icon(Icons.chevron_right,
            color: AppTheme.secondaryText(context)),
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: (!_hasFullTestAccess && pref != null) ? _showPreferenceChangeDialog : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppHeader(
        scaffoldKey: _scaffoldKey,
        showBackButton: widget.asTab ? false : null,
        showProfileAvatar: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF007BFF)))
            : RefreshIndicator(
                onRefresh: _fetchUserProfileData,
                color: const Color(0xFF007BFF),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryText(context),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => EditProfileModal(
                                  currentName: _userData['name'] ?? '',
                                  currentEmail: _userData['email'] ?? '',
                                  onProfileUpdated: _fetchUserProfileData,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 14, color: Color(0xFF007BFF)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Color(0xFF007BFF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ProfileHeader(
                        isDarkMode: AppTheme.isDark(context),
                        userData: _userData,
                        onEditPressed: null,
                        onAvatarTap: _pickAndUploadAvatar,
                        avatarUploading: _avatarUploading,
                      ),
                      const SizedBox(height: 25),
                      const StatsRow(),
                      const SizedBox(height: 25),
                      const ProgressGraph(),
                      const SizedBox(height: 30),

                      Text(
                        'Test History',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context)),
                      ),
                      const SizedBox(height: 12),
                      _buildAllTestsTile(),

                      const SizedBox(height: 30),
                      Text(
                        'Test Preference',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context)),
                      ),
                      const SizedBox(height: 12),
                      _buildPreferenceTile(),
                      const SizedBox(height: 24),
                      Text(
                        'Preferences',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context)),
                      ),
                      const SizedBox(height: 12),
                      PreferenceTiles(isDarkMode: AppTheme.isDark(context)),

                      const SizedBox(height: 25),
                      Text(
                        'Support',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context)),
                      ),
                      const SizedBox(height: 15),
                      const SupportSection(),
                      const SizedBox(height: 30),
                      _buildLogoutButton(context),
                      const SizedBox(height: 25),
                      const Center(
                        child: Text(
                          'Testiva v1.0.0 • © 2026',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFFFFF1F2),
      ),
      child: MaterialButton(
        onPressed: () {
          final hostContext = context;
          showDialog(
            context: hostContext,
            builder: (dialogContext) => LogoutDialog(hostContext: hostContext),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 18),
            SizedBox(width: 8),
            Text('Logout',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}