import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/photo_repository.dart';

import '../../../helpers/test_db.dart';

void main() {
  late Directory root;

  setUp(() async => root = await Directory.systemTemp.createTemp('qa_photos'));
  tearDown(() async => root.delete(recursive: true));

  var n = 0;
  Future<String> tmpShot() async {
    final f = File(p.join(root.path, 'camera_${n++}.jpg'));
    await f.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);
    return f.path;
  }

  test('относительный путь: photos/<вид>/<uuid>.jpg', () {
    expect(
      PhotoStorage.newRelativePath(PhotoKind.body),
      matches(RegExp(r'^photos/body/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.jpg$')),
    );
    expect(PhotoStorage.newRelativePath(PhotoKind.skin), startsWith('photos/skin/'));
  });

  test('сохранение и пересъёмка позы: старая запись мягко удаляется вместе с файлом', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final storage = PhotoStorage(rootDir: () async => root);
    final repo = PhotoRepository(db);
    final service = PhotoService(repo, storage);

    final id1 = await service.save(sourcePath: await tmpShot(), kind: PhotoKind.body, pose: PhotoPose.bodyFront);
    final first = (await repo.active(PhotoKind.body)).single;
    expect(first.id, id1);
    expect(first.localPath, startsWith('photos/body/'));
    expect(p.isRelative(first.localPath), isTrue);
    final firstFile = await storage.resolve(first.localPath);
    expect(firstFile.existsSync(), isTrue);

    await service.save(sourcePath: await tmpShot(), kind: PhotoKind.body, pose: PhotoPose.bodyFront);
    final active = await repo.active(PhotoKind.body);
    expect(active, hasLength(1));
    expect(active.single.id, isNot(id1));
    final old = await (db.select(db.photos)..where((t) => t.id.equals(id1))).getSingle();
    expect(old.deletedAt, isNotNull);
    expect(old.version, 2);
    expect(firstFile.existsSync(), isFalse);
  });

  test('крупные планы без замены копятся; другие позы не трогаются', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final service = PhotoService(PhotoRepository(db), PhotoStorage(rootDir: () async => root));

    await service.save(sourcePath: await tmpShot(), kind: PhotoKind.skin, pose: PhotoPose.faceFront);
    await service.save(sourcePath: await tmpShot(), kind: PhotoKind.skin, pose: PhotoPose.closeup, replace: false);
    await service.save(sourcePath: await tmpShot(), kind: PhotoKind.skin, pose: PhotoPose.closeup, replace: false);

    final active = await service.repo.active(PhotoKind.skin);
    expect(active.where((r) => r.pose == PhotoPose.closeup.name), hasLength(2));
    expect(active.where((r) => r.pose == PhotoPose.faceFront.name), hasLength(1));

    await service.delete(active.last);
    expect(await service.repo.active(PhotoKind.skin), hasLength(2));
  });
}
