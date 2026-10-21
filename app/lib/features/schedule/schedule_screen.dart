// Экран «Расписание»: номер недели с переключением, выбор дня, лента дня, время выхода из дома.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/schedule_repository.dart';
import 'schedule_editor.dart';
import 'schedule_logic.dart';
import 'widgets/schedule_common.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime? _selected; // null — сегодня

  void _back() => context.canPop() ? context.pop() : context.go(Routes.more);

  DateTime _shift(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(scheduleClockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final day = _selected ?? today;
    final config = ref.watch(scheduleConfigProvider).value;
    final entries = ref.watch(scheduleEntriesProvider).value;

    return ScheduleSubPage(
      title: l.schTitle,
      onBack: _back,
      child: config == null || entries == null
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: SysColors.accentLight)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WeekHeader(day: day, config: config),
                const SizedBox(height: 12),
                _DayStrip(
                  day: day,
                  today: today,
                  config: config,
                  onSelect: (d) => setState(() => _selected = d),
                  onWeek: (delta) => setState(() => _selected = _shift(day, 7 * delta)),
                ),
                const SizedBox(height: 14),
                _DayFeed(day: day, config: config, entries: entries, isToday: day == today, now: now),
                const SizedBox(height: 14),
                SysButton.primary(
                  key: const Key('sch-edit'),
                  label: l.schEditSchedule,
                  icon: SysGlyph.settings,
                  expand: true,
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (c) => ScheduleSubPage(
                      title: l.schEditSchedule,
                      onBack: () => Navigator.of(c).maybePop(),
                      child: const ScheduleEditor(),
                    ),
                  )),
                ),
              ],
            ),
    );
  }
}

/// «НЕДЕЛЯ 1 · СР 21.10» + переключение недели.
class _WeekHeader extends ConsumerWidget {
  const _WeekHeader({required this.day, required this.config});

