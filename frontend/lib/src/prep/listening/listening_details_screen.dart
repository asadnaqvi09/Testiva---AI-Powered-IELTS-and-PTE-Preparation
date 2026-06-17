import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import '../reading/widgets/collapsible_lesson_tile.dart';
import '../widgets/prep_segmented_control.dart';
import '../widgets/media_tab_content.dart';
import '../../../../widgets/app_theme.dart';
import '../../../../widgets/app_header.dart';

class ListeningDetailsScreen extends StatefulWidget {
  const ListeningDetailsScreen({super.key});

  @override
  State<ListeningDetailsScreen> createState() => _ListeningDetailsScreenState();
}

class _ListeningDetailsScreenState extends State<ListeningDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, List<LessonItem>> _liveSections = {};
  List<dynamic> _mediaItems = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchListeningLessons();
  }

  Future<void> _fetchListeningLessons() async {
    try {
      final pref = UserNotifier.notifier.value['preference'] ?? 'IELTS';
      final listResponse = await ApiService.get('/content/preparations?test_type=$pref&section=Listening');
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
          'Part 1: Listening Basics': [
            LessonItem(
                title: 'Format of the Test',
                subtitle: 'IELTS Listening takes 30 minutes, with 4 sections and 40 questions. You hear monologues and conversations.',
                tag: 'LESSON',
                icon: Icons.layers,
                bgColor: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
                tagColor: Colors.blue),
            LessonItem(
                title: 'Active Listening & Prediction',
                subtitle: 'Before the recording starts, read the questions. Predict the type of word needed (e.g. noun, number, date).',
                tag: 'TIP',
                icon: Icons.lightbulb_outline,
                bgColor: Colors.amber.withOpacity(0.1),
                iconColor: Colors.amber,
                tagColor: Colors.green),
            LessonItem(
                title: 'Spelling Rules',
                subtitle: 'Spelling must be 100% correct. Watch out for double letters (e.g., accommodation, success).',
                tag: 'LESSON',
                icon: Icons.timer_outlined,
                bgColor: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
                tagColor: Colors.blue),
          ],
          'Part 2: Academic Lectures': [
            LessonItem(
                title: 'Identifying Key Information',
                subtitle: 'Speakers use signpost words (like "firstly", "in contrast", "another reason is") to transition. Use these to follow the lecture.',
                tag: 'TIP',
                icon: Icons.lightbulb_outline,
                bgColor: Colors.amber.withOpacity(0.1),
                iconColor: Colors.amber,
                tagColor: Colors.green),
            LessonItem(
                title: 'Quick Practice Quiz',
                subtitle: 'Listen for distractors: "We will meet at 6:00. Oh wait, let\'s make it 6:30 instead." (Correct Answer: 6:30)',
                tag: 'QUIZ',
                icon: Icons.track_changes,
                bgColor: Colors.red.withOpacity(0.1),
                iconColor: Colors.red,
                tagColor: Colors.orange),
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
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              showBackButton: true,
              titleWidget: Row(
                children: [
                  const Icon(Icons.headphones, color: Color(0xFFFFC107), size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Listening Prep',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
                  : RefreshIndicator(
                      onRefresh: _fetchListeningLessons,
                      color: const Color(0xFFFFC107),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.headphones_outlined, size: 48, color: Colors.white),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Listening Section',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Master auditory comprehension and details prediction.',
                                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
