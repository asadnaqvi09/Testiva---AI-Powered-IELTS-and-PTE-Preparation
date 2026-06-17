import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/user_notifier.dart';
import 'package:url_launcher/url_launcher.dart';
import '../reading/widgets/collapsible_lesson_tile.dart';
import '../widgets/prep_segmented_control.dart';
import '../widgets/media_tab_content.dart';
import '../../../../widgets/custom_drawer.dart';
import '../../../../widgets/app_theme.dart';

class SpeakingDetailsScreen extends StatefulWidget {
  const SpeakingDetailsScreen({super.key});

  @override
  State<SpeakingDetailsScreen> createState() => _SpeakingDetailsScreenState();
}

class _SpeakingDetailsScreenState extends State<SpeakingDetailsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  Map<String, List<LessonItem>> _liveSections = {};
  List<dynamic> _mediaItems = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSpeakingLessons();
  }

  Future<void> _fetchSpeakingLessons() async {
    try {
      final pref = UserNotifier.notifier.value['preference'] ?? 'IELTS';
      final listResponse = await ApiService.get('/content/preparations?test_type=$pref&section=Speaking');
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
          'Part 1: Intro & Interview': [
            LessonItem(
                title: 'Test Structure',
                subtitle: 'The speaking test is a face-to-face interview of 11-14 minutes divided into 3 parts.',
                tag: 'LESSON',
                icon: Icons.layers,
                bgColor: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
                tagColor: Colors.blue),
            LessonItem(
                title: 'Fluency over Grammar',
                subtitle: 'Keep talking even if you make grammatical errors. Fluency carries 25% of the overall band score.',
                tag: 'TIP',
                icon: Icons.lightbulb_outline,
                bgColor: Colors.amber.withOpacity(0.1),
                iconColor: Colors.amber,
                tagColor: Colors.green),
          ],
          'Part 2: Individual Long Turn (Cue Card)': [
            LessonItem(
                title: 'Structuring your 2-minute talk',
                subtitle: 'Use the 1 minute preparation time to make a quick mind map. Cover who, what, when, where, and why.',
                tag: 'LESSON',
                icon: Icons.assignment_outlined,
                bgColor: Colors.blue.withOpacity(0.1),
                iconColor: Colors.blue,
                tagColor: Colors.blue),
            LessonItem(
                title: 'Filler Avoidance Strategy',
                subtitle: 'Record yourself describing a topic. Try replacing filler words ("uhm", "like", "you know") with comfortable pauses.',
                tag: 'TIP',
                icon: Icons.lightbulb_outline,
                bgColor: Colors.amber.withOpacity(0.1),
                iconColor: Colors.amber,
                tagColor: Colors.green),
            LessonItem(
                title: 'Cue Card Quiz',
                subtitle: 'Describe a historical building you visited. (Aim to speak continuously for at least 1.5 minutes)',
                tag: 'QUIZ',
                icon: Icons.record_voice_over,
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
                      const Icon(Icons.record_voice_over, color: Colors.purple, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Speaking Prep',
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
                        backgroundColor: Colors.purple,
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
                  ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                  : RefreshIndicator(
                      onRefresh: _fetchSpeakingLessons,
                      color: Colors.purple,
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
                                  colors: [Colors.purpleAccent, Colors.purple],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.mic_none, size: 48, color: Colors.white),
                                  SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Speaking Section',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Perfect your speech delivery, vocabulary, and cohesion.',
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