  final DateTime day;
  final ScheduleConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final dayText = '${weekdayShort(l, day.weekday)} · ${formatDayMonth(day)}';
    final text = config.alternationEnabled
        ? l.schHeader(ScheduleLogic.weekNumber(day, config), dayText)
        : l.schHeaderNoAlt(dayText);
    return SysPanel(
      animateIn: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.toUpperCase(),
            key: const Key('sch-week-header'),
            style: SysText.title.copyWith(color: SysColors.accentLighter),
          ),
          if (config.alternationEnabled) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: SysButton.secondary(
                key: const Key('sch-switch-week'),
                label: l.schSwitchWeek,
                onPressed: ref.read(scheduleRepositoryProvider).switchWeek,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Неделя: стрелки ± неделя и 7 дней (Пн…Вс) с выделением выбранного.
class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.day,
    required this.today,
    required this.config,
    required this.onSelect,
    required this.onWeek,
  });

  final DateTime day;
  final DateTime today;
  final ScheduleConfig config;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onWeek;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final monday = ScheduleLogic.mondayOf(day);
    Widget arrow(int delta) => IconButton(
          tooltip: delta < 0 ? l.schPrevWeek : l.schNextWeek,
          onPressed: () => onWeek(delta),
          constraints: const BoxConstraints(minWidth: 36, minHeight: SysDims.minTap),
          padding: EdgeInsets.zero,
          icon: RotatedBox(
            quarterTurns: delta < 0 ? 3 : 1,
            child: const SysIcon(SysGlyph.arrowUp, size: 18, color: SysColors.accentLight),
          ),
        );
    return Row(
      children: [
        arrow(-1),
        for (var i = 0; i < 7; i++)
          Expanded(child: _dayCell(context, DateTime(monday.year, monday.month, monday.day + i))),
        arrow(1),
      ],
    );
  }

  Widget _dayCell(BuildContext context, DateTime d) {
    final l = AppLocalizations.of(context);
    final selected = d == day;
    final isToday = d == today;
    final weekend = config.weekendDays.contains(d.weekday);
    final fg = selected
        ? SysColors.textPrimary
        : weekend
            ? SysColors.textInactive
            : SysColors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: '${weekdayFull(l, d.weekday)} ${formatDayMonth(d)}${isToday ? ', ${l.schToday}' : ''}',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onSelect(d),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? SysColors.accent.withValues(alpha: .22) : SysColors.accent.withValues(alpha: .04),
            border: Border.all(
              color: selected
                  ? SysColors.accentLight
                  : isToday
                      ? SysColors.accent
                      : SysColors.accent.withValues(alpha: .25),
            ),
            borderRadius: BorderRadius.circular(SysDims.radius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(weekdayShort(l, d.weekday).toUpperCase(), style: SysText.label.copyWith(color: fg, fontSize: 11)),
              const SizedBox(height: 2),
              Text('${d.day}', style: SysText.mono.copyWith(color: fg, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

Color _slotColor(ScheduleSlotType t) => switch (t) {
      ScheduleSlotType.sleep => SysColors.bossLight,
      ScheduleSlotType.entry => SysColors.accent,
      ScheduleSlotType.commute => SysColors.textInactive,
      ScheduleSlotType.free => SysColors.success,
    };

/// Лента дня (подъём…отбой) + список: сон, дорога, пункты, свободно; время выхода из дома.
class _DayFeed extends StatelessWidget {
  const _DayFeed({
    required this.day,
    required this.config,
    required this.entries,
    required this.isToday,
    required this.now,
  });

  final DateTime day;
  final ScheduleConfig config;
  final List<ScheduleEntry> entries;
  final bool isToday;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slots = ScheduleLogic.dayTimeline(day, config, entries);
    final leave = ScheduleLogic.leaveHomeMinute(day, config, entries);
    final free = ScheduleLogic.freeMinutes(day, config, entries);
    // Видимый диапазон ленты — как на главном: подъём…отбой (не уже 07–23, если пункты выходят за пределы).
    var start = config.wakeMinute < 7 * 60 ? config.wakeMinute : 7 * 60;
    var end = config.bedMinute > config.wakeMinute ? config.bedMinute : 24 * 60;
    if (end < 23 * 60) end = 23 * 60;
    for (final s in slots) {
      if (s.type == ScheduleSlotType.entry || s.type == ScheduleSlotType.commute) {
        if (s.startMinute < start) start = s.startMinute;
        if (s.endMinute > end) end = s.endMinute;
      }
    }
    start = start - start % 60;
    final nowMinute = isToday ? now.hour * 60 + now.minute : null;

    return SysPanel(
      title: l.schDayFeed,
      trailing: leave == null
          ? null
          : Text(formatMinuteOfDay(leave), style: SysText.mono.copyWith(fontSize: 12, color: SysColors.accentLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: SizedBox(
              height: 30,
              child: CustomPaint(
                painter: _RibbonPainter(slots: slots, start: start, end: end, leave: leave, now: nowMinute),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatMinuteOfDay(start), style: SysText.mono.copyWith(fontSize: 10, color: SysColors.textInactive)),
              Text(formatMinuteOfDay(end), style: SysText.mono.copyWith(fontSize: 10, color: SysColors.textInactive)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SysIcon(SysGlyph.home, size: 16, color: SysColors.accentLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  leave == null ? l.schNoLeave : l.schLeaveHome(formatMinuteOfDay(leave)),
                  key: const Key('sch-leave'),
                  style: SysText.secondary.copyWith(color: SysColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.schFreeTotal(formatDuration(l, free)), style: SysText.caption),
          const SizedBox(height: 10),
          for (final s in slots)
            if (s.endMinute > start && s.startMinute < end) _slotRow(context, l, s),
        ],
      ),
    );
  }

  Widget _slotRow(BuildContext context, AppLocalizations l, ScheduleSlot s) {
    final e = s.entry;
    if (e != null) return EntryTile(entry: e, alternation: config.alternationEnabled);
    final label = switch (s.type) {
      ScheduleSlotType.sleep => l.schSlotSleep,
      ScheduleSlotType.commute => l.schSlotCommute,
      _ => l.schSlotFree,
    };
    final c = _slotColor(s.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border(left: BorderSide(color: c.withValues(alpha: .8), width: 2))),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              l.schTimeRange(formatMinuteOfDay(s.startMinute), formatMinuteOfDay(s.endMinute)),
              style: SysText.mono.copyWith(fontSize: 12, color: SysColors.textCaption),
            ),
          ),
          Expanded(child: Text(label, style: SysText.secondary.copyWith(color: c))),
          Text(formatDuration(l, s.endMinute - s.startMinute), style: SysText.caption),
        ],
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter({required this.slots, required this.start, required this.end, this.leave, this.now});

  final List<ScheduleSlot> slots;
  final int start;
  final int end;
  final int? leave;
  final int? now;

  @override
  void paint(Canvas canvas, Size size) {
    if (end <= start || size.isEmpty) return;
    const barH = 14.0;
    final top = (size.height - barH) / 2;
    final track = Rect.fromLTWH(0, top, size.width, barH);
    double x(int m) => ((m - start) / (end - start)).clamp(0.0, 1.0) * size.width;

    canvas.drawRect(track, Paint()..color = const Color.fromRGBO(63, 180, 255, .07));
    for (final s in slots) {
      final l = x(s.startMinute);
      final r = x(s.endMinute);
      if (r - l <= 0) continue;
      final rect = Rect.fromLTRB(l + .5, top, r - .5, top + barH);
      final c = _slotColor(s.type);
      canvas.drawRect(rect, Paint()..color = c.withValues(alpha: s.type == ScheduleSlotType.free ? .22 : .55));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = c.withValues(alpha: .9),
      );
    }
    canvas.drawRect(
      track,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = SysColors.panelBorder,
    );
    final lv = leave;
    if (lv != null) {
      final lx = x(lv);
      canvas.drawPath(
        Path()
          ..moveTo(lx, top - 7)
          ..lineTo(lx + 4, top - 3)
          ..lineTo(lx, top + 1)
          ..lineTo(lx - 4, top - 3)
          ..close(),
        Paint()..color = SysColors.accentLighter,
      );
    }
    final n = now;
    if (n != null && n >= start && n <= end) {
      final nx = x(n);
      canvas.drawLine(
        Offset(nx, 0),
        Offset(nx, size.height),
        Paint()
          ..color = SysColors.textPrimary
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      old.slots != slots || old.start != start || old.end != end || old.leave != leave || old.now != now;
}
