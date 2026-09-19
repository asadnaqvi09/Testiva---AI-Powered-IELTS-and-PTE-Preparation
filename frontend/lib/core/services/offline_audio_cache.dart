import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:frontend/core/database/local_db.dart';

/// Downloads listening audio while online so offline mocks can play locally.
class OfflineAudioCache {
  OfflineAudioCache._();

  // clean and optimized code — collect unique http(s) audio URLs from runtime
  static Set<String> extractAudioUrls(Map<String, dynamic> payload) {
    final urls = <String>{};
    final sections = payload['sections'];
    if (sections is! List) return urls;
    for (final sec in sections) {
      if (sec is! Map) continue;
      final questions = sec['questions'];
      if (questions is! List) continue;
      for (final q in questions) {
        if (q is! Map) continue;
        final u = q['audio_url']?.toString() ?? '';
        if (u.startsWith('http://') || u.startsWith('https://')) {
          urls.add(u);
        }
      }
    }
    return urls;
  }

  static Future<void> cacheFromRuntimePayload({
    required String testId,
    required Map<String, dynamic> payload,
  }) async {
    final urls = extractAudioUrls(payload);
    if (urls.isEmpty) return;

    Directory dir;
    try {
      dir = await getApplicationDocumentsDirectory();
    } catch (e) {
      debugPrint('[OfflineAudioCache] docs dir failed: $e');
      return;
    }
    final audioDir = Directory(p.join(dir.path, 'testiva_audio_cache'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    for (final url in urls) {
      try {
        final existing = await LocalDb.instance.getCachedAudioPath(url);
        if (existing != null && File(existing).existsSync()) continue;

        final response = await http.get(Uri.parse(url));
        if (response.statusCode < 200 || response.statusCode >= 300) continue;

        final ext = _extFromUrl(url);
        final hash = url.hashCode.toUnsigned(32).toRadixString(16);
        final filePath = p.join(audioDir.path, '${testId}_$hash$ext');
        await File(filePath).writeAsBytes(response.bodyBytes, flush: true);
        await LocalDb.instance.saveCachedAudio(
          remoteUrl: url,
          localPath: filePath,
          testId: testId,
        );
      } catch (e) {
        debugPrint('[OfflineAudioCache] skip $url: $e');
      }
    }
  }

  static Future<String?> resolvePlayableSource(String remoteUrl) async {
    final local = await LocalDb.instance.getCachedAudioPath(remoteUrl);
    if (local != null && File(local).existsSync()) return local;
    return null;
  }

  static String _extFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? '';
    final ext = p.extension(path).toLowerCase();
    if (ext.length >= 2 && ext.length <= 5) return ext;
    return '.mp3';
  }
}
