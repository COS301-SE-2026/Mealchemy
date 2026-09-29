import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/cook_timer.dart';

abstract class CookTimerStore {
  Future<List<CookTimer>> readAll(int userId);
  Future<void> saveAll(int userId, List<CookTimer> timers);
}

class FileCookTimerStore implements CookTimerStore {
  FileCookTimerStore({Future<Directory> Function()? supportDirectory})
      : _supportDirectory = supportDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _supportDirectory;
  Future<void> _pending = Future<void>.value();

  Future<T> _ordered<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<File> _timerFile(int userId) async {
    final root = await _supportDirectory();
    return File('${root.path}/cook_timers/user_$userId/timers.json');
  }

  @override
  Future<List<CookTimer>> readAll(int userId) => _ordered(() async {
        final file = await _timerFile(userId);
        if (!await file.exists()) return const [];
        final data = jsonDecode(await file.readAsString()) as List<dynamic>;
        return data
            .map((item) => CookTimer.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      });

  @override
  Future<void> saveAll(int userId, List<CookTimer> timers) =>
      _ordered(() async {
        final file = await _timerFile(userId);
        await file.parent.create(recursive: true);
        final temporary = File('${file.path}.tmp');
        await temporary.writeAsString(
          jsonEncode(timers.map((timer) => timer.toJson()).toList()),
          flush: true,
        );
        await temporary.rename(file.path);
      });
}
