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
import 'widgets/mock_test_card.dart';

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
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    UserNotifier.notifier.addListener(_onUserChanged);
    _fetchMocks();
  }

  void _onUserChanged() {
    if (mounted) _fetchMocks();
  }

  @override
  void dispose() {
    UserNotifier.notifier.removeListener(_onUserChanged);
    super.dispose();
  }

  String? get _examQuery {
    if (_filter == 'IELTS') return 'IELTS';
    if (_filter == 'PTE') return 'PTE';
    return UserNotifier.notifier.value['preference']?.toString() ?? 'IELTS';
  }

  Future<void> _fetchMocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final examType = _examQuery;
      final response = await ApiService.get('/content/test/mobile/dashboard?exam_type=$examType');

      if (kDebugMode) {
        debugPrint('Mocks dashboard: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List list = body['data'] as List;
          var items = list.map<MockTest>((item) => MockTest.fromJson(item as Map<String, dynamic>)).toList();
          if (_filter == 'IELTS') {
            items = items.where((m) => m.examType == 'IELTS').toList();
          } else if (_filter == 'PTE') {
            items = items.where((m) => m.examType == 'PTE').toList();
          }
          setState(() => _mocks = items);
          if (_mocks.isEmpty) {
            _errorMessage = 'No published mock tests yet. Create one in the Admin panel.';
          }
        } else {
          _errorMessage = 'Could not load mock tests.';
        }
      } else {
        _errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openMock(MockTest mock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestOverviewScreen(
          testId: mock.id,
          testTitle: mock.title,
          examType: mock.examType,
          testCategory: mock.testCategory,
          questionCount: mock.totalQuestions,
          duration: mock.totalDuration,
          difficulty: mock.difficultyLevel,
          minBand: mock.minRequiredBand,
          questionTypes: mock.subQuestionTypeIndicators,
        ),
      ),
    ).then((value) {
      _fetchMocks();
      if (value == 'switch_to_mocks') widget.onStartTestRequested();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pref = UserNotifier.notifier.value['preference']?.toString() ?? 'IELTS';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: AppHeader(
        scaffoldKey: _scaffoldKey,
        titleWidget: const Text(
          'Mock Tests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              _isLoading ? 'Loading tests…' : '${_mocks.length} test${_mocks.length == 1 ? '' : 's'} available',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'IELTS', 'PTE'].map((f) {
                final active = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: active,
                    onSelected: (_) {
                      setState(() => _filter = f);
                      _fetchMocks();
                    },
                    selectedColor: const Color(0xFF007BFF),
                    labelStyle: TextStyle(
                      color: active ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: active ? const Color(0xFF007BFF) : Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          if (_mocks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                pref.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _errorView()
                    : RefreshIndicator(
                        onRefresh: _fetchMocks,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _mocks.length,
                          itemBuilder: (context, index) => MockTestCard(
                            mock: _mocks[index],
                            onTap: () => _openMock(_mocks[index]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText(context)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchMocks, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
