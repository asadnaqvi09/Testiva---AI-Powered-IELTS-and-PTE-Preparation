import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'AK',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const ReadingHeader(),
                    const SizedBox(height: 20),
                    const ReadingAICard(),
                    const SizedBox(height: 25),
                    CollapsibleLessonTile(
                      title: 'Part 1: Introduction to Reading',
                      items: [
                        LessonItem(
                          title: 'Types of Reading Questions',
                          subtitle: 'IELTS Reading includes MCQ, True/False/Not Given, Matching Headings, Summary Completion, and Short Answer questions.',
                          tag: 'LESSON',
                          icon: Icons.layers,
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                          tagColor: Colors.blue,
                        ),
                        LessonItem(
                          title: 'Skimming and Scanning',
                          subtitle: 'Skimming means reading quickly for the main idea. Scanning means looking for specific information.',
                          tag: 'TIP',
                          icon: Icons.lightbulb_outline,
                          bgColor: Colors.amber.shade50,
                          iconColor: Colors.amber,
                          tagColor: Colors.green,
                        ),
                        LessonItem(
                          title: 'Time Management',
                          subtitle: 'You have 60 minutes for 40 questions. Allocate about 20 minutes per passage.',
                          tag: 'LESSON',
                          icon: Icons.timer_outlined,
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                          tagColor: Colors.blue,
                        ),
                        LessonItem(
                          title: 'Quick Quiz: Question Types',
                          subtitle: 'Q: What should you do first? Answer: Skim first to understand the topic.',
                          tag: 'QUIZ',
                          icon: Icons.track_changes,
                          bgColor: Colors.red.shade50,
                          iconColor: Colors.red,
                          tagColor: Colors.orange,
                        ),
                        LessonItem(
                          title: 'Vocabulary in Context',
                          subtitle: 'Use context clues to deduce unknown words. Look at the words before and after the unfamiliar term.',
                          tag: 'TIP',
                          icon: Icons.lightbulb_outline,
                          bgColor: Colors.amber.shade50,
                          iconColor: Colors.amber,
                          tagColor: Colors.green,
                        ),
                      ],
                    ),
                    CollapsibleLessonTile(
                      title: 'Part 2: Advanced Strategies',
                      items: [
                        LessonItem(
                          title: 'True/False/Not Given Mastery',
                          subtitle: '"Not Given" means the passage neither confirms nor contradicts. Never assume – use evidence.',
                          tag: 'LESSON',
                          icon: Icons.assignment_turned_in_outlined,
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                          tagColor: Colors.blue,
                        ),
                        LessonItem(
                          title: 'Matching Headings Strategy',
                          subtitle: 'Read the first and last sentence of each paragraph. Match that to a heading first.',
                          tag: 'TIP',
                          icon: Icons.lightbulb_outline,
                          bgColor: Colors.amber.shade50,
                          iconColor: Colors.amber,
                          tagColor: Colors.green,
                        ),
                        LessonItem(
                          title: 'Summary Completion Tips',
                          subtitle: 'Look for paraphrased language. The answer is usually one or two words from the passage.',
                          tag: 'LESSON',
                          icon: Icons.article_outlined,
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                          tagColor: Colors.blue,
                        ),
                        LessonItem(
                          title: 'Practice Exercise',
                          subtitle: 'Answer: Not Given – no comparison is made regarding the "biggest" threat.',
                          tag: 'QUIZ',
                          icon: Icons.edit_note,
                          bgColor: Colors.red.shade50,
                          iconColor: Colors.red,
                          tagColor: Colors.orange,
                        ),
                      ],
                    ),
                    CollapsibleLessonTile(
                      title: 'Part 3: Practice & Review',
                      items: [
                        LessonItem(
                          title: 'Daily Reading Habit',
                          subtitle: 'Read academic articles from BBC News or Scientific American for 30 minutes daily.',
                          tag: 'TIP',
                          icon: Icons.lightbulb_outline,
                          bgColor: Colors.amber.shade50,
                          iconColor: Colors.amber,
                          tagColor: Colors.green,
                        ),
                        LessonItem(
                          title: 'Sample Passage Practice',
                          subtitle: 'The industrial revolution fundamentally transformed how societies organized work and production.',
                          tag: 'LESSON',
                          icon: Icons.menu_book_outlined,
                          bgColor: Colors.blue.shade50,
                          iconColor: Colors.blue,
                          tagColor: Colors.blue,
                        ),
                        LessonItem(
                          title: 'Final Review Quiz',
                          subtitle: 'Q: How many passages? Answer: 3 passages, totaling 40 questions in 60 minutes.',
                          tag: 'QUIZ',
                          icon: Icons.fact_check_outlined,
                          bgColor: Colors.red.shade50,
                          iconColor: Colors.red,
                          tagColor: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}