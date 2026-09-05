import 'dart:convert';
import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

                return PrepModule(
                  title: sectionStr,
                  lessonsCount: json['lessonsCount'] ?? json['lessons_count'] ?? (titleLower.contains('read') ? 12 : 8),
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
          PrepModule(title: 'Reading', lessonsCount: 12, icon: Icons.book_outlined, color: Colors.blue, isCompleted: true),
          PrepModule(title: 'Writing', lessonsCount: 8, icon: Icons.edit_note, color: Colors.orange, isCompleted: true),
          PrepModule(title: 'Listening', lessonsCount: 8, icon: Icons.headphones_outlined, color: Colors.amber, isCompleted: true),
          PrepModule(title: 'Speaking', lessonsCount: 8, icon: Icons.record_voice_over_outlined, color: Colors.purple, isCompleted: true),
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
      appBar: AppHeader(
        scaffoldKey: _scaffoldKey,
        titleWidget: Text(
          '$selectedType Prep',
          style: TextStyle(
            color: AppTheme.primaryText(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveModules,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 25),
              _buildAIRecommendation(context),
              const SizedBox(height: 25),
              Text('$selectedType Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context))),
              const SizedBox(height: 15),
              _isLoading ? const Center(child: CircularProgressIndicator()) : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.1),
                itemCount: _liveModules.length,
                itemBuilder: (context, index) {
                  final module = _liveModules[index];
                  final focus = (_focusModule ?? '').toLowerCase();
                  final title = module.title.toLowerCase();
                  final isRecommended = focus.isNotEmpty && title.contains(focus);
                  return ModuleCard(module: module, isRecommended: isRecommended);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTabLocked(String track) {
    final user = UserNotifier.notifier.value;
    final bool isPremium = user['isPremium'] == true || user['subscription'] == 'premium';
    final bool isAdmin = user['role'] == 'admin';
    final String userPref = user['preference'] ?? 'IELTS';

    if (isPremium || isAdmin) return false;
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
            const Icon(Icons.lightbulb, color: Colors.blue, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'AI Study Focus',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
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
                      const Spacer(),
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
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryText(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isLocked)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.lock, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}