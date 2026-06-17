import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'widgets/writing_header.dart';
import 'widgets/writing_ai_card.dart';
import 'widgets/collapsible_lesson_tile.dart';
import '../widgets/prep_segmented_control.dart';
import '../widgets/media_tab_content.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/app_theme.dart';

class WritingDetailsScreen extends StatefulWidget {
  const WritingDetailsScreen({super.key});

  @override
  State<WritingDetailsScreen> createState() => _WritingDetailsScreenState();
}

class _WritingDetailsScreenState extends State<WritingDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<dynamic> _mediaItems = [];
  int _selectedTabIndex = 0;

  Map<String, List<LessonItem>> _fundamentalsSections = {};
  Map<String, List<LessonItem>> _essaySections = {};

  @override
  void initState() {
    super.initState();
    _fetchWritingLessons();
  }

  Future<void> _fetchWritingLessons() async {
    try {
      final pref = UserNotifier.notifier.value['preference'] ?? 'IELTS';
      final listResponse = await ApiService.get('/content/preparations?test_type=$pref&section=Writing');
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
              Map<String, List<LessonItem>> tempFundamentals = {};
              Map<String, List<LessonItem>> tempEssay = {};
              RegExp emojiReg = RegExp(r'([📚💡🎯🎨📜📝⏱️🔥🧠])');

              for (var part in dynamicList) {
                String partName = part['part_title'] ?? 'Part 1: Writing Fundamentals';
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
                    bgColor: baseColor.withValues(alpha: 0.12),
                    iconColor: baseColor,
                    tagColor: textTagColor,
                  ));
                }

                if (parsedItems.isNotEmpty) {
                  String nameLower = partName.toLowerCase();
                  if (nameLower.contains('essay') || nameLower.contains('part 2') || nameLower.contains('part2')) {
                    tempEssay[partName] = parsedItems;
                  } else {
                    tempFundamentals[partName] = parsedItems;
                  }
                }
              }

              if (mounted) {
                setState(() {
                  _mediaItems = mediaList;
                  _fundamentalsSections = tempFundamentals;
                  _essaySections = tempEssay;
                  _isLoading = false;
                });
                return;
              }
            }
          }
        }
      }
      _loadAbsoluteStaticBackup();
    } catch (e) {
      debugPrint(e.toString());
      _loadAbsoluteStaticBackup();
    }
  }

  void _loadAbsoluteStaticBackup() {
    if (mounted) {
      setState(() {
        _fundamentalsSections = {
          'Part 1: Writing Fundamentals': [
            LessonItem(title: 'Task 1 vs Task 2', subtitle: 'Task 1 (20 min, 150 words): Describe a graph, chart, or diagram. Task 2 (40 min, 250 words): Write an essay responding to a point of view or argument.', tag: 'LESSON', icon: Icons.layers, bgColor: Colors.blue.withValues(alpha: 0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Task Achievement', subtitle: 'For Task 2, make sure you fully address all parts of the question. Many students lose marks by only partially answering the prompt.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withValues(alpha: 0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Coherence & Cohesion', subtitle: 'Use linking words: Furthermore, In addition, However. Structure your essay: Introduction -> Body x 2 -> Conclusion', tag: 'LESSON', icon: Icons.timer_outlined, bgColor: Colors.blue.withValues(alpha: 0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Vocabulary Range', subtitle: 'Avoid repeating the same words. Use synonyms: big -> significant, show -> demonstrate.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withValues(alpha: 0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Grammar Quiz', subtitle: 'Identify the error: "The graph show a increase." Correction: "The graph shows AN increase."', tag: 'QUIZ', icon: Icons.track_changes, bgColor: Colors.red.withValues(alpha: 0.1), iconColor: Colors.red, tagColor: Colors.orange),
          ]
        };

        _essaySections = {
          'Part 2: Essay Writing': [
            LessonItem(title: 'Essay Introduction Template', subtitle: 'Paraphrase the question -> State your position. Example: "It is argued that technology has improved education."', tag: 'LESSON', icon: Icons.assignment_turned_in_outlined, bgColor: Colors.blue.withValues(alpha: 0.1), iconColor: Colors.blue, tagColor: Colors.blue),
            LessonItem(title: 'Body Paragraph Structure', subtitle: 'PEEL method: Point -> Explain -> Evidence -> Link back. Each body paragraph should develop ONE main idea.', tag: 'TIP', icon: Icons.lightbulb_outline, bgColor: Colors.amber.withValues(alpha: 0.1), iconColor: Colors.amber, tagColor: Colors.green),
            LessonItem(title: 'Sample Essay Analysis', subtitle: 'Topic: "Online education is as effective as traditional education." Present pros and cons with your own conclusion.', tag: 'QUIZ', icon: Icons.edit_note, bgColor: Colors.red.withValues(alpha: 0.1), iconColor: Colors.red, tagColor: Colors.orange),
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
                  const Row(
                    children: [
                      Icon(Icons.book, color: Color(0xFF007BFF), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Testiva AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      CircleAvatar(
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
                      onRefresh: _fetchWritingLessons,
                      color: const Color(0xFF007BFF),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            const WritingHeader(),
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
                              const WritingAICard(),
                              const SizedBox(height: 15),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.tileItemBg(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    if (_fundamentalsSections.isNotEmpty) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.edit_note, color: Color(0xFF007BFF), size: 20),
                                            const SizedBox(width: 8),
                                            Text('Writing Fundamentals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText(context))),
                                          ],
                                        ),
                                      ),
                                      ..._fundamentalsSections.entries.map((entry) {
                                        return CollapsibleLessonTile(title: entry.key, items: entry.value);
                                      }),
                                    ],
                                    if (_essaySections.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.description_outlined, color: Color(0xFF007BFF), size: 20),
                                            const SizedBox(width: 8),
                                            Text('Essay Writing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryText(context))),
                                          ],
                                        ),
                                      ),
                                      ..._essaySections.entries.map((entry) {
                                        return CollapsibleLessonTile(title: entry.key, items: entry.value);
                                      }),
                                    ],
                                    if (_fundamentalsSections.isEmpty && _essaySections.isEmpty)
                                      const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text('No items found'))),
                                  ],
                                ),
                              ),
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