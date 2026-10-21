import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

/// Язык интерфейса из профиля (Profiles.locale). null — язык системы.
/// Шаг «Профиль» и настройки меняют язык записью в Profiles.locale — приложение подхватит само.
final appLocaleProvider = StreamProvider<Locale?>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.profiles)..where((t) => t.deletedAt.isNull()))
      .watch()
      .map((rows) {
        final code = rows.isEmpty ? null : rows.first.locale;
        return code == null || code.isEmpty ? null : Locale(code);
      });
});
