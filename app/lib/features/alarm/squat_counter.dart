// Счётчик приседаний по акселерометру (телефон в руке / у груди). Ориентация не важна:
// берётся проекция ускорения на направление силы тяжести (вертикальная составляющая).
// Цикл приседания: опускание (ускорение вниз → v < 0) → низ и подъём (v > 0) → торможение вверху (v < 0).
// Защита от тряски: частые смены знака / слишком большие пики сбрасывают цикл и дают паузу.
import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class SquatCounter {
  SquatCounter({required this.onSquat, this.onError});

  /// Новое приседание засчитано (общее число).
  final void Function(int count) onSquat;
  final void Function(Object error)? onError;

  StreamSubscription<AccelerometerEvent>? _sub;
  int count = 0;

  // Оценка силы тяжести (медленный фильтр) и сглаженная вертикальная составляющая.
  double _gx = 0, _gy = 0, _gz = 0;
  bool _gInit = false;
  double _v = 0;

  // Пороги, м/с².
  static const _down = 1.0; // начало опускания
  static const _up = 1.3; // низ / начало подъёма
  static const _top = 0.8; // торможение вверху
  static const _shake = 14.0; // пик тряски
  static const _minCycle = Duration(milliseconds: 700);
  static const _maxPhase = Duration(milliseconds: 3500);
  static const _minGap = Duration(milliseconds: 600);

  int _phase = 0; // 0 — стоит, 1 — опускается, 2 — поднимается
  DateTime _phaseAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _cycleAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCount = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _quietUntil = DateTime.fromMillisecondsSinceEpoch(0);
  final _signFlips = <DateTime>[];
  int _lastSign = 0;

  void start() {
    _sub ??= accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      _onEvent,
      onError: (Object e) => onError?.call(e),
      cancelOnError: false,
    );
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void _onEvent(AccelerometerEvent e) {
    final now = DateTime.now();
    if (!_gInit) {
      _gx = e.x;
      _gy = e.y;
      _gz = e.z;
      _gInit = true;
      return;
    }
    const ag = 0.02; // ~1 с при 50 Гц
    _gx += (e.x - _gx) * ag;
    _gy += (e.y - _gy) * ag;
    _gz += (e.z - _gz) * ag;
    final g = sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
    if (g < 3) return; // свободное падение / мусор
    final raw = (e.x * _gx + e.y * _gy + e.z * _gz) / g - g;
    _v += (raw - _v) * 0.25;

    // Тряска: резкие пики или >6 смен знака за секунду.
    final sign = _v > _down ? 1 : (_v < -_down ? -1 : 0);
    if (sign != 0 && sign != _lastSign) {
      _lastSign = sign;
      _signFlips.add(now);
    }
    _signFlips.removeWhere((t) => now.difference(t) > const Duration(seconds: 1));
    if (raw.abs() > _shake || _signFlips.length > 6) {
      _phase = 0;
      _quietUntil = now.add(const Duration(milliseconds: 800));
      return;
    }
    if (now.isBefore(_quietUntil)) return;

    if (_phase != 0 && now.difference(_phaseAt) > _maxPhase) _phase = 0;
    switch (_phase) {
      case 0:
        if (_v < -_down && now.difference(_lastCount) > _minGap) {
          _phase = 1;
          _phaseAt = now;
          _cycleAt = now;
        }
      case 1:
        if (_v > _up) {
          _phase = 2;
          _phaseAt = now;
        }
      case 2:
        if (_v < -_top) {
          _phase = 0;
          if (now.difference(_cycleAt) >= _minCycle) {
            _lastCount = now;
            count++;
            onSquat(count);
          }
        }
    }
  }
}
