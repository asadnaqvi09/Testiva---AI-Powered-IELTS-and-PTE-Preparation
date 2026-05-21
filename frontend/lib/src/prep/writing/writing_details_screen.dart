import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const CustomDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu, color: Colors.black87),
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
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF007BFF),
                      child: Text(
                        'SA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: WritingHeader(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: WritingAICard(),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
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
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Writing Fundamentals'),
                    Tab(text: 'Essay Writing'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: CollapsibleLessonTile(
                        title: 'Part 1: Writing Fundamentals',
                        items: [
                          LessonItem(
                            title: 'Task 1 vs Task 2',
                            subtitle: 'Task 1 (20 min, 150 words): Describe a graph, chart, or diagram. Task 2 (40 min, 250 words): Write an essay responding to a point of view or argument.',
                            tag: 'LESSON',
                            icon: Icons.layers,
                            bgColor: Colors.blue.shade50,
                            iconColor: Colors.blue,
                            tagColor: Colors.blue,
                          ),
                          LessonItem(
                            title: 'Task Achievement',
                            subtitle: 'For Task 2, make sure you fully address all parts of the question. Many students lose marks by only partially answering the prompt.',
                            tag: 'TIP',
                            icon: Icons.lightbulb_outline,
                            bgColor: Colors.amber.shade50,
                            iconColor: Colors.amber,
                            tagColor: Colors.green,
                          ),
                          LessonItem(
                            title: 'Coherence & Cohesion',
                            subtitle: 'Use linking words: Furthermore, In addition, However, On the other hand, In conclusion. Structure your essay: Introduction -> Body x 2 -> Conclusion',
                            tag: 'LESSON',
                            icon: Icons.timer_outlined,
                            bgColor: Colors.blue.shade50,
                            iconColor: Colors.blue,
                            tagColor: Colors.blue,
                          ),
                          LessonItem(
                            title: 'Vocabulary Range',
                            subtitle: 'Avoid repeating the same words. Use synonyms: big -> significant, show -> demonstrate, important -> crucial. This directly impacts your Lexical Resource score.',
                            tag: 'TIP',
                            icon: Icons.lightbulb_outline,
                            bgColor: Colors.amber.shade50,
                            iconColor: Colors.amber,
                            tagColor: Colors.green,
                          ),
                          LessonItem(
                            title: 'Grammar Quiz',
                            subtitle: 'Identify the error: "The graph show a increase in temperature." Correction: "The graph shows AN increase in temperature." (subject-verb agreement + article)',
                            tag: 'QUIZ',
                            icon: Icons.track_changes,
                            bgColor: Colors.red.shade50,
                            iconColor: Colors.red,
                            tagColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: CollapsibleLessonTile(
                        title: 'Part 2: Essay Writing',
                        items: [
                          LessonItem(
                            title: 'Essay Introduction Template',
                            subtitle: 'Paraphrase the question -> State your position. Example: "It is argued that technology has improved education. While this view has merit, I believe its benefits must be carefully managed."',
                            tag: 'LESSON',
                            icon: Icons.assignment_turned_in_outlined,
                            bgColor: Colors.blue.shade50,
                            iconColor: Colors.blue,
                            tagColor: Colors.blue,
                          ),
                          LessonItem(
                            title: 'Body Paragraph Structure',
                            subtitle: 'PEEL method: Point -> Explain -> Evidence -> Link back. Each body paragraph should develop ONE main idea with supporting details and examples.',
                            tag: 'TIP',
                            icon: Icons.lightbulb_outline,
                            bgColor: Colors.amber.shade50,
                            iconColor: Colors.amber,
                            tagColor: Colors.green,
                          ),
                          LessonItem(
                            title: 'Sample Essay Analysis',
                            subtitle: 'Topic: "Online education is as effective as traditional education." Analyze: This is a "discuss both views" essay. Present pros and cons with your own conclusion.',
                            tag: 'QUIZ',
                            icon: Icons.edit_note,
                            bgColor: Colors.red.shade50,
                            iconColor: Colors.red,
                            tagColor: Colors.orange,
                          ),
                        ],
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