// Подписи и фразы прогулки из l10n, форматирование дистанции/времени/темпа.
import '../../core/models/enums.dart';
import '../../domain/walks/walk_api.dart';
import '../../l10n/app_localizations.dart';
import 'domain/walk_voice.dart';

String walkModeLabel(AppLocalizations l, WalkMode m) => switch (m) {
      WalkMode.walk => l.wlkModeWalk,
      WalkMode.brisk => l.wlkModeBrisk,
      WalkMode.cardio => l.wlkModeCardio,
      WalkMode.rest => l.wlkModeRest,
    };

String walkTurnLabel(AppLocalizations l, RouteTurn t) => switch (t) {
      RouteTurn.start => l.wlkTurnStart,
      RouteTurn.straight => l.wlkTurnStraight,
      RouteTurn.left => l.wlkTurnLeft,
      RouteTurn.right => l.wlkTurnRight,
      RouteTurn.slightLeft => l.wlkTurnSlightLeft,
      RouteTurn.slightRight => l.wlkTurnSlightRight,
      RouteTurn.uTurn => l.wlkTurnUTurn,
      RouteTurn.arrive => l.wlkTurnArrive,
    };

String? _sayTurn(AppLocalizations l, RouteTurn t) => switch (t) {
      RouteTurn.left => l.wlkSayTurnLeft,
      RouteTurn.right => l.wlkSayTurnRight,
      RouteTurn.slightLeft => l.wlkSayTurnSlightLeft,
      RouteTurn.slightRight => l.wlkSayTurnSlightRight,
      RouteTurn.uTurn => l.wlkSayTurnUTurn,
      _ => null,
    };

String _sayMode(AppLocalizations l, WalkMode m) => switch (m) {
      WalkMode.walk => l.wlkSayModeWalk,
      WalkMode.brisk => l.wlkSayModeBrisk,
      WalkMode.cardio => l.wlkSayModeCardio,
      WalkMode.rest => l.wlkSayModeRest,
    };

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Фраза для голоса («Поверни налево и ускорься»). null — нечего сказать.
String? walkVoiceText(AppLocalizations l, WalkVoiceLine line) {
  if (line.offRoute) return l.wlkSayOffRoute;
  if (line.arrive) return l.wlkSayArrive;
  final mode = line.mode == null ? null : _sayMode(l, line.mode!);
  if (line.start) return mode == null ? l.wlkSayStart : '${l.wlkSayStart}. ${_cap(mode)}';
  final turn = line.turn == null ? null : _sayTurn(l, line.turn!);
  if (turn != null && mode != null) return _cap(l.wlkSayAnd(turn, mode));
  final one = turn ?? mode;
  return one == null ? null : _cap(one);
}

/// «2.35» (км, два знака).
String formatKm(double meters) => (meters / 1000).toStringAsFixed(2);

/// «12:05» / «1:02:05».
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Темп «мм:сс» на км; null/бессмыслица — «—».
String formatPace(double? secPerKm) {
  if (secPerKm == null || !secPerKm.isFinite || secPerKm <= 0 || secPerKm > 3600) return '—';
  final s = secPerKm.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}
