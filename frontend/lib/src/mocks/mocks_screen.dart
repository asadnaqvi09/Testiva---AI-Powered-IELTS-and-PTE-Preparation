import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/services/user_notifier.dart';
import '../../data/models/mock_test_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/custom_drawer.dart';
import 'test_overview_screen.dart';

class MocksScreen extends StatefulWidget {
  final VoidCallback onStartTestRequested;

  const MocksScreen({
    super.key,
    required this.onStartTestRequested,
  });

  @override
  State<MocksScreen> createState() => _MocksScreenState();
}

class _MocksScreenState extends State<MocksScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MockTest> _mocks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  String? _currentExamType;

  @override
  void initState() {
    super.initState();
    UserNotifier.notifier.addListener(_onUserChanged);
    final pref = UserNotifier.notifier.value['preference'];
    if (pref != null) {
      _currentExamType = pref;
    } else {
      _currentExamType = 'IELTS';
    }
    _fetchMocks();
  }

  void _onUserChanged() {
    if (mounted) {
      final pref = UserNotifier.notifier.value['preference'];
      if (pref != null && pref != _currentExamType) {
        setState(() {
          _currentExamType = pref;
        });
        _fetchMocks();
      }
    }
  }

  @override
  void dispose() {
    UserNotifier.notifier.removeListener(_onUserChanged);
    super.dispose();
  }

  Future<void> _fetchMocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final examType = UserNotifier.notifier.value['preference'] ?? 'IELTS';
      final response = await ApiService.get('/content/test/mobile/dashboard?exam_type=$examType');

      if (kDebugMode) {
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List list = body['data'] as List;
          setState(() {
            _mocks = list.map<MockTest>((item) => MockTest.fromJson(item as Map<String, dynamic>)).toList();
          });
          if (_mocks.isEmpty) {
            setState(() {
              _errorMessage = 'Backend connected successfully, but Database has 0 tests inserted.';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'API Error: success flag is false';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server Error Code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Parsing / Connection Error: $e';
      });
    } finally {
      setState(() {
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
      appBar: AppHeader(
        scaffoldKey: _scaffoldKey,
        titleWidget: Text(
          '${UserNotifier.notifier.value['preference'] ?? 'IELTS'} Mock Tests',
          style: TextStyle(
            color: AppTheme.primaryText(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryText(context), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMocks,
                child: const Text('Retry Connection'),
              )
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchMocks,
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _mocks.length,
          itemBuilder: (context, index) {
            final mock = _mocks[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow(context),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mock.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryText(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Test ID: ${mock.displayId}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.secondaryText(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${mock.difficultyLevel} — ${mock.totalQuestions} Questions — ${mock.totalDuration} Min',
                          style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context), fontWeight: FontWeight.w500),
                        ),
                        if (mock.lastAttemptScore != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0x1A4CAF50).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Last Band Score: ${mock.lastAttemptScore}',
                              style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestOverviewScreen(
                            testId: mock.id,
                            testTitle: mock.title,
                            questionCount: mock.totalQuestions,
                            duration: mock.totalDuration,
                            difficulty: mock.difficultyLevel,
                            minBand: mock.minRequiredBand,
                            questionTypes: mock.subQuestionTypeIndicators,
                          ),
                        ),
                      ).then((value) {
                        _fetchMocks();
                        if (value == 'switch_to_mocks') {
                          widget.onStartTestRequested();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(mock.cta == 'retake' ? 'Retake' : 'Open', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}