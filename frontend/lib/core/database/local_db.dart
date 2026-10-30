import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'testiva_offline.db'),
      version: 5,
      onCreate: (db, version) async {
        await _createV1Tables(db);
        await _createAudioCacheTable(db);
        await _createInProgressDraftsTable(db);
        await _createPrepCacheTables(db);
        await _createCommunityDraftsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAudioCacheTable(db);
        }
        if (oldVersion < 3) {
          await _createInProgressDraftsTable(db);
        }
        if (oldVersion < 4) {
          await _createPrepCacheTables(db);
        }
        if (oldVersion < 5) {
          await _createCommunityDraftsTable(db);
        }
      },
    );
  }

  // This is a comment: offline prep lesson cache
  Future<void> _createPrepCacheTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_prep_lessons (
        cache_key TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_prep_details (
        prep_id TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCommunityDraftsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS community_draft_posts (
        local_id TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> cachePrepLessons({
    required String cacheKey,
    required List items,
  }) async {
    final db = await database;
    await db.insert(
      'cached_prep_lessons',
      {
        'cache_key': cacheKey,
        'payload_json': jsonEncode(items),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List?> getCachedPrepLessons(String cacheKey) async {
    final db = await database;
    final rows = await db.query(
      'cached_prep_lessons',
      where: 'cache_key = ?',
      whereArgs: [cacheKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.first['payload_json'] as String);
    return decoded is List ? decoded : null;
  }

  Future<void> cachePrepDetail({
    required String prepId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert(
      'cached_prep_details',
      {
        'prep_id': prepId,
        'payload_json': jsonEncode(payload),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedPrepDetail(String prepId) async {
    final db = await database;
    final rows = await db.query(
      'cached_prep_details',
      where: 'prep_id = ?',
      whereArgs: [prepId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(rows.first['payload_json'] as String);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : null;
  }

  Future<void> saveCommunityDraft({
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert(
      'community_draft_posts',
      {
        'local_id': localId,
        'payload_json': jsonEncode(payload),
        'sync_status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPendingCommunityDrafts() async {
    final db = await database;
    return db.query(
      'community_draft_posts',
      where: "sync_status = 'pending'",
      orderBy: 'created_at ASC',
    );
  }

  Future<void> markCommunityDraftSynced(String localId) async {
    final db = await database;
    await db.delete(
      'community_draft_posts',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> _createV1Tables(Database db) async {
    await db.execute('''
      CREATE TABLE cached_tests (
        test_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL DEFAULT 60,
        payload_json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE cached_mock_dashboard (
        exam_type TEXT PRIMARY KEY,
        payload_json TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE offline_attempts (
        local_id TEXT PRIMARY KEY,
        test_id TEXT NOT NULL,
        test_title TEXT NOT NULL,
        exam_type TEXT,
        client_started_at TEXT NOT NULL,
        client_completed_at TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        server_attempt_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAudioCacheTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cached_audio (
        remote_url TEXT PRIMARY KEY,
        local_path TEXT NOT NULL,
        test_id TEXT,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createInProgressDraftsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS in_progress_drafts (
        draft_key TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        test_id TEXT NOT NULL,
        attempt_local_id TEXT NOT NULL,
        current_index INTEGER NOT NULL DEFAULT 0,
        section_index INTEGER NOT NULL DEFAULT 0,
        remaining_seconds INTEGER NOT NULL DEFAULT 0,
        answers_json TEXT NOT NULL,
        started_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  /// Mid-test answer persistence (local-only; does not touch offline sync flags).
  Future<void> saveInProgressDraft({
    required String draftKey,
    required String userId,
    required String testId,
    required String attemptLocalId,
    required int currentIndex,
    required int sectionIndex,
    required int remainingSeconds,
    required Map<String, dynamic> answers,
    required String startedAt,
  }) async {
    final db = await database;
    await db.insert(
      'in_progress_drafts',
      {
        'draft_key': draftKey,
        'user_id': userId,
        'test_id': testId,
        'attempt_local_id': attemptLocalId,
        'current_index': currentIndex,
        'section_index': sectionIndex,
        'remaining_seconds': remainingSeconds,
        'answers_json': jsonEncode(answers),
        'started_at': startedAt,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getInProgressDraft(String draftKey) async {
    final db = await database;
    final rows = await db.query(
      'in_progress_drafts',
      where: 'draft_key = ?',
      whereArgs: [draftKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return {
      'draft_key': row['draft_key'],
      'user_id': row['user_id'],
      'test_id': row['test_id'],
      'attempt_local_id': row['attempt_local_id'],
      'current_index': row['current_index'],
      'section_index': row['section_index'],
      'remaining_seconds': row['remaining_seconds'],
      'answers': jsonDecode(row['answers_json'] as String),
      'started_at': row['started_at'],
      'updated_at': row['updated_at'],
    };
  }

  Future<void> clearInProgressDraft(String draftKey) async {
    final db = await database;
    await db.delete(
      'in_progress_drafts',
      where: 'draft_key = ?',
      whereArgs: [draftKey],
    );
  }

  Future<void> cacheTestRuntime({
    required String testId,
    required String title,
    required int durationMinutes,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert(
      'cached_tests',
      {
        'test_id': testId,
        'title': title,
        'duration_minutes': durationMinutes,
        'payload_json': jsonEncode(payload),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getCachedTestRuntime(String testId) async {
    final db = await database;
    final rows = await db.query(
      'cached_tests',
      where: 'test_id = ?',
      whereArgs: [testId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return {
      'title': row['title'],
      'duration_minutes': row['duration_minutes'],
      'data': jsonDecode(row['payload_json'] as String) as Map<String, dynamic>,
    };
  }

  // clean and optimized code — listening audio for offline playback
  Future<void> saveCachedAudio({
    required String remoteUrl,
    required String localPath,
    String? testId,
  }) async {
    final db = await database;
    await db.insert(
      'cached_audio',
      {
        'remote_url': remoteUrl,
        'local_path': localPath,
        'test_id': testId,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getCachedAudioPath(String remoteUrl) async {
    final db = await database;
    final rows = await db.query(
      'cached_audio',
      where: 'remote_url = ?',
      whereArgs: [remoteUrl],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['local_path']?.toString();
  }

  Future<void> cacheMockDashboard({
    required String examType,
    required List<dynamic> items,
  }) async {
    final db = await database;
    await db.insert(
      'cached_mock_dashboard',
      {
        'exam_type': examType,
        'payload_json': jsonEncode(items),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>?> getCachedMockDashboard(String examType) async {
    final db = await database;
    final rows = await db.query(
      'cached_mock_dashboard',
      where: 'exam_type = ?',
      whereArgs: [examType],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final list = jsonDecode(rows.first['payload_json'] as String) as List;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<String> saveOfflineAttempt({
    required String localId,
    required String testId,
    required String testTitle,
    String? examType,
    required String clientStartedAt,
    required String clientCompletedAt,
    required Map<String, dynamic> payload,
  }) async {
    final db = await database;
    await db.insert('offline_attempts', {
      'local_id': localId,
      'test_id': testId,
      'test_title': testTitle,
      'exam_type': examType,
      'client_started_at': clientStartedAt,
      'client_completed_at': clientCompletedAt,
      'payload_json': jsonEncode(payload),
      'sync_status': 'pending',
      'server_attempt_id': null,
      'created_at': DateTime.now().toIso8601String(),
    });
    return localId;
  }

  Future<List<Map<String, dynamic>>> getPendingAttempts() async {
    final db = await database;
    return db.query(
      'offline_attempts',
      where: "sync_status = 'pending'",
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllLocalAttempts() async {
    final db = await database;
    return db.query('offline_attempts', orderBy: 'created_at DESC');
  }

  Future<void> markAttemptUploaded(String localId) async {
    final db = await database;
    await db.update(
      'offline_attempts',
      {'sync_status': 'uploaded'},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markAttemptSynced({
    required String localId,
    required String serverAttemptId,
  }) async {
    final db = await database;
    await db.update(
      'offline_attempts',
      {
        'sync_status': 'synced',
        'server_attempt_id': serverAttemptId,
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markAttemptFailed(String localId) async {
    final db = await database;
    await db.update(
      'offline_attempts',
      {'sync_status': 'failed'},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<Map<String, dynamic>?> getAttemptByLocalId(String localId) async {
    final db = await database;
    final rows = await db.query(
      'offline_attempts',
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<List<Map<String, dynamic>>> getFailedAttempts() async {
    final db = await database;
    return db.query(
      'offline_attempts',
      where: "sync_status = 'failed'",
      orderBy: 'created_at DESC',
    );
  }

  Future<void> resetFailedAttempts() async {
    final db = await database;
    await db.update(
      'offline_attempts',
      {'sync_status': 'pending'},
      where: "sync_status = 'failed'",
    );
  }

  /// Drop cached dashboards / runtimes the user is no longer allowed to access.
  Future<void> purgeDisallowedCaches({
    required bool canIelts,
    required bool canPte,
  }) async {
    final db = await database;
    if (!canIelts) {
      await db.delete(
        'cached_mock_dashboard',
        where: 'exam_type = ?',
        whereArgs: ['IELTS'],
      );
    }
    if (!canPte) {
      await db.delete(
        'cached_mock_dashboard',
        where: 'exam_type = ?',
        whereArgs: ['PTE'],
      );
    }
    if (!canIelts || !canPte) {
      await db.delete(
        'cached_mock_dashboard',
        where: 'exam_type = ?',
        whereArgs: ['ALL'],
      );
    }
  }

  Future<Map<String, int>> getSyncStatusCounts() async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT sync_status, COUNT(*) AS c
      FROM offline_attempts
      GROUP BY sync_status
      ''',
    );
    final counts = <String, int>{
      'pending': 0,
      'uploaded': 0,
      'synced': 0,
      'failed': 0,
    };
    for (final row in rows) {
      final key = row['sync_status']?.toString() ?? '';
      counts[key] = (row['c'] as int?) ?? 0;
    }
    return counts;
  }
}
