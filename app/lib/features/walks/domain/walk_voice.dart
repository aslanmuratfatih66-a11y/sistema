// Голосовые подсказки прогулки: по ходу WalkProgress решает, что сказать (поворот, смена режима, финиш, сход).
// Тексты собирает экран из l10n (WalkVoiceLine → фраза).
import '../../../core/models/enums.dart';
import '../../../domain/walks/walk_api.dart';

/// За сколько метров предупреждать о повороте.
const double cueAnnounceM = 40;

/// Что сказать: поворот и/или новый режим («поверни налево и ускорься»), финиш, сход с маршрута.
class WalkVoiceLine {
  const WalkVoiceLine({this.turn, this.mode, this.arrive = false, this.offRoute = false, this.start = false});

  final RouteTurn? turn;
  final WalkMode? mode;
  final bool arrive;
  final bool offRoute;
  final bool start;

  @override
  String toString() => 'WalkVoiceLine(turn: $turn, mode: $mode, arrive: $arrive, offRoute: $offRoute, start: $start)';
}

class WalkVoiceCoach {
  double? _announcedCueAt;
  int? _segment;
  bool _offRoute = false;
  bool _arrived = false;
  bool _started = false;

  void reset() {
    _announcedCueAt = null;
    _segment = null;
    _offRoute = false;
    _arrived = false;
    _started = false;
  }

  /// Очередное состояние → фраза или null.
  WalkVoiceLine? next(WalkProgress p) {
    if (p.paused) return null;
    if (!_started) {
      _started = true;
      _segment = p.segmentIndex;
      return WalkVoiceLine(start: true, mode: p.mode);
    }
    final off = p.offRoute && !_offRoute;
    _offRoute = p.offRoute;
    if (off) return const WalkVoiceLine(offRoute: true);

    WalkMode? mode;
    if (p.segmentIndex != null && p.segmentIndex != _segment) {
      _segment = p.segmentIndex;
      mode = p.mode;
    }
    RouteTurn? turn;
    var arrive = false;
    final cue = p.nextCue;
    final dist = p.metersToNextCue;
    if (cue != null && dist != null && dist <= cueAnnounceM && cue.atM != _announcedCueAt) {
      _announcedCueAt = cue.atM;
      if (cue.turn == RouteTurn.arrive) {
        if (!_arrived) arrive = _arrived = true;
      } else if (cue.turn != RouteTurn.start && cue.turn != RouteTurn.straight) {
        turn = cue.turn;
      }
    }
    if (turn == null && mode == null && !arrive) return null;
    return WalkVoiceLine(turn: turn, mode: mode, arrive: arrive);
  }
}
