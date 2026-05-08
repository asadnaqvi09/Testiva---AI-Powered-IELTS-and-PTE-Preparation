import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
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

  final List<PrepModule> modules = [
    PrepModule(title: 'Reading', lessonsCount: 12, icon: Icons.book_outlined, color: Colors.blue, isCompleted: true),
    PrepModule(title: 'Writing', lessonsCount: 8, icon: Icons.edit_note, color: Colors.orange, isCompleted: true),
    PrepModule(title: 'Listening', lessonsCount: 8, icon: Icons.headphones_outlined, color: Colors.amber, isCompleted: true),
    PrepModule(title: 'Speaking', lessonsCount: 8, icon: Icons.record_voice_over_outlined, color: Colors.purple, isCompleted: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: PrepHeader(scaffoldKey: _scaffoldKey),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preparation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Structured content for English proficiency tests',
                style: TextStyle(color: Colors.grey, fontSize: 14)),

            const SizedBox(height: 20),

            
            Row(
              children: [
                _buildExamTab('GB', 'IELTS', selectedType == 'IELTS'),
                const SizedBox(width: 15),
                _buildExamTab('🌐', 'PTE', selectedType == 'PTE', isLocked: true),
              ],
            ),

            const SizedBox(height: 25),
            _buildAIRecommendation(),
            const SizedBox(height: 25),

            Text('$selectedType Modules', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) => ModuleCard(module: modules[index]),
            ),

            const SizedBox(height: 30),
            const Text("What's Inside Each Module", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInsideItem(Icons.library_books, Colors.orange, 'Structured Lessons', '3-5 parts per section, 5-10 items each'),
            _buildInsideItem(Icons.lightbulb_outline, Colors.amber, 'Expert Tips', 'Proven strategies from high scorers'),
            _buildInsideItem(Icons.ads_click, Colors.redAccent, 'Practice Quizzes', 'Test your understanding after each part'),
            _buildInsideItem(Icons.smart_toy_outlined, Colors.blueGrey, 'AI Feedback', 'Personalized recommendations based on performance'),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTab(String code, String name, bool isSelected, {bool isLocked = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: isLocked ? null : () => setState(() => selectedType = name),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
              Text(name, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildAIRecommendation() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Recommendation', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                Text('Focus on Writing Task 2 - it carries the most weight in your score', style: TextStyle(fontSize: 12, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInsideItem(IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}