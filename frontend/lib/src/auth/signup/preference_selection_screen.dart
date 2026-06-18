import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_navigation_helper.dart';
import '../../../core/services/user_notifier.dart';
import '../../../widgets/app_theme.dart';

class PreferenceSelectionScreen extends StatefulWidget {
  final String userName;

  const PreferenceSelectionScreen({
    super.key,
    required this.userName,
  });

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  String? _selectedPreference; // 'IELTS' or 'PTE'
  bool _isSaving = false;

  Future<void> _handleSavePreference() async {
    if (_selectedPreference == null) return;

    setState(() => _isSaving = true);

    try {
      final response = await ApiService.post('/auth/user/preferences', {
        'preference': _selectedPreference,
      });

      final responseData = jsonDecode(response.body);

      if (mounted) {
        if (response.statusCode == 200 && responseData['success'] == true) {
          await ApiService.persistAuthResponse(responseData);

          final user = Map<String, dynamic>.from(
            (responseData['user'] as Map<String, dynamic>?) ??
                UserNotifier.notifier.value,
          );
          user['preference'] = _selectedPreference;

          if (!mounted) return;

          await AuthNavigationHelper.navigateAfterAuth(
            context,
            user: user,
            successMessage:
                'Welcome to Testiva! Selected $_selectedPreference track.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to save preference'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final scaffoldBg = AppTheme.scaffoldBg(context);
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);
    final borderColor = AppTheme.borderColor(context);

    // Color definitions
    final ieltsSelectedColor = const Color(0xFF007BFF);
    final pteSelectedColor = const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Top Header Row (Logo & App Name)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: primaryText),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Testiva',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Main Header
                Row(
                  children: [
                    Text(
                      'Choose Your Test',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '🎯',
                      style: TextStyle(fontSize: 26),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subtitle
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: secondaryText,
                    ),
                    children: [
                      const TextSpan(text: 'Hi '),
                      TextSpan(
                        text: widget.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      const TextSpan(
                        text: '! Which test are you preparing for? This is a one-time selection — choose carefully.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // IELTS Option
                _buildTestCard(
                  title: 'IELTS',
                  subtitle: 'International English Language Testing System',
                  description: 'Required for UK, Australia, Canada immigration & university admissions',
                  tags: ['UK', 'Australia', 'Canada', 'New Zealand'],
                  avatarWidget: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'GB',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ),
                  isSelected: _selectedPreference == 'IELTS',
                  selectedColor: ieltsSelectedColor,
                  onTap: () => setState(() => _selectedPreference = 'IELTS'),
                ),
                const SizedBox(height: 20),

                // PTE Option
                _buildTestCard(
                  title: 'PTE Academic',
                  subtitle: 'Pearson Test of English Academic',
                  description: 'Fully computer-based test, fast results within 2 business days',
                  tags: ['Australia', 'New Zealand', 'UK', 'Canada'],
                  avatarWidget: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF065F46) : const Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.language,
                        size: 20,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857),
                      ),
                    ),
                  ),
                  isSelected: _selectedPreference == 'PTE',
                  selectedColor: pteSelectedColor,
                  onTap: () => setState(() => _selectedPreference = 'PTE'),
                ),
                const SizedBox(height: 30),

                // Info Warning Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.15) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark ? const Color(0xFFB45309).withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Can I change this later?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yes — but changing your preference requires admin approval after your initial selection. Premium users get access to both IELTS and PTE simultaneously.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_selectedPreference == null || _isSaving)
                        ? null
                        : _handleSavePreference,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedPreference == 'IELTS'
                          ? ieltsSelectedColor
                          : (_selectedPreference == 'PTE' ? pteSelectedColor : Colors.grey),
                      disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue with Selected Test',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                            ],
                          ),
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

  Widget _buildTestCard({
    required String title,
    required String subtitle,
    required String description,
    required List<String> tags,
    required Widget avatarWidget,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.cardBg(context);
    final primaryText = AppTheme.primaryText(context);
    final secondaryText = AppTheme.secondaryText(context);
    final borderColor = AppTheme.borderColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? selectedColor.withValues(alpha: 0.1)
                  : selectedColor.withValues(alpha: 0.05))
              : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarWidget,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: primaryText.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags.map((tag) => _buildChip(tag)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String tag) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
