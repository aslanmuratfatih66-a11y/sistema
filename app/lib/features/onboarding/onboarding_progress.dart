import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import 'onboarding_step.dart';

/// Прогресс анкеты: текущий этап и признак завершения. Хранится в AppSettings,
/// чтобы можно было прерваться и продолжить (SPEC §5). Слушается роутером (redirect).
class OnboardingProgress extends ChangeNotifier {
  OnboardingProgress._(this._db, {required this._completed, required this._stepIndex, required this._introSeen});

  /// Без БД — для тестов.
  @visibleForTesting
  OnboardingProgress.memory({this._completed = false, this._stepIndex = 0, this._introSeen = false}) : _db = null;

  static const completedKey = 'onboarding.completed';
  static const stepKey = 'onboarding.step';
  static const introSeenKey = 'onboarding.introSeen';

  static Future<OnboardingProgress> load(AppDatabase db) async {
    final completed = await db.getSetting(completedKey) == '1';
    final step = int.tryParse(await db.getSetting(stepKey) ?? '') ?? 0;
    return OnboardingProgress._(db,
        completed: completed,
        stepIndex: step.clamp(0, OnboardingStep.values.length - 1),
        introSeen: await db.getSetting(introSeenKey) == '1');
  }

  final AppDatabase? _db;
  bool _completed;
  int _stepIndex;
  bool _introSeen;

  /// Окно «[ Уведомление ] Вы получили право стать Игроком…» уже принято.
  bool get introSeen => _introSeen;

  bool get completed => _completed;
  int get stepIndex => _stepIndex;
  OnboardingStep get step => OnboardingStep.values[_stepIndex];

  Future<void> goTo(int index) async {
    _stepIndex = index.clamp(0, OnboardingStep.values.length - 1);
    notifyListeners();
    await _db?.setSetting(stepKey, '$_stepIndex');
  }

  Future<void> acceptIntro() async {
    _introSeen = true;
    notifyListeners();
    await _db?.setSetting(introSeenKey, '1');
  }

  Future<void> complete() async {
    _completed = true;
    notifyListeners();
    await _db?.setSetting(completedKey, '1');
  }

  /// Пройти анкету заново (из настроек). Данные не удаляются.
  Future<void> restart() async {
    _completed = false;
    _stepIndex = 0;
    notifyListeners();
    await _db?.setSetting(completedKey, '0');
    await _db?.setSetting(stepKey, '0');
  }
}

/// Переопределяется в main после загрузки из БД.
final onboardingProgressProvider = Provider<OnboardingProgress>(
  (ref) => throw UnimplementedError('onboardingProgressProvider не переопределён'),
);
