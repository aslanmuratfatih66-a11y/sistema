import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/voice/tts_service.dart';
import 'package:sistema/features/workouts/domain/workout_runner.dart';
import 'package:sistema/features/workouts/domain/workout_voice.dart';
import 'package:sistema/features/workouts/model/workout_program.dart';
import 'package:sistema/features/workouts/wrk_l10n.dart';
import 'package:sistema/l10n/app_localizations.dart';

import 'fakes.dart';

void main() {
  late AppLocalizations ru;
  late AppLocalizations tr;

  setUpAll(() async {
    ru = await AppLocalizations.delegate.load(const Locale('ru'));
    tr = await AppLocalizations.delegate.load(const Locale('tr'));
  });

  test('фразы по событиям тренировки (ru)', () {
    final p = L10nWorkoutPhrases(ru);
    const squat = ProgramExercise(exerciseKey: 'squat', sets: 3, reps: 12, restSeconds: 45);
    const plank = ProgramExercise(exerciseKey: 'plank', sets: 2, seconds: 30, restSeconds: 45);
    expect(p.phrase(const CuePrepare('squat')), 'Приготовьтесь. Приседания.');
    expect(p.phrase(const CueWorkStart(WorkoutStep(block: 0, item: squat, set: 2))),
        'Подход 2 из 3. 12 повторов. Начали!');
    expect(p.phrase(const CueWorkStart(WorkoutStep(block: 1, item: plank, set: 1))),
        'Подход 1 из 2. 30 секунд. Начали!');
    expect(p.phrase(const CueCountdown(3)), '3');
    expect(p.phrase(const CueRest(45)), 'Отдых: 45 секунд.');
    expect(p.phrase(const CueRest(21, nextExerciseKey: 'plank')), 'Отдых: 21 секунда. Далее: Планка.');
    expect(p.phrase(const CueFinished()), 'Тренировка завершена. Отличная работа!');
  });

  test('турецкий и неизвестное упражнение', () {
    final p = L10nWorkoutPhrases(tr);
    expect(p.phrase(const CuePrepare('plank')), 'Hazırlan. Plank.');
    expect(exerciseName(tr, 'aiCustomMove'), 'aiCustomMove');
    expect(exerciseHint(ru, 'aiCustomMove'), '');
    expect(exerciseHint(ru, 'squat').split('\n').length, 3);
  });

  test('озвучка: голос ассистента, язык; во время тренировки — только на события', () async {
    final tts = FakeTts();
    const voice = VoiceProfile(id: 'animeGirl.soft', pitch: 1.2);
    final v = WorkoutVoice(tts: tts, phrases: L10nWorkoutPhrases(ru), languageCode: 'ru', voice: voice);
    final clock = FakeClock(DateTime(2026, 10, 21, 18));
    final ticker = ManualTicker();
    final r = WorkoutRunner(
      exercises: const [ProgramExercise(exerciseKey: 'plank', sets: 1, seconds: 10, restSeconds: 0)],
      clock: clock.call,
      ticker: ticker,
      onCue: v.onCue,
      prepareSeconds: 5,
    )..start();
    // 15 секунд тиками по 200 мс — 75 тиков, но фраз только по событиям.
    for (var i = 0; i < 75; i++) {
      clock.advance(const Duration(milliseconds: 200));
      ticker.tick();
    }
    await Future<void>.delayed(Duration.zero);
    expect(r.phase, WorkoutPhase.finished);
    expect(tts.spoken, [
      'Приготовьтесь. Планка.', '3', '2', '1',
      'Подход 1 из 1. 10 секунд. Начали!', '3', '2', '1',
      'Тренировка завершена. Отличная работа!',
    ]);
    expect(tts.voices.toSet(), {voice});
    expect(tts.languages.toSet(), {'ru'});
    expect(tts.stops, 0, reason: 'stop не вызывается без нужды');
  });

  test('выключенный голос молчит; silence — stop только если фраза звучит', () async {
    final tts = _SlowTts();
    final v = WorkoutVoice(tts: tts, phrases: L10nWorkoutPhrases(ru), languageCode: 'ru', enabled: false);
    v.onCue(const CueFinished());
    expect(tts.spoken, isEmpty);
    await v.silence();
    expect(tts.stops, 0);

    v.enabled = true;
    v.onCue(const CueCountdown(2));
    expect(v.speaking, isTrue);
    await v.silence();
    expect(tts.stops, 1);
    expect(v.speaking, isFalse);
  });
}

/// Фраза «звучит», пока не вызван stop.
class _SlowTts extends FakeTts {
  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) {
    spoken.add(text);
    return Future<void>.delayed(const Duration(seconds: 5));
  }
}
