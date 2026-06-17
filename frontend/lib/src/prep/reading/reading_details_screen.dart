import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/reading_header.dart';
import 'widgets/reading_ai_card.dart';
import 'widgets/collapsible_lesson_tile.dart';
import '../widgets/prep_segmented_control.dart';
import '../widgets/media_tab_content.dart';
import '../../../../widgets/custom_drawer.dart';
import '../../../../widgets/app_theme.dart';

class ReadingDetailsScreen extends StatefulWidget {
  const ReadingDetailsScreen({super.key});

  @override
  State<ReadingDetailsScreen> createState() => _ReadingDetailsScreenState();
}

class _ReadingDetailsScreenState extends State<ReadingDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, List<LessonItem>> _liveSections = {};
  List<dynamic> _mediaItems = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchReadingLessons();
  }

  Future<void> _fetchReadingLessons() async {
    try {
      final pref = UserNotifier.notifier.value['preference'] ?? 'IELTS';
      final listResponse = await ApiService.get('/content/preparations?test_type=$pref&section=Reading');
      if (listResponse.statusCode == 200) {
        final listData = jsonDecode(listResponse.body);
        if (listData['success'] == true && listData['data'] != null && listData['data'].isNotEmpty) {
          final prepId = listData['data'][0]['id'];
          final detailResponse = await ApiService.get('/content/preparations/lesson/$prepId');
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            if (detailData['success'] == true && detailData['data'] != null) {
              final List dynamicList = detailData['data']['parts'] ?? [];
              final List mediaList = detailData['data']['media'] ?? [];
              Map<String, List<LessonItem>> tempSections = {};
              RegExp emojiReg = RegExp(r'([📚💡🎯🎨📜📝⏱️🔥🧠])');

              for (var part in dynamicList) {
                String partName = part['part_title'] ?? 'Part 1: General Lessons';
                String rawText = part['part_content'] ?? '';
                List<String> segments = rawText.split(emojiReg);
                List<RegExpMatch> matches = emojiReg.allMatches(rawText).toList();

                if (segments.isNotEmpty && segments[0].trim().isEmpty) {
                  segments.removeAt(0);
                }

                List<LessonItem> parsedItems = [];
                for (int i = 0; i < segments.length; i++) {
                  String emoji = (i < matches.length) ? matches[i].group(0) ?? '📚' : '📚';
                  String segment = segments[i].trim();
                  if (segment.isEmpty) continue;

                  List<String> lines = segment.split('\n');
                  String title = lines[0].trim();
                  String subtitle = lines.sublist(1).join('\n').trim();

                  String tag = 'LESSON';
                  IconData icon = Icons.layers;
                  Color baseColor = Colors.blue;
                  Color textTagColor = Colors.blue;

                  if (emoji == '💡' || emoji == '🔥') {
                    tag = 'TIP';
                    icon = Icons.lightbulb_outline;
                    baseColor = Colors.amber;
                    textTagColor = Colors.green;
                  } else if (emoji == '🎯' || emoji == '🧠') {
                    tag = 'QUIZ';
                    icon = Icons.track_changes;
                    baseColor = Colors.red;
                    textTagColor = Colors.orange;
                  } else if (emoji == '⏱️') {
                    icon = Icons.timer_outlined;
                  }

                  parsedItems.add(LessonItem(
                    title: title,
                    subtitle: subtitle,
                    tag: tag,
                    icon: icon,
                    bgColor: baseColor.withOpacity(0.12),
                    iconColor: baseColor,
                    tagColor: textTagColor,
                  ));
                }

                if (parsedItems.isNotEmpty) {
                  tempSections[partName] = parsedItems;
                }
              }

              if (tempSections.isNotEmpty && mounted) {
                setState(() {
                  _mediaItems = mediaList;
                  _liveSections = tempSections;
                  _isLoading = false;
                });
                return;
              }
            }
          }
        }
      }
      _loadAbsoluteFallbackContent();
    } catch (e) {
      debugPrint(e.toString());
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.scaffoldBg(context),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppTheme.appBarBg(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.menu, color: AppTheme.iconColor(context)),
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
                          color: AppTheme.primaryText(context),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                ],
              ),
            ),


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
                      PrepSegmentedControl(
                        selectedIndex: _selectedTabIndex,
                        onChanged: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        mediaCount: _mediaItems.length,
                      ),
                      const SizedBox(height: 10),
                      if (_selectedTabIndex == 0) ...[
                        const ReadingAICard(),
                        const SizedBox(height: 25),
                        ..._liveSections.entries.map((entry) {
                          return CollapsibleLessonTile(
                            title: entry.key,
                            items: entry.value,
                          );
                        }),
                      ] else ...[
                        MediaTabContent(mediaItems: _mediaItems),
                      ],
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