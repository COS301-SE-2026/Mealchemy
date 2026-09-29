import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/cook_session.dart';

abstract class CookSessionStore {
  Future<CookSession?> read(int userId, int recipeId);
  Future<CookSession?> latest(int userId);
  Future<void> save(int userId, CookSession session);
  Future<void> remove(int userId, int recipeId);
}

class FileCookSessionStore implements CookSessionStore {
  FileCookSessionStore({Future<Directory> Function()? supportDirectory})
      : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirectory;
  Future<void> _pending = Future<void>.value();

  Future<T> _ordered<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<Directory> _userDirectory(int userId) async {
    final root = await _supportDirectory();
    return Directory('${root.path}/cook_sessions/user_$userId');
  }

  Future<File> _sessionFile(int userId, int recipeId) async {
    final directory = await _userDirectory(userId);
    return File('${directory.path}/recipe_$recipeId.json');
  }

  Future<CookSession> _readFile(File file) async {
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return CookSession.fromJson(data);
  }

  @override
  Future<CookSession?> read(int userId, int recipeId) => _ordered(() async {
        final file = await _sessionFile(userId, recipeId);
        if (!await file.exists()) return null;
        return _readFile(file);
      });

  @override
  Future<CookSession?> latest(int userId) => _ordered(() async {
        final directory = await _userDirectory(userId);
        if (!await directory.exists()) return null;

        CookSession? newest;
        await for (final entry in directory.list()) {
          if (entry is! File || !entry.path.endsWith('.json')) continue;
          final session = await _readFile(entry);
          if (newest == null || session.savedAt.isAfter(newest.savedAt)) {
            newest = session;
          }
        }
        return newest;
      });

  @override
  Future<void> save(int userId, CookSession session) => _ordered(() async {
        final file = await _sessionFile(userId, session.recipeId);
        await file.parent.create(recursive: true);
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsString(jsonEncode(session.toJson()),
            flush: true);
        await temporary.rename(file.path);
      });

  @override
  Future<void> remove(int userId, int recipeId) => _ordered(() async {
        final file = await _sessionFile(userId, recipeId);
        if (await file.exists()) await file.delete();
      });
}
