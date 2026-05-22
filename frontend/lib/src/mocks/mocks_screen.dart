import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/services/api_service.dart'; // API infrastructure mapping service
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
  bool _isLoading = true;
  List<MockTest> _liveMockTests = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveMockExams();
  }

  // 🚀 Fetch live dynamic mock arrays matching the selected filter state params
  Future<void> _fetchLiveMockExams() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/mocks?type=$selectedFilter');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List dynamicList = data['data'];

          setState(() {
            _liveMockTests = dynamicList.map((json) {
              // Icon categorization identifier injection checks
              IconData testIcon = Icons.assignment;
              String titleLower = (json['title'] ?? '').toString().toLowerCase();
              if (titleLower.contains('read')) testIcon = Icons.menu_book;
              if (titleLower.contains('listen')) testIcon = Icons.headphones;
              if (titleLower.contains('speak')) testIcon = Icons.record_voice_over;

              return MockTest(
                title: json['title'] ?? 'Full Mock Exam',
                type: json['type'] ?? selectedFilter,
                difficulty: json['difficulty'] ?? 'Medium',
                duration: json['duration'] ?? 180,
                questions: json['questions'] ?? 80,
                progress: json['progress'] != null ? (json['progress'] as num).toInt() : null,
                band: json['band']?.toString(),
                isLocked: json['isLocked'] ?? json['is_locked'] ?? false,
                icon: testIcon,
              );
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
      _loadOriginalMocksFallback();
    } catch (e) {
      debugPrint("Error loading full exams grid dashboard: ${e.toString()}");
      _loadOriginalMocksFallback();
    }
  }

  void _loadOriginalMocksFallback() {
    if (mounted) {
      setState(() {
        _liveMockTests = [
          MockTest(title: 'Full Mock Test 01', type: 'IELTS', difficulty: 'Medium', duration: 180, questions: 80, progress: 65, icon: Icons.assignment),
          MockTest(title: 'Reading Practice Set', type: 'IELTS', difficulty: 'Hard', duration: 60, questions: 40, band: '7.5 Band', icon: Icons.menu_book),
          MockTest(title: 'Listening Mastery', type: 'IELTS', difficulty: 'Easy', duration: 45, questions: 40, isLocked: true, icon: Icons.headphones),
        ];
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
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text(
          'Testiva',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLiveMockExams,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mock Tests', style: ThemeHelper.getTitleStyle(context).copyWith(fontSize: 24)),
              const Text('Practice with real exam scenarios', style: TextStyle(color: Colors.grey, fontSize: 14)),

              const SizedBox(height: 20),
              _buildPremiumBanner(),

              const SizedBox(height: 25),
              _buildTypeTabs(),

              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$selectedFilter Tests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  const Text(
                    'See History',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              _isLoading
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
                  : _liveMockTests.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text("No mock tests available for this model track."),
                ),
              )
                  : Column(
                children: _liveMockTests.map((test) => MockTestCard(test: test)).toList(),
              ),
            ],
          ),
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
              color: const Color(0xFF6F42C1).withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Go Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Unlock 50+ Premium Mock Tests', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        _fetchLiveMockExams();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDarkMode ? Colors.grey[800]! : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDarkMode ? Colors.grey[400] : Colors.grey.shade600),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}