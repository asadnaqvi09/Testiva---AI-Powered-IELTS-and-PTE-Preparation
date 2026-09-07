import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/database/local_db.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/services/connectivity_service.dart';
import 'package:frontend/core/services/offline_sync_service.dart';
import 'package:frontend/src/mocks/test_results_screen.dart';
import 'package:frontend/widgets/app_theme.dart';
import 'package:intl/intl.dart';

class AllTestsScreen extends StatefulWidget {
  final String? initialAttemptId;

  const AllTestsScreen({super.key, this.initialAttemptId});

  @override
  State<AllTestsScreen> createState() => _AllTestsScreenState();
}

class _AllTestsScreenState extends State<AllTestsScreen> {
  bool _loading = true;
  String? _error;
  List<_TestHistoryItem> _items = [];
  int _failedCount = 0;
  int _pendingCount = 0;
  int _syncedCount = 0;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final merged = <_TestHistoryItem>[];
      final serverByAttemptId = <String, Map<String, dynamic>>{};
      final linkedServerIds = <String>{};

      if (ConnectivityService.instance.isOnline) {
        try {
          final response = await ApiService.get('/user/results');
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body) as Map<String, dynamic>;
            if (body['success'] == true) {
              for (final raw in body['data'] as List? ?? []) {
                final map = Map<String, dynamic>.from(raw as Map);
                final attemptId = map['attempt_id']?.toString() ?? '';
                if (attemptId.isNotEmpty) {
                  serverByAttemptId[attemptId] = map;
                }
              }
            }
          }
        } catch (_) {}
      }

      final localAttempts = await LocalDb.instance.getAllLocalAttempts();
      final failed = await LocalDb.instance.getFailedAttempts();

      for (final row in localAttempts) {
        final syncStatus = row['sync_status'] as String? ?? 'pending';
        final serverId = row['server_attempt_id'] as String?;
        if (serverId != null && serverId.isNotEmpty) {
          linkedServerIds.add(serverId);
        }

        final serverRow = serverId != null ? serverByAttemptId[serverId] : null;
        final status = _resolveStatus(syncStatus, serverRow);
        final band = serverRow != null
            ? _parseBand(serverRow['overall_band_score'])
            : null;

        merged.add(_TestHistoryItem(
          id: serverId ?? row['local_id'] as String,
          localId: row['local_id'] as String,
          testTitle: row['test_title'] as String? ?? 'Mock Test',
          completedAt: DateTime.tryParse(
                row['client_completed_at'] as String? ?? '',
              ) ??
              DateTime.now(),
          bandScore: band,
          status: status,
          isLocalOnly: serverId == null,
        ));
      }

      for (final entry in serverByAttemptId.entries) {
        if (linkedServerIds.contains(entry.key)) continue;
        final map = entry.value;
        merged.add(_TestHistoryItem(
          id: entry.key,
          localId: null,
          testTitle: map['test_title']?.toString() ?? 'Mock Test',
          completedAt: DateTime.tryParse(
                map['client_completed_at']?.toString() ??
                    map['created_at']?.toString() ??
                    '',
              ) ??
              DateTime.now(),
          bandScore: _parseBand(map['overall_band_score']),
          status: map['status']?.toString() ?? 'completed',
          isLocalOnly: false,
        ));
      }

      merged.sort((a, b) => b.completedAt.compareTo(a.completedAt));

      if (mounted) {
        setState(() {
          _items = merged;
          _failedCount = failed.length;
          _pendingCount = localAttempts
              .where((r) =>
                  (r['sync_status'] as String?) == 'pending' ||
                  (r['sync_status'] as String?) == 'uploaded')
              .length;
          _syncedCount = localAttempts
              .where((r) => (r['sync_status'] as String?) == 'synced')
              .length;
          _loading = false;
        });
        _openInitialAttemptIfNeeded();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load test history: $e';
          _loading = false;
        });
      }
    }
  }

  String _resolveStatus(String syncStatus, Map<String, dynamic>? serverRow) {
    if (syncStatus == 'pending') return 'offline_pending';
    if (syncStatus == 'failed') return 'failed';
    if (syncStatus == 'uploaded') {
      return serverRow?['status']?.toString() ?? 'pending';
    }
    if (syncStatus == 'synced') {
      return serverRow?['status']?.toString() ?? 'completed';
    }
    return syncStatus;
  }

  void _openInitialAttemptIfNeeded() {
    final targetId = widget.initialAttemptId;
    if (targetId == null || targetId.isEmpty) return;

    _TestHistoryItem? match;
    for (final item in _items) {
      if (item.id == targetId || item.localId == targetId) {
        match = item;
        break;
      }
    }
    if (match != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openItem(match!);
      });
    }
  }

  Future<void> _retryFailedUploads() async {
    if (!ConnectivityService.instance.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect to the internet to retry uploads.')),
      );
      return;
    }

    setState(() => _retrying = true);
    try {
      final count = await OfflineSyncService.instance.retryFailedAttempts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'Retrying $count offline test(s)...'
                : 'No failed uploads to retry.',
          ),
        ),
      );
      await _loadHistory();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  double? _parseBand(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  void _openItem(_TestHistoryItem item) {
    if (item.status == 'offline_pending') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultsScreen(
            attemptId: item.localId ?? item.id,
            isOfflineSaved: true,
            testTitle: item.testTitle,
            onRetake: () => Navigator.pop(context),
            onAllTestsPressed: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    if (item.status == 'failed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Use "Retry failed uploads" above.'),
        ),
      );
      return;
    }

    if (item.isLocalOnly) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result is still uploading. Check back shortly.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestResultsScreen(
          attemptId: item.id,
          initialPending: item.status == 'pending',
          testTitle: item.testTitle,
          onRetake: () => Navigator.pop(context),
          onAllTestsPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg(context),
      appBar: AppBar(
        title: const Text('All Tests'),
        backgroundColor: AppTheme.appBarBg(context),
        foregroundColor: AppTheme.primaryText(context),
        elevation: 0,
        actions: [
          if (_failedCount > 0)
            TextButton(
              onPressed: _retrying ? null : _retryFailedUploads,
              child: _retrying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Retry failed'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No tests yet.\nComplete a mock test to see it here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (ConnectivityService.instance.isOnline) {
                          await OfflineSyncService.instance.syncPendingAttempts();
                        }
                        await _loadHistory();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length +
                            (_failedCount > 0 ? 1 : 0) +
                            ((_pendingCount > 0 || _syncedCount > 0) ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          var offset = 0;
                          if (_failedCount > 0) {
                            if (index == 0) {
                              return _FailedUploadBanner(
                                count: _failedCount,
                                onRetry: _retrying ? null : _retryFailedUploads,
                              );
                            }
                            offset++;
                          }
                          if (_pendingCount > 0 || _syncedCount > 0) {
                            if (index == offset) {
                              return _SyncStatusBanner(
                                pending: _pendingCount,
                                synced: _syncedCount,
                                online: ConnectivityService.instance.isOnline,
                              );
                            }
                            offset++;
                          }
                          final item = _items[index - offset];
                          return _HistoryCard(
                            item: item,
                            onTap: () => _openItem(item),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _FailedUploadBanner extends StatelessWidget {
  final int count;
  final VoidCallback? onRetry;

  const _FailedUploadBanner({required this.count, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$count offline test(s) failed to upload.',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SyncStatusBanner extends StatelessWidget {
  final int pending;
  final int synced;
  final bool online;

  const _SyncStatusBanner({
    required this.pending,
    required this.synced,
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (pending > 0) {
      parts.add('$pending pending sync');
    }
    if (synced > 0) {
      parts.add('$synced synced');
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(
            online ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            color: online ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              online
                  ? parts.join(' · ')
                  : 'Offline · ${parts.isEmpty ? 'no local uploads' : parts.join(' · ')}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestHistoryItem {
  final String id;
  final String? localId;
  final String testTitle;
  final DateTime completedAt;
  final double? bandScore;
  final String status;
  final bool isLocalOnly;

  const _TestHistoryItem({
    required this.id,
    this.localId,
    required this.testTitle,
    required this.completedAt,
    this.bandScore,
    required this.status,
    required this.isLocalOnly,
  });
}

class _HistoryCard extends StatelessWidget {
  final _TestHistoryItem item;
  final VoidCallback onTap;

  const _HistoryCard({required this.item, required this.onTap});

  String get _statusLabel {
    switch (item.status) {
      case 'offline_pending':
        return 'Pending sync';
      case 'pending':
        return 'Evaluating';
      case 'uploaded':
        return 'Uploaded · awaiting results';
      case 'failed':
        return 'Upload failed';
      case 'synced':
        return 'Synced';
      case 'completed':
        return 'Completed';
      default:
        return item.status;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (item.status) {
      case 'offline_pending':
      case 'uploaded':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'synced':
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(item.completedAt);

    return Material(
      color: AppTheme.cardBg(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066F5).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment, color: Color(0xFF0066F5)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.testTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(context).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.bandScore != null &&
                  (item.status == 'completed' || item.status == 'synced'))
                Text(
                  item.bandScore!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066F5),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: AppTheme.secondaryText(context)),
            ],
          ),
        ),
      ),
    );
  }
}
