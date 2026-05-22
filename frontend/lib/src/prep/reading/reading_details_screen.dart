import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService import path verify kar lein
import 'widgets/reading_header.dart';
import 'widgets/reading_ai_card.dart';
import 'widgets/collapsible_lesson_tile.dart';
import '../../../../widgets/custom_drawer.dart';

class ReadingDetailsScreen extends StatefulWidget {
  const ReadingDetailsScreen({super.key});

  @override
  State<ReadingDetailsScreen> createState() => _ReadingDetailsScreenState();
}

class _ReadingDetailsScreenState extends State<ReadingDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, List<LessonItem>> _liveSections = {};

  @override
  void initState() {
    super.initState();
    _fetchReadingLessons();
  }

  // 🚀 Backend API Call to load reading tasks structured sections
  Future<void> _fetchReadingLessons() async {
    try {
      final response = await ApiService.get('/lessons?module=reading');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List dynamicList = data['data'];
          Map<String, List<LessonItem>> tempSections = {};

          for (var item in dynamicList) {
            String partName = item['part_title'] ?? item['partTitle'] ?? 'Part 1: General Lessons';

            // Dynamic theme parsing parameters based on incoming string tag flags
            String itemTag = (item['tag'] ?? 'LESSON').toString().toUpperCase();
            IconData itemIcon = Icons.layers;
            Color baseColor = Colors.blue;
            Color textTagColor = Colors.blue;

            if (itemTag == 'TIP') {
              itemIcon = Icons.lightbulb_outline;
              baseColor = Colors.amber;
              textTagColor = Colors.green;
            } else if (itemTag == 'QUIZ') {
              itemIcon = Icons.track_changes;
              baseColor = Colors.red;
              textTagColor = Colors.orange;
            }

            LessonItem parsedItem = LessonItem(
              title: item['title'] ?? 'Untitled Item',
              subtitle: item['subtitle'] ?? '',
              tag: itemTag,
              icon: itemIcon,
              bgColor: baseColor.withOpacity(0.12),
              iconColor: baseColor,
              tagColor: textTagColor,
            );

            if (!tempSections.containsKey(partName)) {
              tempSections[partName] = [];
            }
            tempSections[partName]!.add(parsedItem);
          }

          if (tempSections.isNotEmpty && mounted) {
            setState(() {
              _liveSections = tempSections;
              _isLoading = false;
            });
            return;
          }
        }
      }
      _loadAbsoluteFallbackContent();
    } catch (e) {
      debugPrint("Error retrieving Reading Module sub-sections: ${e.toString()}");
      _loadAbsoluteFallbackContent();
    }
  }

  void _loadAbsoluteFallbackContent() {
    if (mounted) {
      setState(() {
        _liveSections = {
          'Part 1: Introduction to Reading': [
            LessonItem(title: 'Types of Reading Questions', subtitle: 'IELTS Reading includes MCQ, True/False/Not Given, Matching Headings, Summary Completion, and Short Answer questions.', tag: 'LESSON', icon: Icons.layers, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Skimming and Scanning', subtitle: 'Skimming means reading quickly for the main idea. Scanning means looking for specific information.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withOpacity(0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Time Management', subtitle: 'You have 60 minutes for 40 questions. Allocate about 20 minutes per passage.', tag: 'LESSON', icon: Icons.timer_outlined, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Quick Quiz: Question Types', subtitle: 'Q: What should you do first? Answer: Skim first to understand the topic.', tag: 'QUIZ', icon: Icons.track_changes, bgColor: Colors.red.withOpacity(0.1), iconColor: Colors.red, tagColor: Colors.orange),
          ],
          'Part 2: Advanced Strategies': [
            LessonItem(title: 'True/False/Not Given Mastery', subtitle: '"Not Given" means the passage neither confirms nor contradicts. Never assume – use evidence.', tag: 'LESSON', icon: Icons.assignment_turned_in_outlined, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Matching Headings Strategy', subtitle: 'Read the first and last sentence of each paragraph. Match that to a heading first.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withOpacity(0.1), iconColor: Colors.amber, tagColor: Colors.green),
          ]
        };
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
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Top App Bar Header component
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.book, color: Color(0xFF007BFF), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Testiva AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF007BFF),
                    child: Text(
                      'AK',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Dynamic list parsing structure body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                  : RefreshIndicator(
                onRefresh: _fetchReadingLessons,
                color: const Color(0xFF007BFF),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const ReadingHeader(),
                      const SizedBox(height: 20),
                      const ReadingAICard(),
                      const SizedBox(height: 25),

                      // Map loops over dynamic database parts keys
                      ..._liveSections.entries.map((entry) {
                        return CollapsibleLessonTile(
                          title: entry.key,
                          items: entry.value,
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}