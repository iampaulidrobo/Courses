import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/session_meta.dart';
import '../models/session_stats.dart';
import '../models/session_summary.dart';

class SessionStore {
  final String userScopeId;

  SessionStore(this.userScopeId);

  String _safe(String value) => value.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  String _safeFolderName(String input) {
    final clean = input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return clean.isEmpty ? 'session_${DateTime.now().millisecondsSinceEpoch}' : clean;
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<Directory> _root() async {
    final docs = await getApplicationDocumentsDirectory();
    final root = Directory(
      p.join(docs.path, 'KalLog', 'users', _safe(userScopeId), 'sessions'),
    );
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  DateTime? _parseDayFromFileName(String pathOrName) {
    final base = p.basenameWithoutExtension(pathOrName);
    final first = base.split('_').first;
    try {
      final parsed = DateTime.parse(first);
      return _dayOnly(parsed);
    } catch (_) {
      return null;
    }
  }

  int _currentStreak(List<DateTime> days) {
    if (days.isEmpty) return 0;
    var streak = 1;
    for (var i = days.length - 1; i > 0; i--) {
      final current = _dayOnly(days[i]);
      final previous = _dayOnly(days[i - 1]);
      if (current.difference(previous).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int _longestStreak(List<DateTime> days) {
    if (days.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < days.length; i++) {
      final prev = _dayOnly(days[i - 1]);
      final now = _dayOnly(days[i]);
      if (now.difference(prev).inDays == 1) {
        current++;
      } else {
        if (current > longest) longest = current;
        current = 1;
      }
    }
    return current > longest ? current : longest;
  }

  Future<List<SessionSummary>> listSessions() async {
    final root = await _root();
    final sessions = <SessionSummary>[];

    for (final entity in root.listSync()) {
      if (entity is! Directory) continue;
      final metaFile = File(p.join(entity.path, 'session.json'));
      if (!await metaFile.exists()) continue;

      try {
        final raw = await metaFile.readAsString();
        final meta = SessionMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        final videos = entity
            .listSync()
            .whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.mp4'))
            .length;

        sessions.add(SessionSummary(
          meta: meta,
          path: entity.path,
          videoCount: videos,
        ));
      } catch (_) {
        continue;
      }
    }

    sessions.sort((a, b) => b.meta.createdAt.compareTo(a.meta.createdAt));
    return sessions;
  }

  Future<SessionStats> sessionStats(SessionSummary session) async {
    final grouped = await groupedVideos(session);
    final days = grouped.keys.map(_dayOnly).toList()..sort();
    final totalVideos = grouped.values.fold<int>(0, (sum, files) => sum + files.length);

    return SessionStats(
      totalVideos: totalVideos,
      recordedDays: days.length,
      currentStreak: _currentStreak(days),
      longestStreak: _longestStreak(days),
    );
  }

  Future<void> createSession({
    required String name,
    required int durationSeconds,
    required int maxRecordings,
  }) async {
    final root = await _root();
    var folderName = _safeFolderName(name);
    var dir = Directory(p.join(root.path, folderName));
    var counter = 1;
    while (await dir.exists()) {
      folderName = '${_safeFolderName(name)}_$counter';
      dir = Directory(p.join(root.path, folderName));
      counter++;
    }

    await dir.create(recursive: true);

    final meta = SessionMeta(
      name: name,
      durationSeconds: durationSeconds,
      maxRecordings: maxRecordings,
      createdAt: DateTime.now(),
      folderName: folderName,
    );

    await File(p.join(dir.path, 'session.json')).writeAsString(jsonEncode(meta.toJson()));
  }

  Future<void> renameSession(SessionSummary session, String newName) async {
    final root = await _root();
    var newFolder = _safeFolderName(newName);
    var newDir = Directory(p.join(root.path, newFolder));
    var counter = 1;
    while (await newDir.exists()) {
      newFolder = '${_safeFolderName(newName)}_$counter';
      newDir = Directory(p.join(root.path, newFolder));
      counter++;
    }

    final oldDir = Directory(session.path);
    await oldDir.rename(newDir.path);

    final updated = SessionMeta(
      name: newName,
      durationSeconds: session.meta.durationSeconds,
      maxRecordings: session.meta.maxRecordings,
      createdAt: session.meta.createdAt,
      folderName: newFolder,
    );
    await File(p.join(newDir.path, 'session.json')).writeAsString(jsonEncode(updated.toJson()));
  }

  Future<void> deleteSession(SessionSummary session) async {
    final dir = Directory(session.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<int> totalVideos(SessionSummary session) async {
    final dir = Directory(session.path);
    if (!await dir.exists()) return 0;
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mp4'))
        .length;
  }

  Future<Map<DateTime, List<File>>> groupedVideos(SessionSummary session) async {
    final dir = Directory(session.path);
    final map = <DateTime, List<File>>{};
    if (!await dir.exists()) return map;

    for (final entity in dir.listSync()) {
      if (entity is! File || !entity.path.toLowerCase().endsWith('.mp4')) continue;
      final day = _parseDayFromFileName(entity.path);
      if (day == null) continue;
      map.putIfAbsent(day, () => []);
      map[day]!.add(entity);
    }

    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.path.compareTo(b.path));
    }

    return map;
  }

  Future<List<File>> videosForDay(SessionSummary session, DateTime day) async {
    final grouped = await groupedVideos(session);
    return grouped[_dayOnly(day)] ?? [];
  }

  Future<String> nextRecordingPath(SessionSummary session, DateTime day) async {
    final dir = Directory(session.path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir.path, '${_dateKey(day)}_$timestamp.mp4');
  }
}
