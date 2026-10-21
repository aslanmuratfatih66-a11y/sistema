import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/body/data/body_photos.dart';

PhotoRow _photo(String id, DateTime at, {String? session, PhotoPose pose = PhotoPose.faceFront}) => PhotoRow(
      id: id,
      updatedAt: at,
      deviceId: 'd',
      version: 1,
      kind: PhotoKind.skin.name,
      pose: pose.name,
      localPath: 'photos/skin/$id.jpg',
      takenAt: at,
      sessionId: session,
    );

void main() {
  test('серии раздела', () {
    expect(BodyPhotoSessions.diary(DateTime(2026, 1, 5, 23)), 'diary-20260105');
    expect(BodyPhotoSessions.swelling(DateTime(2026, 10, 21)), 'swelling-20261021');
  });

  test('ленты: дневник без отёков, отёки отдельно, новые сверху; группировка по дням', () {
    final photos = [
      _photo('a', DateTime(2026, 10, 1, 9)), // анкета
      _photo('b', DateTime(2026, 10, 20, 7), session: BodyPhotoSessions.swelling(DateTime(2026, 10, 20))),
      _photo('c', DateTime(2026, 10, 21, 7), session: BodyPhotoSessions.swelling(DateTime(2026, 10, 21))),
      _photo('d', DateTime(2026, 10, 21, 20), session: BodyPhotoSessions.diary(DateTime(2026, 10, 21)), pose: PhotoPose.closeup),
      _photo('e', DateTime(2026, 10, 21, 21), session: BodyPhotoSessions.diary(DateTime(2026, 10, 21))),
    ];
    expect(diaryFeed(photos).map((p) => p.id), ['e', 'd', 'a']);
    expect(swellingFeed(photos).map((p) => p.id), ['c', 'b']);
    final days = groupByDay(diaryFeed(photos));
    expect(days.map((d) => d.$1), [DateTime(2026, 10, 21), DateTime(2026, 10, 1)]);
    expect(days.first.$2.map((p) => p.id), ['e', 'd']);
  });

  test('позы по виду фото', () {
    expect(posesFor(PhotoKind.body), [PhotoPose.bodyFront, PhotoPose.bodySide, PhotoPose.bodyBack]);
    expect(posesFor(PhotoKind.skin), contains(PhotoPose.closeup));
  });
}
