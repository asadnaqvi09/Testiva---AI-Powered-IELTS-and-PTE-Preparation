import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/theme/theme_helper.dart';
import 'package:frontend/data/models/mock_test_model.dart';
import 'package:frontend/src/mocks/widgets/mock_test_card.dart';
import 'package:frontend/widgets/custom_drawer.dart';

class MocksScreen extends StatefulWidget {
  const MocksScreen({super.key});

  @override

  State<MocksScreen> createState() => _MocksScreenState();
}


class _MocksScreenState extends State<MocksScreen> {
  String selectedFilter = 'IELTS';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<MockTest> ieltsTests = [
    MockTest(
      title: 'Full Mock Test 01',
      type: 'IELTS',
      difficulty: 'Medium',
      duration: 180,
      questions: 80,
      progress: 65,
      icon: Icons.assignment,
    ),
    MockTest(
      title: 'Reading Practice Set',
      type: 'IELTS',
      difficulty: 'Hard',
      duration: 60,
      questions: 40,
      band: '7.5 Band',
      icon: Icons.menu_book,
    ),
    MockTest(
      title: 'Listening Mastery',
      type: 'IELTS',
      difficulty: 'Easy',
      duration: 45,
      questions: 40,
      isLocked: true,
      icon: Icons.headphones,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text('Testiva',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mock Tests', style: ThemeHelper.getTitleStyle(context).copyWith(fontSize: 24)),
            const Text('Practice with real exam scenarios',
                style: TextStyle(color: Colors.grey, fontSize: 14)),

            const SizedBox(height: 20),
            _buildPremiumBanner(),

            const SizedBox(height: 25),
            _buildTypeTabs(),

            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$selectedFilter Tests',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('See History',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),

            const SizedBox(height: 15),
            ...ieltsTests.map((test) => MockTestCard(test: test)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6F42C1), Color(0xFF8E44AD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6F42C1).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Go Premium',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Unlock 50+ Premium Mock Tests',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Row(
      children: [
        _tabItem('IELTS'),
        const SizedBox(width: 12),
        _tabItem('PTE'),
        const SizedBox(width: 12),
        _tabItem('TOEFL'),
      ],
    );
  }

  Widget _tabItem(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}