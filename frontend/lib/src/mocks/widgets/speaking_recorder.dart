import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../widgets/app_theme.dart';
import '../models/runtime_question.dart';

/// Prep countdown → record (with max duration) → optional re-record.
class SpeakingRecorderWidget extends StatefulWidget {
  final RuntimeQuestion question;
  final SpeakingAnswerState? initial;
  final ValueChanged<SpeakingAnswerState> onChanged;
  final Future<String?> Function(String localPath) uploadAudio;

  const SpeakingRecorderWidget({
    super.key,
    required this.question,
    required this.onChanged,
    required this.uploadAudio,
    this.initial,
  });

  @override
  State<SpeakingRecorderWidget> createState() => _SpeakingRecorderWidgetState();
}

enum _Phase { idle, prep, recording, done, uploading }

class _SpeakingRecorderWidgetState extends State<SpeakingRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  _Phase _phase = _Phase.idle;
  int _prepLeft = 0;
  int _recordLeft = 0;
  Timer? _timer;
  String? _localPath;
  String? _uploadedUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _localPath = widget.initial?.localPath;
    _uploadedUrl = widget.initial?.audioResponseUrl;
    if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
      _phase = _Phase.done;
    } else if (_localPath != null && _localPath!.isNotEmpty) {
      _phase = _Phase.done;
    }
  }

  @override
  void didUpdateWidget(covariant SpeakingRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _timer?.cancel();
      unawaited(_safeStopRecorder());
      _localPath = widget.initial?.localPath;
      _uploadedUrl = widget.initial?.audioResponseUrl;
      _error = null;
      if (_uploadedUrl != null && _uploadedUrl!.isNotEmpty) {
        _phase = _Phase.done;
      } else if (_localPath != null && _localPath!.isNotEmpty) {
        _phase = _Phase.done;
      } else {
        _phase = _Phase.idle;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_safeStopRecorder());
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _safeStopRecorder() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<bool> _ensureMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _begin() async {
    setState(() => _error = null);
    final allowed = await _ensureMicPermission();
    if (!allowed) {
      setState(() => _error = 'Microphone permission is required to record.');
      return;
    }
    final prep = widget.question.effectivePrepSeconds;
    if (prep > 0) {
      setState(() {
        _phase = _Phase.prep;
        _prepLeft = prep;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_prepLeft <= 1) {
          t.cancel();
          unawaited(_startRecording());
        } else {
          setState(() => _prepLeft--);
        }
      });
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        'speaking_${widget.question.id}_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      final maxSecs = widget.question.effectiveRecordSeconds;
      setState(() {
        _phase = _Phase.recording;
        _recordLeft = maxSecs;
        _localPath = path;
        _uploadedUrl = null;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_recordLeft <= 1) {
          t.cancel();
          unawaited(_stopRecording());
        } else {
          setState(() => _recordLeft--);
        }
      });
    } catch (e) {
      setState(() {
        _phase = _Phase.idle;
        _error = 'Could not start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {}
    path ??= _localPath;
    if (path == null || path.isEmpty) {
      setState(() {
        _phase = _Phase.idle;
        _error = 'Recording failed. Please try again.';
      });
      return;
    }
    setState(() {
      _localPath = path;
      _phase = _Phase.uploading;
    });
    widget.onChanged(SpeakingAnswerState(localPath: path));

    try {
      final url = await widget.uploadAudio(path!);
      if (!mounted) return;
      if (url != null && url.isNotEmpty) {
        setState(() {
          _uploadedUrl = url;
          _phase = _Phase.done;
        });
        widget.onChanged(
          SpeakingAnswerState(localPath: path, audioResponseUrl: url),
        );
      } else {
        setState(() {
          _phase = _Phase.done;
          _error =
              'Saved locally. Will retry upload on submit (needs connection).';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.done;
        _error =
            'Saved locally. Will retry upload on submit (needs connection).';
      });
    }
  }

  Future<void> _reRecord() async {
    _timer?.cancel();
    await _safeStopRecorder();
    setState(() {
      _localPath = null;
      _uploadedUrl = null;
      _error = null;
      _phase = _Phase.idle;
    });
    widget.onChanged(const SpeakingAnswerState());
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.hasCueCard) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cue card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  q.cueCard!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppTheme.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          'Prep ${q.effectivePrepSeconds}s · Record up to ${q.effectiveRecordSeconds}s',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceBg(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Column(
            children: [
              _statusIcon(),
              const SizedBox(height: 10),
              Text(
                _statusLabel(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.primaryText(context),
                ),
              ),
              if (_phase == _Phase.prep || _phase == _Phase.recording) ...[
                const SizedBox(height: 6),
                Text(
                  _phase == _Phase.prep
                      ? _fmt(_prepLeft)
                      : _fmt(_recordLeft),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _phase == _Phase.recording
                        ? Colors.red.shade600
                        : const Color(0xFF1D4ED8),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
              const SizedBox(height: 14),
              _actions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusIcon() {
    switch (_phase) {
      case _Phase.prep:
        return const Icon(Icons.hourglass_top, size: 40, color: Color(0xFF1D4ED8));
      case _Phase.recording:
        return Icon(Icons.mic, size: 40, color: Colors.red.shade600);
      case _Phase.uploading:
        return const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(strokeWidth: 3),
        );
      case _Phase.done:
        return Icon(
          _uploadedUrl != null ? Icons.check_circle : Icons.audio_file,
          size: 40,
          color: _uploadedUrl != null ? Colors.green : Colors.orange,
        );
      case _Phase.idle:
        return Icon(Icons.mic_none, size: 40, color: Colors.grey.shade600);
    }
  }

  String _statusLabel() {
    switch (_phase) {
      case _Phase.idle:
        return 'Tap Start to begin speaking';
      case _Phase.prep:
        return 'Prepare your answer…';
      case _Phase.recording:
        return 'Recording…';
      case _Phase.uploading:
        return 'Uploading audio…';
      case _Phase.done:
        return _uploadedUrl != null
            ? 'Response recorded & uploaded'
            : 'Response recorded (upload pending)';
    }
  }

  Widget _actions() {
    switch (_phase) {
      case _Phase.idle:
        return ElevatedButton.icon(
          onPressed: _begin,
          icon: const Icon(Icons.mic, color: Colors.white),
          label: const Text('Start', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0066F5),
          ),
        );
      case _Phase.prep:
        return TextButton(
          onPressed: () {
            _timer?.cancel();
            unawaited(_startRecording());
          },
          child: const Text('Skip prep'),
        );
      case _Phase.recording:
        return ElevatedButton.icon(
          onPressed: _stopRecording,
          icon: const Icon(Icons.stop, color: Colors.white),
          label: const Text('Stop', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
        );
      case _Phase.uploading:
        return const SizedBox.shrink();
      case _Phase.done:
        return OutlinedButton.icon(
          onPressed: _reRecord,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Re-record'),
        );
    }
  }
}
