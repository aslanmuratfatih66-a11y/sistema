import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sistema/core/db/database.dart';

/// БД в памяти для тестов. Не забыть `addTearDown(db.close)`.
AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
