import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/notifications/notification_api.dart';
import 'package:sistema/core/notifications/reminder_prefs_repository.dart';

import '../../helpers/test_db.dart';

void main() {
  test('по умолчанию — значения контракта', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final p = await ReminderPrefsRepository(db).load();
    expect(p.enabled, isTrue);
    expect(p.nag, isTrue);
    expect(p.reproach, isTrue);
    expect(p.voiceSound, isFalse);
    expect(p.quiet, isNull);
  });

  test('сохранение и чтение, тихие часы, перезапись', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = ReminderPrefsRepository(db);
    await repo.save(const ReminderPrefs(nag: false, voiceSound: true, quiet: defaultQuietHours));
    var p = await repo.load();
    expect(p.nag, isFalse);
    expect(p.voiceSound, isTrue);
    expect(p.quiet?.startMinute, 23 * 60);
    expect(p.quiet?.endMinute, 7 * 60);
    await repo.save(copyReminderPrefs(p, clearQuiet: true, enabled: false));
    p = await repo.load();
    expect(p.quiet, isNull);
    expect(p.enabled, isFalse);
    final row = await (db.select(db.userSettings)..where((t) => t.id.equals(reminderPrefsSettingId))).getSingle();
    expect(row.version, 2);
  });

  test('битый JSON — значения по умолчанию', () {
    expect(reminderPrefsFromJson('x').enabled, isTrue);
    final p = reminderPrefsFromJson({
      'nag': 'yes',
      'quiet': {'start': 5000, 'end': 1},
    });
    expect(p.nag, isTrue);
    expect(p.quiet, isNull);
    final back = reminderPrefsFromJson(reminderPrefsToJson(
      const ReminderPrefs(reproach: false, quiet: QuietHours(startMinute: 60, endMinute: 120)),
    ));
    expect(back.reproach, isFalse);
    expect(back.quiet?.endMinute, 120);
  });
}
