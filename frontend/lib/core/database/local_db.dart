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
      version: 1,
      onCreate: (db, version) async {
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
      },
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
}
