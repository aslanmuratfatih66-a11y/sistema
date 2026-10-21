import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/voice/tts_service.dart';
import 'capture_guide.dart';

/// Ракурс фото-сессии.
class SessionShot {
  const SessionShot(this.pose, this.guide);

  final PhotoPose pose;
  final CaptureGuide guide;

  static const body = [
    SessionShot(PhotoPose.bodyFront, CaptureGuide.bodyFront),
    SessionShot(PhotoPose.bodySide, CaptureGuide.bodySide),
    SessionShot(PhotoPose.bodyBack, CaptureGuide.bodyBack),
  ];

  static const face = [
    SessionShot(PhotoPose.faceFront, CaptureGuide.faceFront),
    SessionShot(PhotoPose.faceLeft, CaptureGuide.faceLeft),
    SessionShot(PhotoPose.faceRight, CaptureGuide.faceRight),
  ];
}

/// Фразы сессии (текст на экране и голос). В приложении — из AppLocalizations, в тестах — фейк.
abstract interface class SessionPhrases {
  /// Инструкция ракурса («Отойди на ~2 м и встань в контур лицом к камере»). [first] — первый в серии.
  String instruction(SessionShot shot, {required bool first});

  /// Число обратного отсчёта (последние 3 секунды).
  String count(int n);

  /// «Снимок сделан. Следующий: …» ([next] == null — серия закончена).
  String taken(SessionShot? next);

  /// Не удалось сделать снимок.
  String failed();
}

/// Источник снимков (камера). Возвращает путь к временному файлу или null при ошибке.
abstract interface class ShotSource {
  Future<String?> capture();

  /// Удалить ненужный временный файл.
  Future<void> discard(String path);
}

enum SessionPhase {
  /// Экран подготовки: настройки, «Начать».
  preparing,

  /// Звучит инструкция ракурса.
  instruction,

  /// Идёт обратный отсчёт ([GuidedSessionController.remaining]).
  countdown,

  /// Отсчёт выключен (снимает другой человек) — ждём кнопку.
  waitingShutter,

  /// Снимок делается.
  capturing,

  /// Снимок сделан, «Следующий: …», пауза перед следующим.
  captured,

  /// Снимок не удался — можно повторить ([GuidedSessionController.retry]).
  failed,

  /// Все ракурсы сняты — просмотр.
  review,

  /// Сессия отменена.
  cancelled,
}

/// Логика фото-сессии «под руководством Системы» без камеры и UI:
/// подготовка → (инструкция → отсчёт → снимок → «следующий») × N → обзор; переснять один ракурс; пауза; отмена.
class GuidedSessionController extends ChangeNotifier {
  GuidedSessionController({
    required this.shots,
    required this.source,
    required this.tts,
    required this.phrases,
    required this.languageCode,
    this.voice,
    int countdownSeconds = 10,
    this.onTick,
    this.onCaptured,
    Future<void> Function(Duration)? wait,
    this.betweenShots = const Duration(seconds: 2),
    this.speakTimeout = const Duration(seconds: 10),
  })  : _countdown = countdownSeconds,
        _wait = wait ?? ((d) => Future<void>.delayed(d)),
        _results = List<String?>.filled(shots.length, null);

  final List<SessionShot> shots;
  final ShotSource source;
  final TtsService tts;
  final SessionPhrases phrases;
  final String languageCode;

  /// Голос выбранного персонажа (null — голос по умолчанию). Можно задать после создания.
  VoiceProfile? voice;

  /// Каждая секунда отсчёта (звук/вибро). Аргумент — сколько секунд осталось.
  final void Function(int remaining)? onTick;

  /// Снимок сделан (вспышка-подтверждение).
  final void Function()? onCaptured;

  final Duration betweenShots;
  final Duration speakTimeout;
  final Future<void> Function(Duration) _wait;

  int _countdown;
  final List<String?> _results;
  SessionPhase _phase = SessionPhase.preparing;
  bool _paused = false;
  int _index = 0;
  int _remaining = 0;
  String _caption = '';
  bool _speaking = false;

  /// Сейчас звучит фраза (персонаж на экране «говорит»).
  bool get speaking => _speaking;

  /// Очередь ракурсов текущего прогона (вся серия или один при «переснять»).
  List<int> _queue = const [];
  int _queuePos = 0;

  /// Поколение прогона: пауза/отмена/переснять увеличивают его, и устаревшие await-цепочки выходят.
  int _gen = 0;
  bool _disposed = false;

  SessionPhase get phase => _phase;
  bool get paused => _paused;

  /// Индекс текущего ракурса в [shots].
  int get index => _index;
  SessionShot get current => shots[_index];

  /// Секунд до снимка (во время отсчёта).
  int get remaining => _remaining;

  /// Текст на экране (последняя инструкция/фраза).
  String get caption => _caption;

  /// 0 — отсчёт выключен, снимок по кнопке.
  int get countdownSeconds => _countdown;
  set countdownSeconds(int v) {
    _countdown = v < 0 ? 0 : v;
    _notify();
  }

  /// Пути снимков по ракурсам (null — ещё не снят).
  List<String?> get results => List.unmodifiable(_results);

  bool get running => switch (_phase) {
        SessionPhase.instruction ||
        SessionPhase.countdown ||
        SessionPhase.waitingShutter ||
        SessionPhase.capturing ||
        SessionPhase.captured ||
        SessionPhase.failed =>
          true,
        _ => false,
      };

