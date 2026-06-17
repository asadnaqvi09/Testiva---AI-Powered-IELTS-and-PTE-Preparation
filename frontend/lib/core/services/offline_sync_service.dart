import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/database/local_db.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/connectivity_service.dart';

class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  bool _syncing = false;
  VoidCallback? onSyncComplete;

  Future<void> initialize() async {
    ConnectivityService.instance.addListener(_onConnectivityChanged);
    if (ConnectivityService.instance.isOnline) {
      unawaited(syncPendingAttempts());
    }
  }

  void _onConnectivityChanged(bool isOnline) {
    if (isOnline) {
      unawaited(syncPendingAttempts());
    }
  }

  Future<int> syncPendingAttempts() async {
    if (_syncing) return 0;
    if (!ConnectivityService.instance.isOnline) return 0;

    final pending = await LocalDb.instance.getPendingAttempts();
    if (pending.isEmpty) return 0;

    _syncing = true;
    var uploaded = 0;

    try {
      for (final row in pending) {
        final localId = row['local_id'] as String;
        final payload =
            jsonDecode(row['payload_json'] as String) as Map<String, dynamic>;
        final body = Map<String, dynamic>.from(payload)..['is_offline'] = true;

        try {
          final response =
              await ApiService.post('/progress/submit-test', body);
          if (response.statusCode == 202 || response.statusCode == 201) {
            final resData = jsonDecode(response.body) as Map<String, dynamic>;
            if (resData['success'] == true) {
              await LocalDb.instance.markAttemptUploaded(localId);
              uploaded++;
              final attemptId =
                  (resData['data'] as Map?)?['attemptId']?.toString();
              if (attemptId != null && attemptId.isNotEmpty) {
                await LocalDb.instance.markAttemptSynced(
                  localId: localId,
                  serverAttemptId: attemptId,
                );
              } else {
                unawaited(_resolveServerAttemptId(
                  localId: localId,
                  testId: row['test_id'] as String,
                  clientStartedAt: row['client_started_at'] as String,
                ));
              }
            }
          } else {
            await LocalDb.instance.markAttemptFailed(localId);
          }
        } catch (e) {
          debugPrint('[OfflineSync] Upload failed for $localId: $e');
        }
      }
    } finally {
      _syncing = false;
      if (uploaded > 0) {
        onSyncComplete?.call();
      }
    }

    return uploaded;
  }

  Future<int> retryFailedAttempts() async {
    await LocalDb.instance.resetFailedAttempts();
    return syncPendingAttempts();
  }

  Future<void> _resolveServerAttemptId({
    required String localId,
    required String testId,
    required String clientStartedAt,
  }) async {
    for (var i = 0; i < 12; i++) {
      await Future<void>.delayed(const Duration(seconds: 5));
      if (!ConnectivityService.instance.isOnline) return;

      try {
        final response = await ApiService.get('/user/results');
        if (response.statusCode != 200) continue;

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] != true) continue;

        final results = body['data'] as List? ?? [];
        for (final item in results) {
          final map = item as Map<String, dynamic>;
          if (map['test_id']?.toString() != testId) continue;

          final started = map['client_started_at']?.toString() ??
              map['created_at']?.toString();
          if (started != null &&
              started.startsWith(clientStartedAt.substring(0, 19))) {
            final attemptId = map['attempt_id']?.toString();
            if (attemptId != null && attemptId.isNotEmpty) {
              await LocalDb.instance.markAttemptSynced(
                localId: localId,
                serverAttemptId: attemptId,
              );
              onSyncComplete?.call();
              return;
            }
          }
        }
      } catch (e) {
        debugPrint('[OfflineSync] Resolve attempt id failed: $e');
      }
    }
  }

  void dispose() {
    ConnectivityService.instance.removeListener(_onConnectivityChanged);
  }
}
