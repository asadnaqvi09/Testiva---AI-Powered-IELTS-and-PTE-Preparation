import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/local_db.dart';
import '../../core/services/api_service.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/offline_audio_cache.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/services/user_notifier.dart';
import '../../data/demo/demo_mock_runtime.dart';
import '../../widgets/app_theme.dart';
import '../profile/all_tests_screen.dart';
import 'models/runtime_question.dart';
import 'test_results_screen.dart';
import 'widgets/matching_engine.dart';
import 'widgets/selection_engine.dart';
import 'widgets/input_engine.dart';
import 'widgets/speaking_recorder.dart';

class DynamicTestScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final int totalDurationMinutes;

  const DynamicTestScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    this.totalDurationMinutes = 60,
  });

  @override
  State<DynamicTestScreen> createState() => _DynamicTestScreenState();
}

class _DynamicTestScreenState extends State<DynamicTestScreen> {
  int _currentIndex = 0;
  late int _remainingSeconds;
  Timer? _countdownTimer;
  Timer? _draftSaveTimer;
  bool _isPassageExpanded = true;
  final Map<int, dynamic> _answers = {};
  List<RuntimeQuestion> _questions = [];
  List<RuntimeSectionInfo> _sections = [];
  int _sectionIndex = 0;
  bool _useSectionTimers = false;
  bool _isLoading = false;
  late DateTime _startedAt;
  final TextEditingController _textController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingAudioUrl;
  bool _isAudioPlaying = false;
  bool _loadedFromCache = false;
  bool _isOfflineMode = false;
  String _draftKey = '';
  String _attemptLocalId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalDurationMinutes * 60;
    _startedAt = DateTime.now();
    final userId = UserNotifier.notifier.value['id']?.toString() ?? 'local';
    _draftKey = '${userId}_${widget.testId}';
    _fetchTestDetails();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isAudioPlaying = false);
    });
  }

  Future<void> _fetchTestDetails() async {
    setState(() => _isLoading = true);
    try {
      final online = await ConnectivityService.instance.checkOnline();

      if (online) {
        try {
          final response =
              await ApiService.get('/content/test/${widget.testId}/runtime');
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            if (body['success'] == true) {
              final data = body['data'] as Map<String, dynamic>;
              await LocalDb.instance.cacheTestRuntime(
                testId: widget.testId,
                title: widget.testTitle,
                durationMinutes: widget.totalDurationMinutes,
                payload: data,
              );
              // clean and optimized code — prefetch listening audio for offline
              unawaited(OfflineAudioCache.cacheFromRuntimePayload(
                testId: widget.testId,
                payload: data,
              ));
              final parsed = TestRuntimeParser.parseFullRuntime(data);
              if (mounted) {
                await _applyParsedRuntime(
                  parsed,
                  fromCache: false,
                  offline: false,
                );
              }
              return;
            }
          }
        } catch (_) {}
      }

      final cached = await LocalDb.instance.getCachedTestRuntime(widget.testId);
      if (cached != null) {
        await _applyParsedRuntime(
          TestRuntimeParser.parseFullRuntime(
            cached['data'] as Map<String, dynamic>,
          ),
          fromCache: true,
          offline: !online,
        );
        return;
      }

      // clean and optimized code — bundled runtime (no prior online cache needed)
      final demo = DemoMockRuntime.payloadFor(widget.testId);
      if (demo != null) {
        await LocalDb.instance.cacheTestRuntime(
          testId: widget.testId,
          title: widget.testTitle,
          durationMinutes: widget.totalDurationMinutes,
          payload: demo,
        );
        await _applyParsedRuntime(
          TestRuntimeParser.parseFullRuntime(demo),
          fromCache: true,
          offline: !online,
        );
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _applyParsedRuntime(
    ParsedTestRuntime parsed, {
    required bool fromCache,
    required bool offline,
  }) async {
    if (!mounted) return;
    setState(() {
      _questions = parsed.questions;
      _sections = parsed.sections;
      _useSectionTimers = parsed.useSectionTimers;
      _sectionIndex = 0;
      _loadedFromCache = fromCache;
      _isOfflineMode = offline;
      _isLoading = false;
    });

    final restored = await _tryRestoreDraft();
    if (!restored) {
      if (_useSectionTimers && _sections.isNotEmpty) {
        _remainingSeconds = _sections.first.timeLimitMinutes * 60;
        _currentIndex = _sections.first.startIndex;
      } else {
        _remainingSeconds = widget.totalDurationMinutes * 60;
        _currentIndex = 0;
      }
    }

    if (!mounted) return;
    _syncTextController();
    if (_questions.isNotEmpty) _startTimer();
  }

  Future<bool> _tryRestoreDraft() async {
    try {
      final draft = await LocalDb.instance.getInProgressDraft(_draftKey);
      if (draft == null) return false;
      final answersRaw = draft['answers'];
      if (answersRaw is! Map) return false;

      final restoredAnswers = <int, dynamic>{};
      answersRaw.forEach((key, value) {
        final idx = int.tryParse(key.toString());
        if (idx == null || value is! Map) return;
        final type = value['type']?.toString() ?? 'raw';
        if (type == 'speaking') {
          restoredAnswers[idx] = SpeakingAnswerState(
            localPath: value['localPath']?.toString(),
            audioResponseUrl: value['audioResponseUrl']?.toString(),
          );
        } else if (type == 'map' && value['value'] is Map) {
          restoredAnswers[idx] = Map<String, String>.from(
            (value['value'] as Map).map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            ),
          );
        } else if (type == 'list' && value['value'] is List) {
          restoredAnswers[idx] =
              (value['value'] as List).map((e) => e.toString()).toList();
        } else {
          restoredAnswers[idx] = value['value'];
        }
      });

      final idx = (draft['current_index'] as num?)?.toInt() ?? 0;
      final secIdx = (draft['section_index'] as num?)?.toInt() ?? 0;
      final rem = (draft['remaining_seconds'] as num?)?.toInt() ?? 0;
      final started = DateTime.tryParse(draft['started_at']?.toString() ?? '');
      final attemptId = draft['attempt_local_id']?.toString();

      if (!mounted) return false;
      setState(() {
        _answers
          ..clear()
          ..addAll(restoredAnswers);
        _currentIndex = idx.clamp(0, _questions.isEmpty ? 0 : _questions.length - 1);
        _sectionIndex = secIdx.clamp(
          0,
          _sections.isEmpty ? 0 : _sections.length - 1,
        );
        _remainingSeconds = rem > 0
            ? rem
            : (_useSectionTimers && _sections.isNotEmpty
                ? _sections[_sectionIndex].timeLimitMinutes * 60
                : widget.totalDurationMinutes * 60);
        if (started != null) _startedAt = started;
        if (attemptId != null && attemptId.isNotEmpty) {
          _attemptLocalId = attemptId;
        }
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _serializeDraftAnswers() {
    final out = <String, dynamic>{};
    _answers.forEach((i, v) {
      if (v is SpeakingAnswerState) {
        out['$i'] = {
          'type': 'speaking',
          'localPath': v.localPath,
          'audioResponseUrl': v.audioResponseUrl,
        };
      } else if (v is Map) {
        out['$i'] = {
          'type': 'map',
          'value': Map<String, String>.from(
            v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? '')),
          ),
        };
      } else if (v is List) {
        out['$i'] = {
          'type': 'list',
          'value': v.map((e) => e.toString()).toList(),
        };
      } else {
        out['$i'] = {'type': 'raw', 'value': v};
      }
    });
    return out;
  }

  void _scheduleDraftSave() {
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 600), () {
      unawaited(_persistDraft());
    });
  }

  Future<void> _persistDraft() async {
    if (_questions.isEmpty || _draftKey.isEmpty) return;
    try {
      final userId = UserNotifier.notifier.value['id']?.toString() ?? 'local';
      await LocalDb.instance.saveInProgressDraft(
        draftKey: _draftKey,
        userId: userId,
        testId: widget.testId,
        attemptLocalId: _attemptLocalId,
        currentIndex: _currentIndex,
        sectionIndex: _sectionIndex,
        remainingSeconds: _remainingSeconds,
        answers: _serializeDraftAnswers(),
        startedAt: _startedAt.toIso8601String(),
      );
    } catch (_) {}
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds % 15 == 0) _scheduleDraftSave();
      } else {
        timer.cancel();
        _onTimerExpired();
      }
    });
  }

  void _onTimerExpired() {
    if (_useSectionTimers && _sectionIndex < _sections.length - 1) {
      _advanceToSection(_sectionIndex + 1);
      return;
    }
    // Last section / singular module: auto-submit (Acelt intent).
    unawaited(_submitTest());
  }

  void _advanceToSection(int nextSectionIndex) {
    if (nextSectionIndex < 0 || nextSectionIndex >= _sections.length) {
      unawaited(_submitTest());
      return;
    }
    final next = _sections[nextSectionIndex];
    setState(() {
      _sectionIndex = nextSectionIndex;
      _currentIndex = next.startIndex;
      _remainingSeconds = next.timeLimitMinutes * 60;
    });
    _syncTextController();
    _startTimer();
    _scheduleDraftSave();
  }

  RuntimeSectionInfo? get _currentSection {
    if (_sections.isEmpty) return null;
    if (_useSectionTimers) {
      return _sections[_sectionIndex.clamp(0, _sections.length - 1)];
    }
    for (final s in _sections) {
      if (_currentIndex >= s.startIndex && _currentIndex < s.endIndex) {
        return s;
      }
    }
    return _sections.first;
  }

  bool get _isLastQuestionInSection {
    final sec = _currentSection;
    if (sec == null) return _currentIndex >= _questions.length - 1;
    return _currentIndex >= sec.endIndex - 1;
  }

  bool get _canGoPrevInScope {
    if (!_useSectionTimers) return _currentIndex > 0;
    final sec = _currentSection;
    if (sec == null) return false;
    return _currentIndex > sec.startIndex;
  }

  void _goNext() {
    if (_useSectionTimers) {
      final sec = _currentSection;
      if (sec == null) return;
      if (_currentIndex < sec.endIndex - 1) {
        setState(() => _currentIndex++);
        _syncTextController();
        _scheduleDraftSave();
        return;
      }
      if (_sectionIndex < _sections.length - 1) {
        _advanceToSection(_sectionIndex + 1);
        return;
      }
      _confirmSubmit();
      return;
    }
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
      _syncTextController();
      _scheduleDraftSave();
    } else {
      _confirmSubmit();
    }
  }

  void _goPrev() {
    if (!_canGoPrevInScope) return;
    setState(() => _currentIndex--);
    _syncTextController();
    _scheduleDraftSave();
  }

  void _setAnswer(dynamic value) {
    setState(() => _answers[_currentIndex] = value);
    _scheduleDraftSave();
  }

  void _syncTextController() {
    final ans = _answers[_currentIndex];
    _textController.text = ans is String ? ans : '';
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  RuntimeQuestion? get _current => _questions.isEmpty ? null : _questions[_currentIndex];

  String? get _currentAudioUrl {
    final q = _current;
    if (q == null || !q.hasAudio) return null;
    return q.audioUrl;
  }

  Future<void> _toggleAudio() async {
    final url = _currentAudioUrl;
    if (url == null) return;
    try {
      if (_isAudioPlaying && _playingAudioUrl == url) {
        await _audioPlayer.pause();
        setState(() => _isAudioPlaying = false);
        return;
      }
      if (_playingAudioUrl != url) {
        await _audioPlayer.stop();
        // clean and optimized code — prefer local cache when offline
        final localPath = await OfflineAudioCache.resolvePlayableSource(url);
        if (localPath != null) {
          await _audioPlayer.play(DeviceFileSource(localPath));
        } else {
          await _audioPlayer.play(UrlSource(url));
        }
        _playingAudioUrl = url;
      } else {
        await _audioPlayer.resume();
      }
      setState(() => _isAudioPlaying = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not play audio. Open this test once online to cache audio.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _draftSaveTimer?.cancel();
    unawaited(_persistDraft());
    _textController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formattedTime() {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _timerSubtitle() {
    if (_useSectionTimers) {
      final name = _currentSection?.sectionName ?? 'Section';
      return '$name · ${_formattedTime()}';
    }
    return _formattedTime();
  }

  int _wordCount(String text) => text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submit Test?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Submit your answers for scoring and AI evaluation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Review')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066F5)),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  dynamic _serializeAnswer(RuntimeQuestion q, dynamic raw) {
    if (q.kind == QuestionKind.writing) {
      final text = raw is String ? raw : '';
      return text.trim().isEmpty ? '' : {'text_essay': text};
    }
    if (q.kind == QuestionKind.speaking) {
      return <String, dynamic>{};
    }
    if (q.kind == QuestionKind.multiSelect && raw is List) {
      return raw;
    }
    if (q.kind == QuestionKind.matching && raw is Map) {
      return (raw as Map<String, String>).entries
          .map((e) => {'key': e.key, 'value': e.value})
          .toList();
    }
    return raw?.toString() ?? '';
  }

  Future<String?> _uploadSpeakingLocal(String localPath) async {
    final online = await ConnectivityService.instance.checkOnline();
    if (!online) return null;
    try {
      return await ApiService.uploadSpeakingAudio(localPath);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitTest() async {
    setState(() => _isLoading = true);
    try {
      final elapsed = DateTime.now().difference(_startedAt).inSeconds;
      final timeTaken = elapsed > 0 ? elapsed : 1;
      final perQ = _questions.isEmpty ? 0 : timeTaken ~/ _questions.length;
      final responses = <Map<String, dynamic>>[];

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        var raw = _answers[i];

        String? audioUrl;
        if (q.isSpeaking) {
          SpeakingAnswerState speaking = raw is SpeakingAnswerState
              ? raw
              : const SpeakingAnswerState();
          audioUrl = speaking.audioResponseUrl;
          if ((audioUrl == null || audioUrl.isEmpty) && speaking.hasLocal) {
            final uploaded = await _uploadSpeakingLocal(speaking.localPath!);
            if (uploaded != null && uploaded.isNotEmpty) {
              audioUrl = uploaded;
              speaking = speaking.copyWith(audioResponseUrl: uploaded);
              _answers[i] = speaking;
              raw = speaking;
            }
          }
        }

        final serialized = _serializeAnswer(q, raw);
        int wc = 0;
        if (q.isWriting && raw is String) wc = _wordCount(raw);

        // clean and optimized code — keep local path for offline sync upload
        String? localAudioPath;
        if (q.isSpeaking && raw is SpeakingAnswerState) {
          localAudioPath = raw.localPath;
        }

        responses.add({
          'question_id': q.id,
          'user_answer': serialized,
          'time_spent_seconds': perQ,
          if (wc > 0) 'word_count': wc,
          if (audioUrl != null && audioUrl.isNotEmpty)
            'audio_response_url': audioUrl,
          if ((audioUrl == null || audioUrl.isEmpty) &&
              localAudioPath != null &&
              localAudioPath.isNotEmpty)
            'local_audio_path': localAudioPath,
        });
      }

      final missingSpeaking = _questions.asMap().entries.where((e) {
        if (!e.value.isSpeaking) return false;
        final resp = responses[e.key];
        final url = resp['audio_response_url']?.toString() ?? '';
        return url.isEmpty;
      }).length;
      if (missingSpeaking > 0 && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Speaking audio missing'),
            content: Text(
              '$missingSpeaking speaking answer(s) have no uploaded audio. '
              'Those items will not be AI-scored. Continue anyway?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Go back'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Submit anyway'),
              ),
            ],
          ),
        );
        if (proceed != true) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      final body = {
        'test_id': widget.testId,
        'client_started_at': _startedAt.toIso8601String(),
        'client_completed_at': DateTime.now().toIso8601String(),
        'responses': responses,
      };

      final online = await ConnectivityService.instance.checkOnline();
      if (online) {
        try {
          final response = await ApiService.post('/progress/submit-test', body);
          if (response.statusCode == 201 || response.statusCode == 202) {
            final resData = jsonDecode(response.body) as Map<String, dynamic>;
            if (resData['success'] == true) {
              final attemptId =
                  (resData['data'] as Map?)?['attemptId']?.toString() ?? '';
              final status =
                  (resData['data'] as Map?)?['status']?.toString() ?? 'completed';
              await LocalDb.instance.clearInProgressDraft(_draftKey);
              if (!mounted) return;
              _navigateToResults(
                attemptId: attemptId,
                pending: status == 'pending',
              );
              return;
            }
          }
        } catch (_) {
          // Fall through to offline save on network failure.
        }
      }

      final localId = const Uuid().v4();
      await LocalDb.instance.saveOfflineAttempt(
        localId: localId,
        testId: widget.testId,
        testTitle: widget.testTitle,
        clientStartedAt: body['client_started_at'] as String,
        clientCompletedAt: body['client_completed_at'] as String,
        payload: body,
      );
      await LocalDb.instance.clearInProgressDraft(_draftKey);

      if (ConnectivityService.instance.isOnline) {
        unawaited(OfflineSyncService.instance.syncPendingAttempts());
      }

      if (!mounted) return;
      _navigateToResults(
        localId: localId,
        isOfflineSaved: true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit error: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _navigateToResults({
    String attemptId = '',
    String? localId,
    bool pending = false,
    bool isOfflineSaved = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultsScreen(
          attemptId: attemptId.isNotEmpty ? attemptId : (localId ?? ''),
          initialPending: pending,
          isOfflineSaved: isOfflineSaved,
          testTitle: widget.testTitle,
          onRetake: () {
            unawaited(LocalDb.instance.clearInProgressDraft(_draftKey));
            setState(() {
              _currentIndex = 0;
              _sectionIndex = 0;
              _attemptLocalId = const Uuid().v4();
              _answers.clear();
              _startedAt = DateTime.now();
              if (_useSectionTimers && _sections.isNotEmpty) {
                _remainingSeconds = _sections.first.timeLimitMinutes * 60;
                _currentIndex = _sections.first.startIndex;
              } else {
                _remainingSeconds = widget.totalDurationMinutes * 60;
              }
            });
            _syncTextController();
            Navigator.pop(context);
            _startTimer();
          },
          onAllTestsPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllTestsScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg(context),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.testTitle, style: TextStyle(color: AppTheme.primaryText(context))),
          backgroundColor: AppTheme.appBarBg(context),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadedFromCache
                  ? 'This test is not cached on your device yet.\nOpen it once while online to take it offline.'
                  : 'No questions available for this test.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryText(context)),
            ),
          ),
        ),
      );
    }

    final q = _current!;
    final nextColor = AppTheme.isDark(context) ? Colors.blueAccent : const Color(0xFF0066F5);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarBg(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.iconColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q ${_currentIndex + 1}/${_questions.length}',
              style: TextStyle(color: AppTheme.primaryText(context), fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              _timerSubtitle(),
              style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (q.hasPassage || q.hasImage)
            IconButton(
              icon: Icon(_isPassageExpanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.iconColor(context)),
              onPressed: () => setState(() => _isPassageExpanded = !_isPassageExpanded),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isOfflineMode || _loadedFromCache)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.orange.withValues(alpha: 0.12),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isOfflineMode
                                ? 'Offline mode — answers will sync when you reconnect'
                                : 'Loaded from device cache',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (q.hasAudio) _buildAudioBar(context),
                if (q.isListening && !q.hasAudio)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: Colors.orange.withValues(alpha: 0.12),
                    child: const Row(
                      children: [
                        Icon(Icons.volume_off, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Admin has not attached audio for this listening mock.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isPassageExpanded && (q.hasPassage || q.hasImage)) ...[
                          _buildContextPanel(context, q),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            _chip(q.typeLabel, AppTheme.tagBg(context), AppTheme.tagText(context)),
                            const SizedBox(width: 8),
                            _chip(q.sectionName, const Color(0xFFF1F5F9), const Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildModuleHint(context, q),
                        const SizedBox(height: 12),
                        Text(
                          '${_currentIndex + 1}. ${q.text}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText(context),
                            height: 1.4,
                          ),
                        ),
                        if (q.wordLimitInstruction != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            q.wordLimitInstruction!,
                            style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildAnswerWidget(context, q),
                      ],
                    ),
                  ),
                ),
                _buildNavBar(context, nextColor),
              ],
            ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModuleHint(BuildContext context, RuntimeQuestion q) {
    String title;
    String body;
    IconData icon;
    Color color;
    if (q.isSpeaking) {
      title = 'Speaking';
      body = 'Read the prompt, then record. Gemini Flash scores fluency, vocabulary, grammar, and pronunciation.';
      icon = Icons.mic_none_rounded;
      color = const Color(0xFFDB2777);
    } else if (q.isWriting) {
      title = 'Writing';
      body = 'Write at least the word limit. Gemini scores task response, cohesion, vocabulary, and grammar.';
      icon = Icons.edit_outlined;
      color = const Color(0xFFEA580C);
    } else if (q.isListening) {
      title = 'Listening';
      body = 'Play the audio, then answer. Score is correct answers mapped to an IELTS listening band.';
      icon = Icons.headphones_outlined;
      color = const Color(0xFF16A34A);
    } else {
      title = 'Reading';
      body = 'Use the passage above. Score is correct answers mapped to an IELTS reading band.';
      icon = Icons.menu_book_outlined;
      color = const Color(0xFF7C3AED);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppTheme.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF1D4ED8).withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(Icons.headphones, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Listening audio',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade800, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: _toggleAudio,
            icon: Icon(
              _isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: const Color(0xFF1D4ED8),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextPanel(BuildContext context, RuntimeQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.sectionName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText(context))),
          const SizedBox(height: 10),
          if (q.hasImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(q.imageUrl!, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
          if (q.hasPassage)
            Text(
              q.passageText,
              style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.primaryText(context).withValues(alpha: 0.85)),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerWidget(BuildContext context, RuntimeQuestion q) {
    switch (q.kind) {
      case QuestionKind.mcq:
        return SelectionEngineWidget(
          options: q.options,
          selectedAnswer: _answers[_currentIndex],
          onChanged: _setAnswer,
        );
      case QuestionKind.multiSelect:
        final selected = (_answers[_currentIndex] as List<String>?) ?? <String>[];
        return Column(
          children: q.options.map((opt) {
            final checked = selected.contains(opt);
            return CheckboxListTile(
              value: checked,
              title: Text(opt, style: TextStyle(color: AppTheme.primaryText(context), fontSize: 14)),
              onChanged: (v) {
                final next = List<String>.from(selected);
                if (v == true) {
                  next.add(opt);
                } else {
                  next.remove(opt);
                }
                _setAnswer(next);
              },
            );
          }).toList(),
        );
      case QuestionKind.trueFalseNg:
        return _pillRow(['True', 'False', 'Not Given']);
      case QuestionKind.yesNoNg:
        return _pillRow(['Yes', 'No', 'Not Given']);
      case QuestionKind.matching:
        final keys = q.matchingKeys.map((p) => p['key'] ?? '').where((k) => k.isNotEmpty).toList();
        final opts = q.options.isNotEmpty ? q.options : q.matchingKeys.map((p) => p['value'] ?? '').where((v) => v.isNotEmpty).toList();
        final selected = Map<String, String>.from(_answers[_currentIndex] as Map? ?? {});
        return MatchingEngineWidget(
          questionsToMatch: keys.isNotEmpty ? keys : [q.text],
          availableOptions: opts,
          selectedAnswers: selected,
          onOptionChanged: (question, option) {
            final m = Map<String, String>.from(selected);
            m[question] = option;
            _setAnswer(m);
          },
        );
      case QuestionKind.writing:
        final text = (_answers[_currentIndex] as String?) ?? '';
        final wc = _wordCount(text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.inputFill(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor(context)),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 12,
                style: TextStyle(color: AppTheme.primaryText(context)),
                onChanged: (v) {
                  setState(() => _answers[_currentIndex] = v);
                  _scheduleDraftSave();
                },
                decoration: InputDecoration(
                  hintText: 'Write your response here…',
                  hintStyle: TextStyle(color: AppTheme.secondaryText(context)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$wc words${q.minWords > 0 ? ' (min ${q.minWords})' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: q.minWords > 0 && wc < q.minWords ? Colors.orange : Colors.green.shade700,
              ),
            ),
          ],
        );
      case QuestionKind.speaking:
        final initial = _answers[_currentIndex] is SpeakingAnswerState
            ? _answers[_currentIndex] as SpeakingAnswerState
            : null;
        return SpeakingRecorderWidget(
          key: ValueKey('speaking_${q.id}'),
          question: q,
          initial: initial,
          uploadAudio: _uploadSpeakingLocal,
          onChanged: (state) {
            setState(() => _answers[_currentIndex] = state);
            _scheduleDraftSave();
          },
        );
      case QuestionKind.sentenceCompletion:
      case QuestionKind.shortAnswer:
      case QuestionKind.formFill:
      case QuestionKind.unknown:
        // clean and optimized code — dedicated short-answer / fill UI
        return InputEngineWidget(
          key: ValueKey('input_${q.id}_$_currentIndex'),
          initialValue: (_answers[_currentIndex] as String?) ?? '',
          onChanged: (v) {
            setState(() => _answers[_currentIndex] = v);
            _scheduleDraftSave();
          },
        );
    }
  }

  Widget _pillRow(List<String> options) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final selected = _answers[_currentIndex] == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: selected,
          onSelected: (_) => _setAnswer(opt),
          selectedColor: AppTheme.tagText(context),
          labelStyle: TextStyle(color: selected ? Colors.white : AppTheme.primaryText(context)),
        );
      }).toList(),
    );
  }

  Widget _buildNavBar(BuildContext context, Color nextColor) {
    final atLastOverall = _currentIndex >= _questions.length - 1;
    final showSubmit = _useSectionTimers
        ? (_isLastQuestionInSection && _sectionIndex >= _sections.length - 1)
        : atLastOverall;
    final nextLabel = _useSectionTimers && _isLastQuestionInSection && !showSubmit
        ? 'Next Section'
        : 'Next';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg(context),
        border: Border(top: BorderSide(color: AppTheme.borderColor(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_canGoPrevInScope)
            OutlinedButton.icon(
              onPressed: _goPrev,
              icon: Icon(Icons.arrow_back, size: 16, color: AppTheme.primaryText(context)),
              label: Text('Prev', style: TextStyle(color: AppTheme.primaryText(context))),
            )
          else
            const SizedBox(width: 80),
          if (!showSubmit)
            ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(backgroundColor: nextColor),
              child: Text(nextLabel, style: const TextStyle(color: Colors.white)),
            )
          else
            ElevatedButton(
              onPressed: _confirmSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

/// Backward-compatible alias used by older imports.
typedef ReadingTestScreen = DynamicTestScreen;
