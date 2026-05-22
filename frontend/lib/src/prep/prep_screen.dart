import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService helper
import 'package:frontend/src/prep/widgets/prep_header.dart';
import 'package:frontend/src/prep/widgets/module_card.dart';
import 'package:frontend/widgets/custom_drawer.dart';
import '../../../../data/models/prep_module_model.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchLiveModules();
  }

  // 🚀 Backend Server API Integration for Modules Grid
  Future<void> _fetchLiveModules() async {
    setState(() => _isLoading = true);
    try {
      // Backend request hit passing selectedType filter params
      final response = await ApiService.get('/practice/categories?track=$selectedType');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List dynamicList = data['data'];

          if (mounted) {
            setState(() {
              _liveModules = dynamicList.map((json) {
                String titleStr = (json['title'] ?? '').toString().toLowerCase();

                // Icon Map parsing based on module context
                IconData moduleIcon = Icons.book_outlined;
                if (titleStr.contains('read')) moduleIcon = Icons.book_outlined;
                if (titleStr.contains('writ')) moduleIcon = Icons.edit_note;
                if (titleStr.contains('listen')) moduleIcon = Icons.headphones_outlined;
                if (titleStr.contains('speak')) moduleIcon = Icons.record_voice_over_outlined;

                // Color configuration selector
                Color moduleColor = Colors.blue;
                if (titleStr.contains('read')) moduleColor = Colors.blue;
                if (titleStr.contains('writ')) moduleColor = Colors.orange;
                if (titleStr.contains('listen')) moduleColor = Colors.amber;
                if (titleStr.contains('speak')) moduleColor = Colors.purple;

                return PrepModule(
                  title: json['title'] ?? 'Module',
                  lessonsCount: json['lessonsCount'] ?? json['lessons_count'] ?? 0,
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
      debugPrint("Error fetching preparation grid database: ${e.toString()}");
      _loadOriginalFallbackModules();
    }
  }

  // Fallback function maintaining your exact design values safely
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: PrepHeader(scaffoldKey: _scaffoldKey),
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)
              ),
              const Text(
                  'Structured content for English proficiency tests',
                  style: TextStyle(color: Colors.grey, fontSize: 14)
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _buildExamTab('GB', 'IELTS', selectedType == 'IELTS', isDarkMode),
                  const SizedBox(width: 15),
                  // Locked toggle parameters verification
                  _buildExamTab('🌐', 'PTE', selectedType == 'PTE', isDarkMode, isLocked: true),
                ],
              ),

              const SizedBox(height: 25),
              _buildAIRecommendation(isDarkMode),
              const SizedBox(height: 25),

              Text(
                  '$selectedType Modules',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)
              ),
              const SizedBox(height: 15),

              _isLoading
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
                  : _liveModules.isEmpty
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No preparation modules found.")))
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                ),
                itemCount: _liveModules.length,
                itemBuilder: (context, index) => ModuleCard(module: _liveModules[index]),
              ),

              const SizedBox(height: 30),
              Text(
                  "What's Inside Each Module",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)
              ),
              const SizedBox(height: 20),
              _buildInsideItem(Icons.library_books, Colors.orange, 'Structured Lessons', '3-5 parts per section, 5-10 items each', isDarkMode),
              _buildInsideItem(Icons.lightbulb_outline, Colors.amber, 'Expert Tips', 'Proven strategies from high scorers', isDarkMode),
              _buildInsideItem(Icons.ads_click, Colors.redAccent, 'Practice Quizzes', 'Test your understanding after each part', isDarkMode),
              _buildInsideItem(Icons.smart_toy_outlined, Colors.blueGrey, 'AI Feedback', 'Personalized recommendations based on performance', isDarkMode),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamTab(String code, String name, bool isSelected, bool isDarkMode, {bool isLocked = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: isLocked ? null : () {
          setState(() {
            selectedType = name;
          });
          _fetchLiveModules();
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? AppColors.primary : (isDarkMode ? Colors.grey[800]! : Colors.grey.shade200)
            ),
            boxShadow: [
              if (!isDarkMode)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(code, style: TextStyle(color: isSelected ? Colors.white70 : Colors.blue, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                  name,
                  style: TextStyle(
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[300] : Colors.black),
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  )
              ),
              if (isLocked)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.lock_outline, size: 14, color: isSelected ? Colors.white70 : Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendation(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFE3F2FD).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Recommendation', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Text(
                    'Focus on Writing Task 2 - it carries the most weight in your score',
                    style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[300] : Colors.black87)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsideItem(IconData icon, Color color, String title, String subtitle, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDarkMode ? Colors.white : Colors.black87)
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}