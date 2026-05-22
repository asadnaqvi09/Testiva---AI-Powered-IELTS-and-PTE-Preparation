import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart'; // ApiService helper path
import 'widgets/writing_header.dart';
import 'widgets/writing_ai_card.dart';
import 'widgets/collapsible_lesson_tile.dart';
import '../../../widgets/custom_drawer.dart';

class WritingDetailsScreen extends StatefulWidget {
  const WritingDetailsScreen({super.key});

  @override
  State<WritingDetailsScreen> createState() => _WritingDetailsScreenState();
}

class _WritingDetailsScreenState extends State<WritingDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

  // Tabs separation state matrices
  Map<String, List<LessonItem>> _fundamentalsSections = {};
  Map<String, List<LessonItem>> _essaySections = {};

  @override
  void initState() {
    super.initState();
    _fetchWritingLessons();
  }

  // 🚀 Live Backend API Call logic for Writing tasks separation structure
  Future<void> _fetchWritingLessons() async {
    try {
      final response = await ApiService.get('/lessons?module=writing');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List dynamicList = data['data'];

          Map<String, List<LessonItem>> tempFundamentals = {};
          Map<String, List<LessonItem>> tempEssay = {};

          for (var item in dynamicList) {
            String partName = item['part_title'] ?? item['partTitle'] ?? 'Part 1: Writing Track';
            // Backend variable configuration routing determination logic
            String tabCategory = (item['category'] ?? item['tab'] ?? 'fundamentals').toString().toLowerCase();

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
              title: item['title'] ?? 'Untitled Lesson',
              subtitle: item['subtitle'] ?? '',
              tag: itemTag,
              icon: itemIcon,
              bgColor: baseColor.withOpacity(0.12),
              iconColor: baseColor,
              tagColor: textTagColor,
            );

            // Tab routing filtration allocation
            if (tabCategory.contains('essay')) {
              if (!tempEssay.containsKey(partName)) tempEssay[partName] = [];
              tempEssay[partName]!.add(parsedItem);
            } else {
              if (!tempFundamentals.containsKey(partName)) tempFundamentals[partName] = [];
              tempFundamentals[partName]!.add(parsedItem);
            }
          }

          if (mounted) {
            setState(() {
              _fundamentalsSections = tempFundamentals;
              _essaySections = tempEssay;
              _isLoading = false;
            });
          }
          return;
        }
      }
      _loadAbsoluteStaticBackup();
    } catch (e) {
      debugPrint("Writing modules sync runtime failure: ${e.toString()}");
      _loadAbsoluteStaticBackup();
    }
  }

  void _loadAbsoluteStaticBackup() {
    if (mounted) {
      setState(() {
        // Fallback structures maintaining original data parameters precisely
        _fundamentalsSections = {
          'Part 1: Writing Fundamentals': [
            LessonItem(title: 'Task 1 vs Task 2', subtitle: 'Task 1 (20 min, 150 words): Describe a graph, chart, or diagram. Task 2 (40 min, 250 words): Write an essay responding to a point of view or argument.', tag: 'LESSON', icon: Icons.layers, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Task Achievement', subtitle: 'For Task 2, make sure you fully address all parts of the question. Many students lose marks by only partially answering the prompt.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withOpacity(0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Coherence & Cohesion', subtitle: 'Use linking words: Furthermore, In addition, However. Structure your essay: Introduction -> Body x 2 -> Conclusion', tag: 'LESSON', icon: Icons.timer_outlined, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Vocabulary Range', subtitle: 'Avoid repeating the same words. Use synonyms: big -> significant, show -> demonstrate.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withOpacity(0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Grammar Quiz', subtitle: 'Identify the error: "The graph show a increase." Correction: "The graph shows AN increase."', tag: 'QUIZ', icon: Icons.track_changes, bgColor: Colors.red.withOpacity(0.1), iconColor: Colors.red, tagColor: Colors.orange),
          ]
        };

        _essaySections = {
          'Part 2: Essay Writing': [
            LessonItem(title: 'Essay Introduction Template', subtitle: 'Paraphrase the question -> State your position. Example: "It is argued that technology has improved education."', tag: 'LESSON', icon: Icons.assignment_turned_in_outlined, bgColor: Colors.blue.withOpacity(0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Body Paragraph Structure', subtitle: 'PEEL method: Point -> Explain -> Evidence -> Link back. Each body paragraph should develop ONE main idea.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withOpacity(0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Sample Essay Analysis', subtitle: 'Topic: "Online education is as effective as traditional education." Present pros and cons with your own conclusion.', tag: 'QUIZ', icon: Icons.edit_note, bgColor: Colors.red.withOpacity(0.1), iconColor: Colors.red, tagColor: Colors.orange),
          ]
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
        drawer: const CustomDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar Header
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
                        'SA',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: WritingHeader(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: WritingAICard(),
              ),
              const SizedBox(height: 15),

              // Custom TabBar Container Layout Spacing
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: const Color(0xFF007BFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Writing Fundamentals'),
                    Tab(text: 'Essay Writing'),
                  ],
                ),
              ),

              // Body Tabs views loading state conditions switcher
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF007BFF)))
                    : TabBarView(
                  children: [
                    // Tab 1 UI Renderer
                    RefreshIndicator(
                      onRefresh: _fetchWritingLessons,
                      color: const Color(0xFF007BFF),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: _fundamentalsSections.isEmpty
                            ? const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("No items found")))
                            : Column(
                          children: _fundamentalsSections.entries.map((entry) {
                            return CollapsibleLessonTile(title: entry.key, items: entry.value);
                          }).toList(),
                        ),
                      ),
                    ),
                    // Tab 2 UI Renderer
                    RefreshIndicator(
                      onRefresh: _fetchWritingLessons,
                      color: const Color(0xFF007BFF),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: _essaySections.isEmpty
                            ? const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("No essay guides available")))
                            : Column(
                          children: _essaySections.entries.map((entry) {
                            return CollapsibleLessonTile(title: entry.key, items: entry.value);
                          }).toList(),
                        ),
                      ),
                    ),
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