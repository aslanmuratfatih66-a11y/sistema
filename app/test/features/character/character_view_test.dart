import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/character/art/character_pose.dart';
import 'package:sistema/features/character/character_view.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(textDirection: TextDirection.ltr, child: Center(child: child)),
    );

void main() {
  testWidgets('все 8 состояний рисуются для всех 4 архетипов', (tester) async {
    for (final a in CharacterArchetype.values) {
      for (final s in CharacterState.values) {
        for (final left in [false, true]) {
          await tester.pumpWidget(_host(CharacterView(archetype: a, state: s, height: 120, facingLeft: left)));
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 1300));
          expect(tester.takeException(), isNull, reason: '$a/$s');
        }
      }
    }
    final size = tester.getSize(find.byType(CharacterView));
    expect(size, const Size(72, 120));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('плавный переход между состояниями без исключений', (tester) async {
    var state = CharacterState.idle;
    late StateSetter set;
    await tester.pumpWidget(_host(StatefulBuilder(builder: (context, s) {
      set = s;
      return CharacterView(archetype: CharacterArchetype.grimSwordsman, state: state);
    })));
    for (final next in [CharacterState.happy, CharacterState.sleep, CharacterState.angry, CharacterState.walk]) {
      set(() => state = next);
      await tester.pump(const Duration(milliseconds: 100)); // середина перехода
      set(() => state = CharacterState.point); // смена во время перехода
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('«Уменьшение движения» — статичная поза, без кадров анимации', (tester) async {
    await tester.pumpWidget(_host(
      const CharacterView(archetype: CharacterArchetype.animeGirl, state: CharacterState.walk),
      reduceMotion: true,
    ));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  test('поза: lerp на концах и статичная фаза', () {
    final a = CharacterPose.forState(CharacterState.idle, 0);
    final b = CharacterPose.forState(CharacterState.sleep, 0);
    expect(CharacterPose.lerp(a, b, 0).sit, a.sit);
    expect(CharacterPose.lerp(a, b, 1).sit, b.sit);
    expect(CharacterPose.lerp(a, b, .5).sit, closeTo(.5, 1e-9));
    expect(b.eyeOpen, 0);
    expect(b.zzz, 1);
    expect(CharacterPose.forState(CharacterState.angry, 0).brow, 1);
    expect(CharacterPose.forState(CharacterState.point, 0).pointR, 1);
    expect(CharacterPose.forState(CharacterState.idle, 0).eyeOpen, 1);
  });
}