  /// Начать серию со всех ракурсов.
  void start() {
    if (_phase != SessionPhase.preparing) return;
    _runQueue([for (var i = 0; i < shots.length; i++) i]);
  }

  /// Переснять один ракурс (из обзора).
  void retake(int i) {
    if (_phase != SessionPhase.review || i < 0 || i >= shots.length) return;
    _runQueue([i]);
  }

  /// Повторить текущий ракурс после ошибки.
  void retry() {
    if (_phase != SessionPhase.failed) return;
    _runQueue(_queue, from: _queuePos);
  }

  /// Пауза: прерывает отсчёт и речь; [resume] начинает текущий ракурс заново.
  void pause() {
    if (!running || _paused) return;
    _gen++;
    _paused = true;
    unawaited(tts.stop());
    _notify();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _runQueue(_queue, from: _queuePos);
  }

  /// Снимок по кнопке (режим без отсчёта).
  void shutter() {
    if (_phase != SessionPhase.waitingShutter || _paused) return;
    final gen = ++_gen;
    unawaited(_captureCurrent(gen));
  }

  /// Отмена сессии: временные файлы удаляются.
  Future<void> cancel() async {
    _gen++;
    _paused = false;
    _phase = SessionPhase.cancelled;
    unawaited(tts.stop());
    _notify();
    for (var i = 0; i < _results.length; i++) {
      final r = _results[i];
      _results[i] = null;
      if (r != null) await source.discard(r);
    }
  }

  /// Завершить из обзора: снятые пути (ракурс → путь). Файлы теперь принадлежат вызывающему.
  Map<PhotoPose, String> takeResults() {
    final out = <PhotoPose, String>{
      for (var i = 0; i < shots.length; i++)
        if (_results[i] != null) shots[i].pose: _results[i]!,
    };
    for (var i = 0; i < _results.length; i++) {
      _results[i] = null;
    }
    return out;
  }

  // ---- прогон ----

  void _runQueue(List<int> queue, {int from = 0}) {
    _queue = queue;
    _queuePos = from;
    _paused = false;
    final gen = ++_gen;
    unawaited(_loop(gen));
  }

  Future<void> _loop(int gen) async {
    while (_queuePos < _queue.length) {
      _index = _queue[_queuePos];
      final ok = await _shoot(gen);
      if (!_alive(gen)) return;
      if (!ok) return; // failed — ждём retry(), или ждём shutter()
      if (!await _announceNext(gen)) return;
    }
    _phase = SessionPhase.review;
    _notify();
  }

  /// После снимка: сдвиг очереди (пауза здесь продолжит со следующего), «Снимок сделан. Следующий: …», пауза.
  Future<bool> _announceNext(int gen) async {
    _queuePos++;
    final hasNext = _queuePos < _queue.length;
    _caption = phrases.taken(hasNext ? shots[_queue[_queuePos]] : null);
    _notify();
    await _say(_caption);
    if (!_alive(gen)) return false;
    if (hasNext) {
      await _wait(betweenShots);
      if (!_alive(gen)) return false;
    }
    return true;
  }

  /// Один ракурс: инструкция → отсчёт → снимок. true — снят; false — ошибка или ждём кнопку.
  Future<bool> _shoot(int gen) async {
    _phase = SessionPhase.instruction;
    _caption = phrases.instruction(current, first: _queuePos == 0);
    _notify();
    await _say(_caption);
    if (!_alive(gen)) return false;

    if (_countdown <= 0) {
      _phase = SessionPhase.waitingShutter;
      _notify();
      // Ждём shutter(): он увеличит поколение и сам продолжит серию.
      return false;
    }

    _phase = SessionPhase.countdown;
    for (var n = _countdown; n >= 1; n--) {
      _remaining = n;
      _notify();
      onTick?.call(n);
      if (n <= 3) unawaited(_say(phrases.count(n)));
      await _wait(const Duration(seconds: 1));
      if (!_alive(gen)) return false;
    }
    _remaining = 0;
    return _capture(gen);
  }

  /// Снимок по кнопке и продолжение серии.
  Future<void> _captureCurrent(int gen) async {
    final ok = await _capture(gen);
    if (!_alive(gen) || !ok) return;
    if (!await _announceNext(gen)) return;
    await _loop(gen);
  }

  Future<bool> _capture(int gen) async {
    _phase = SessionPhase.capturing;
    _notify();
    String? path;
    try {
      path = await source.capture();
    } catch (e) {
      debugPrint('GuidedSession.capture: $e');
    }
    if (!_alive(gen)) {
      if (path != null) await source.discard(path);
      return false;
    }
    if (path == null) {
      _phase = SessionPhase.failed;
      _caption = phrases.failed();
      _notify();
      unawaited(_say(_caption));
      return false;
    }
    final old = _results[_index];
    _results[_index] = path;
    if (old != null) unawaited(source.discard(old));
    _phase = SessionPhase.captured;
    onCaptured?.call();
    _notify();
    return true;
  }

  bool _alive(int gen) => !_disposed && gen == _gen && !_paused && _phase != SessionPhase.cancelled;

  Future<void> _say(String text) async {
    _speaking = true;
    _notify();
    try {
      await tts.speak(text, languageCode: languageCode, voice: voice).timeout(speakTimeout, onTimeout: () {});
    } catch (e) {
      debugPrint('GuidedSession.say: $e');
    } finally {
      _speaking = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _gen++;
    super.dispose();
  }
}
