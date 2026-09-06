import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../core/database/local_db.dart';
import '../../core/services/api_service.dart';
import '../../core/services/connectivity_service.dart';
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

  bool _hasFullTestAccess() {
    final user = UserNotifier.notifier.value;
    final role = user['role']?.toString().toLowerCase();
    final sub = user['subscription']?.toString().toLowerCase();
    final unlocked = user['unlocked_exam']?.toString().toUpperCase();
    return role == 'admin' || sub == 'premium' || unlocked == 'BOTH';
  }

  bool _canAccessExam(String examType) {
    final upper = examType.toUpperCase();
    if (_hasFullTestAccess()) return true;
    final user = UserNotifier.notifier.value;
    final unlocked = user['unlocked_exam']?.toString().toUpperCase();
    if (unlocked == 'IELTS' || unlocked == 'PTE') return unlocked == upper;
    final preference =
        (user['preference']?.toString() ?? 'IELTS').toUpperCase();
    return preference == upper;
  }

  String? get _examQuery {
    if (_filter == 'IELTS') return _canAccessExam('IELTS') ? 'IELTS' : null;
    if (_filter == 'PTE') return _canAccessExam('PTE') ? 'PTE' : null;
    if (_hasFullTestAccess()) return 'ALL';
    final unlocked =
        UserNotifier.notifier.value['unlocked_exam']?.toString().toUpperCase();
    if (unlocked == 'IELTS' || unlocked == 'PTE') return unlocked;
    return UserNotifier.notifier.value['preference']?.toString() ?? 'IELTS';
  }

  Future<void> _fetchMocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await LocalDb.instance.purgeDisallowedCaches(
        canIelts: _canAccessExam('IELTS'),
        canPte: _canAccessExam('PTE'),
      );

      final examType = _examQuery;
      if (examType == null) {
        setState(() {
          _mocks = [];
          _errorMessage = 'This exam track is locked on your plan.';
        });
        return;
      }

      final online = await ConnectivityService.instance.checkOnline();

      if (online) {
        try {
          final endpoint = examType == 'ALL'
              ? '/content/test/mobile/dashboard'
              : '/content/test/mobile/dashboard?exam_type=$examType';
          final response = await ApiService.get(endpoint);

          if (kDebugMode) {
            debugPrint('Mocks dashboard: ${response.statusCode}');
          }

          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            if (body['success'] == true) {
              final List list = body['data'] as List;
              final allowed = list.where((item) {
                final map = item as Map<String, dynamic>;
                final type =
                    (map['exam_type'] ?? map['examType'] ?? '').toString();
                return type.isEmpty || _canAccessExam(type);
              }).toList();
              await LocalDb.instance.cacheMockDashboard(
                examType: examType,
                items: allowed,
              );
              _applyMockList(allowed);
              return;
            }
            _errorMessage = 'Could not load mock tests.';
            return;
          }
          _errorMessage = 'Server error (${response.statusCode})';
        } catch (e) {
          final loaded = await _loadCachedMocks(examType);
          if (loaded) return;
          _errorMessage = 'Connection error: $e';
        }
      } else {
        final loaded = await _loadCachedMocks(examType);
        if (!loaded) {
          _errorMessage =
              'You are offline. Open mock tests once while online to cache them.';
        }
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyMockList(List list) {
    var items = list
        .map<MockTest>((item) => MockTest.fromJson(item as Map<String, dynamic>))
        .toList();
    if (_filter == 'IELTS') {
      items = items.where((m) => m.examType == 'IELTS').toList();
    } else if (_filter == 'PTE') {
      items = items.where((m) => m.examType == 'PTE').toList();
    }
    setState(() => _mocks = items);
    if (_mocks.isEmpty) {
      _errorMessage = 'No published mock tests yet. Create one in the Admin panel.';
    }
  }

  Future<bool> _loadCachedMocks(String examType) async {
    final cached = await LocalDb.instance.getCachedMockDashboard(examType);
    if (cached == null || cached.isEmpty) return false;
    _applyMockList(cached);
    return true;
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

  String get _sectionLabel {
    if (_filter != 'All') return _filter.toUpperCase();
    if (_hasFullTestAccess()) return 'ALL EXAMS';
    return (UserNotifier.notifier.value['preference']?.toString() ?? 'IELTS').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.scaffoldBg(context),
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
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText(context), fontWeight: FontWeight.w500),
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
                      color: active ? Colors.white : AppTheme.primaryText(context),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppTheme.cardBg(context),
                    side: BorderSide(
                      color: active ? const Color(0xFF007BFF) : AppTheme.borderColor(context),
                    ),
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
                _sectionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.secondaryText(context),
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
