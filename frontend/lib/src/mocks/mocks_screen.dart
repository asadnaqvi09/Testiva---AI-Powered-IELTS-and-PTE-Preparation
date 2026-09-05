import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/app_theme.dart';
import '../../core/database/local_db.dart';
import '../../core/services/api_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/user_notifier.dart';
import '../../data/demo/demo_mock_catalog.dart';
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
    return role == 'admin' || sub == 'premium';
  }

  String _normalizedPreference() {
    final raw = UserNotifier.notifier.value['preference']?.toString().toUpperCase().trim();
    if (raw == 'PTE') return 'PTE';
    return 'IELTS';
  }

  String get _examQuery {
    if (_filter == 'IELTS') return 'IELTS';
    if (_filter == 'PTE') return 'PTE';
    if (_hasFullTestAccess()) return 'ALL';
    return _normalizedPreference();
  }

  String? _messageFromBody(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return null;
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      final data = body['data'];
      if (data is List) return data;
      if (data is Map && data['data'] is List) return data['data'] as List;
    }
    return const [];
  }

  Future<void> _fetchMocks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    final examType = _examQuery;
    try {
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
            if (body is Map && body['success'] == true) {
              final list = _extractList(body);
              if (list.isNotEmpty) {
                await LocalDb.instance.cacheMockDashboard(
                  examType: examType,
                  items: list,
                );
                _applyMockList(
                  list,
                  notice: body['demo'] == true
                      ? (body['message']?.toString() ??
                          'Showing demo mock tests (database unavailable).')
                      : '',
                );
                return;
              }
            }
            final apiMessage = body is Map ? body['message']?.toString() : null;
            await _showFallback(
              examType,
              apiMessage ??
                  'No published mock tests from the server. Showing demo tests for preview.',
            );
            return;
          }

          await _showFallback(
            examType,
            _messageFromBody(response.body) ??
                'Could not load mock tests (${response.statusCode}).',
          );
          return;
        } catch (e) {
          final loaded = await _loadCachedMocks(examType);
          if (loaded) {
            setState(() {
              _errorMessage =
                  'Could not refresh from server. Showing cached mock tests.';
            });
            return;
          }
          await _showFallback(examType, 'Connection error: $e');
        }
      } else {
        final loaded = await _loadCachedMocks(examType);
        if (!loaded) {
          await _showFallback(
            examType,
            'You are offline. Showing demo mock tests until you reconnect.',
          );
        }
      }
    } catch (e) {
      await _showFallback(examType, 'Connection error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFallback(String examType, String message) async {
    final loaded = await _loadCachedMocks(examType);
    if (loaded) {
      if (mounted) {
        setState(() => _errorMessage = message);
      } else {
        _errorMessage = message;
      }
      return;
    }
    _applyMockList(DemoMockCatalog.forExamType(examType), notice: message);
  }

  void _applyMockList(List list, {String notice = ''}) {
    final items = <MockTest>[];
    for (final item in list) {
      if (item is! Map) continue;
      try {
        items.add(MockTest.fromJson(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('Skipping mock parse error: $e');
      }
    }
    var filtered = items;
    if (_filter == 'IELTS') {
      filtered = items.where((m) => m.examType == 'IELTS').toList();
    } else if (_filter == 'PTE') {
      filtered = items.where((m) => m.examType == 'PTE').toList();
    }
    _mocks = filtered;
    _errorMessage = notice;
    if (_mocks.isEmpty && _errorMessage.isEmpty) {
      _errorMessage = 'No published mock tests yet. Create one in the Admin panel.';
    }
    if (mounted) setState(() {});
  }

  Future<bool> _loadCachedMocks(String examType) async {
    try {
      final cached = await LocalDb.instance.getCachedMockDashboard(examType);
      if (cached == null || cached.isEmpty) return false;
      _applyMockList(cached);
      return _mocks.isNotEmpty;
    } catch (e) {
      debugPrint('Cached mocks load failed: $e');
      return false;
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

  String get _sectionLabel {
    if (_filter != 'All') return _filter.toUpperCase();
    if (_hasFullTestAccess()) return 'ALL EXAMS';
    return _normalizedPreference();
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
          if (_errorMessage.isNotEmpty && _mocks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _noticeBanner(),
            ),
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
            child: _isLoading && _mocks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _mocks.isEmpty
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

  Widget _noticeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Text(
        _errorMessage,
        style: const TextStyle(fontSize: 12, color: Color(0xFF9A3412), height: 1.35),
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
              _errorMessage.isEmpty
                  ? 'No published mock tests yet. Create one in the Admin panel.'
                  : _errorMessage,
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
