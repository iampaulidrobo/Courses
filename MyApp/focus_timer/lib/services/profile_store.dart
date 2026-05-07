import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/local_user.dart';

class ProfileStore {
  static Future<Directory> _baseDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final base = Directory(p.join(docs.path, 'KalLog'));
    if (!await base.exists()) {
      await base.create(recursive: true);
    }
    return base;
  }

  static Future<File> _profileFile() async {
    final base = await _baseDir();
    return File(p.join(base.path, '.profile.json'));
  }

  static Future<LocalUser?> loadUser() async {
    try {
      final file = await _profileFile();
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return LocalUser.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(LocalUser user) async {
    final file = await _profileFile();
    await file.writeAsString(jsonEncode(user.toJson()));
  }

  static Future<void> clearUser() async {
    try {
      final file = await _profileFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
