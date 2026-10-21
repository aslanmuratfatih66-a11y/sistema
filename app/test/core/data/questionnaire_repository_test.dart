import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/models/enums.dart';

import '../../helpers/test_db.dart';

void main() {
  test('раздел анкеты: запись, патч, версия растёт', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = QuestionnaireRepository(db);

    expect(await repo.read(QuestionnaireSection.skin), isEmpty);
    await repo.write(QuestionnaireSection.skin, {'oily': true, 'routine': 'нет'});
    await repo.patch(QuestionnaireSection.skin, {'routine': null, 'tight': 2});
    expect(await repo.read(QuestionnaireSection.skin), {'oily': true, 'tight': 2});

    final row = await db.select(db.questionnaireSections).getSingle();
    expect(row.version, 2);
    expect(row.deviceId, await db.deviceId());
  });
}
