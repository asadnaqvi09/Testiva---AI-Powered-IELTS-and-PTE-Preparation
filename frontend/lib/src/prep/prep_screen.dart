import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/widgets/app_header.dart';
import 'package:frontend/src/prep/widgets/module_card.dart';
import 'package:frontend/widgets/custom_drawer.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../../../data/models/prep_module_model.dart';
import '../dashboard/home/widgets/premium_modal.dart';

class PrepScreen extends StatefulWidget {
  const PrepScreen({super.key});

  @override
  State<PrepScreen> createState() => _PrepScreenState();
}

class _PrepScreenState extends State<PrepScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedType = 'IELTS';
  bool _isLoading = true;
  List<PrepModule> _liveModules = [];


  final List<String> _aiTips = [
    "Focus on Writing Task 2 - it carries the most weight in your score.",
    "Your Reading speed is improving! Try the 'Matching Headings' practice.",
    "Listening practice: focus on signpost words like 'however' or 'finally'.",
    "Speaking Tip: Record yourself and listen for filler words like 'um' or 'uh'.",
    "Consistency is key! Keep up your daily streak for a higher band score."
  ];
  String _currentTip = "Focus on Writing Task 2 - it carries the most weight in your score.";
  String? _focusModule;
  String? _focusReason;

  @override
  void initState() {
    super.initState();
    UserNotifier.notifier.addListener(_onUserChanged);
    final userPref = UserNotifier.notifier.value['preference'];
    if (userPref != null) {
      selectedType = userPref.toUpperCase();
    } else {
      selectedType = 'IELTS';
    }
    _fetchLiveModules();
  }

  void _onUserChanged() {
    if (mounted) {
      final userPref = UserNotifier.notifier.value['preference'];
      if (userPref != null) {
        final newType = userPref.toUpperCase();
        if (selectedType != newType) {
          setState(() {
            selectedType = newType;
          });
          _fetchLiveModules();
        }
      }
    }
  }

  @override
  void dispose() {
    UserNotifier.notifier.removeListener(_onUserChanged);
    super.dispose();
  }

  Future<void> _refreshAIRecommendation() async {
    try {
      final response = await ApiService.get('/ai/recommendation?exam_type=$selectedType');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['tip'] != null) {
          if (mounted) {
            setState(() {
              _currentTip = body['tip'];
              _focusModule = body['focus_module']?.toString();
              _focusReason = body['reason']?.toString();
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching AI recommendation: $e");
    }
    if (mounted) {
      setState(() {
        _currentTip = _aiTips[Random().nextInt(_aiTips.length)];
        _focusModule = null;
        _focusReason = null;
      });
    }
  }

  Future<void> _fetchLiveModules() async {
    setState(() => _isLoading = true);
    _refreshAIRecommendation();
    try {
      final response = await ApiService.get('/content/preparations?test_type=$selectedType');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List dynamicList = data['data'];
          if (mounted) {
            setState(() {
              _liveModules = dynamicList.map((json) {
                String sectionStr = (json['section'] ?? json['title'] ?? '').toString();
                String titleLower = sectionStr.toLowerCase();
                IconData moduleIcon = Icons.book_outlined;
                if (titleLower.contains('read')) moduleIcon = Icons.book_outlined;
                if (titleLower.contains('writ')) moduleIcon = Icons.edit_note;
                if (titleLower.contains('listen')) moduleIcon = Icons.headphones_outlined;
                if (titleLower.contains('speak')) moduleIcon = Icons.record_voice_over_outlined;

                Color moduleColor = Colors.blue;
                if (titleLower.contains('read')) moduleColor = Colors.blue;
                if (titleLower.contains('writ')) moduleColor = Colors.orange;
                if (titleLower.contains('listen')) moduleColor = Colors.amber;
                if (titleLower.contains('speak')) moduleColor = Colors.purple;

                int defaultPdfs = 0;
                if (titleLower.contains('read')) defaultPdfs = 3;
                if (titleLower.contains('writ')) defaultPdfs = 2;
                if (titleLower.contains('listen')) defaultPdfs = 1;

                return PrepModule(
                  title: sectionStr,
                  lessonsCount: json['lessonsCount'] ?? json['lessons_count'] ?? (titleLower.contains('read') ? 12 : 8),
                  pdfCount: json['pdfCount'] ?? json['pdf_count'] ?? defaultPdfs,
                  icon: moduleIcon,
                  color: moduleColor,
                  isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
                );
              }).toList();
              _isLoading = false;
            });
          }
          return;
        }
      }
      _loadOriginalFallbackModules();
    } catch (e) {
      _loadOriginalFallbackModules();
    }
  }

  void _loadOriginalFallbackModules() {
    if (mounted) {
      setState(() {
        _liveModules = [
          PrepModule(
            title: 'Reading',
            lessonsCount: 12,
            pdfCount: 3,
            icon: Icons.book_outlined,
            color: Colors.blue,
          ),
          PrepModule(
            title: 'Writing',
            lessonsCount: 8,
            pdfCount: 2,
            icon: Icons.edit_note,
            color: Colors.orange,
          ),
          PrepModule(
            title: 'Listening',
            lessonsCount: 8,
            pdfCount: 1,
            icon: Icons.headphones_outlined,
            color: Colors.amber,
          ),
          PrepModule(
            title: 'Speaking',
            lessonsCount: 8,
            icon: Icons.record_voice_over_outlined,
            color: Colors.purple,
            isCompleted: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.scaffoldBg(context),
      drawer: const CustomDrawer(),
      appBar: AppHeader(scaffoldKey: _scaffoldKey, showBackButton: false),
      body: RefreshIndicator(
        onRefresh: _fetchLiveModules,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preparation',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Structured content for all English proficiency tests',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
              const SizedBox(height: 18),
              Row(children: [
                _buildExamTab(
                  context,
                  'GB',
                  'IELTS',
                  selectedType == 'IELTS',
                  isLocked: _isTabLocked('IELTS'),
                ),
                const SizedBox(width: 15),
                _buildExamTab(
                  context,
                  '🌐',
                  'PTE',
                  selectedType == 'PTE',
                  isLocked: _isTabLocked('PTE'),
                ),
              ]),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        selectedType == 'PTE' ? '🌐' : 'GB',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF1D4ED8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: 'Showing content for your preference: '),
                            TextSpan(
                              text: selectedType,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(text: ' (Free Plan)'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildAIRecommendation(context),
              const SizedBox(height: 25),
              Text('$selectedType Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context))),
              const SizedBox(height: 15),
              _isLoading ? const Center(child: CircularProgressIndicator()) : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.95),
                itemCount: _liveModules.length,
                itemBuilder: (context, index) {
                  final module = _liveModules[index];
                  final focus = (_focusModule ?? '').toLowerCase();
                  final title = module.title.toLowerCase();
                  final isRecommended = focus.isNotEmpty && title.contains(focus);
                  return ModuleCard(module: module, isRecommended: isRecommended);
                },
              ),
              const SizedBox(height: 28),
              Text(
                "What's Inside Each Module",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText(context),
                ),
              ),
              const SizedBox(height: 12),
              _insideItem(context, Icons.layers_outlined, const Color(0xFF22C55E), 'Structured Lessons', '3-5 parts per section, 5-10 items each'),
              _insideItem(context, Icons.lightbulb_outline, const Color(0xFFF59E0B), 'Expert Tips', 'Proven strategies from high scorers'),
              _insideItem(context, Icons.gps_fixed, const Color(0xFFEC4899), 'Practice Quizzes', 'Test your understanding after each part'),
              _insideItem(context, Icons.picture_as_pdf_outlined, const Color(0xFF8B5CF6), 'PDF Study Materials', 'Admin-uploaded PDFs, guides, and worksheets'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _insideItem(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.primaryText(context),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isTabLocked(String track) {
    final user = UserNotifier.notifier.value;
    final unlocked = user['unlocked_exam']?.toString().toUpperCase();
    final bool isPremium = user['isPremium'] == true ||
        user['subscription'] == 'premium' ||
        unlocked == 'BOTH';
    final bool isAdmin = user['role'] == 'admin';
    if (isPremium || isAdmin) return false;
    if (unlocked == 'IELTS' || unlocked == 'PTE') {
      return unlocked != track.toUpperCase();
    }
    final String userPref = user['preference'] ?? 'IELTS';
    return userPref.toUpperCase() != track.toUpperCase();
  }

  Widget _buildAIRecommendation(BuildContext context) {
    return GestureDetector(
      onTap: _refreshAIRecommendation,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.tipBg(context),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppTheme.isDark(context) ? Colors.blue.shade900 : Colors.blue.shade100,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'AI Recommendation',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (_focusModule != null && _focusModule!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Focus: $_focusModule',
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 10),
                          ),
                        ),
                      Text(
                        'Tap to refresh',
                        style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_currentTip, style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context))),
                  if (_focusReason != null && _focusReason!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _focusReason!,
                      style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context).withValues(alpha: 0.85), fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildExamTab(BuildContext context, String code, String name, bool isSelected, {bool isLocked = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: isLocked
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const PremiumModal(),
                );
              }
            : () {
                setState(() => selectedType = name);
                _fetchLiveModules();
              },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppTheme.cardBg(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppTheme.borderColor(context),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      code,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isSelected ? Colors.white70 : AppTheme.secondaryText(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isSelected ? Colors.white : AppTheme.primaryText(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: 6),
                      Icon(Icons.lock_outline, size: 14, color: isSelected ? Colors.white70 : Colors.grey),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}