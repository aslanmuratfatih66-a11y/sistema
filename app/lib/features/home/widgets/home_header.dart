import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/home_providers.dart';
import '../utils/home_format.dart';
import 'pulse_dot.dart';

/// Блок 1: «● Система · онлайн», колокольчик, настройки; строка даты/недели.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key, required this.unread, required this.programStart, this.onBell, this.onSettings});

  final int unread;
  final DateTime programStart;
  final VoidCallback? onBell;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final tag = locale.toLanguageTag();
    final now = ref.watch(homeClockProvider);
    final wd = programWeekDay(programStart, now);

    final weekday = upperFor(DateFormat.E(tag).format(now).replaceAll('.', ''), locale);
    final date = DateFormat('dd.MM', tag).format(now);
    final time = DateFormat.Hm(tag).format(now);

    const sep = TextSpan(text: '  ·  ', style: TextStyle(color: SysColors.textInactive));
    final captionStyle = SysText.caption.copyWith(
      fontFamily: SysFonts.heading,
      letterSpacing: 1.4,
      color: SysColors.textCaption,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PulseDot(),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                upperFor(l.homeSystemOnline, locale),
                style: SysText.title.copyWith(
                  color: SysColors.accentLighter,
                  letterSpacing: 2,
                  shadows: const [Shadow(color: SysColors.accent, blurRadius: 8)],
                ),
              ),
            ),
            const Spacer(),
            _HeaderIconButton(
              semanticLabel: l.homeNotificationsLabel(unread),
              onTap: onBell,
              badge: unread > 0 ? unread : null,
              glyph: SysGlyph.bell,
            ),
            _HeaderIconButton(
              semanticLabel: l.homeSettingsLabel,
              onTap: onSettings,
              glyph: SysGlyph.settings,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text.rich(
              TextSpan(children: [
                TextSpan(text: weekday),
                sep,
                TextSpan(text: date, style: SysText.mono.copyWith(fontSize: 12, color: SysColors.textSecondary)),
                sep,
                TextSpan(text: time, style: SysText.mono.copyWith(fontSize: 12, color: SysColors.textPrimary)),
              ]),
              style: captionStyle,
            ),
            Text(upperFor(l.homeWeekDay(wd.week, wd.day), locale), style: captionStyle.copyWith(color: SysColors.accentLight)),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.semanticLabel, required this.glyph, this.onTap, this.badge});

  final String semanticLabel;
  final SysGlyph glyph;
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap ?? () {},
        radius: 24,
        child: SizedBox.square(
          dimension: 48,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              SysIcon(glyph, size: 22, color: SysColors.accentLight),
              if (badge != null)
                Positioned(
                  top: 6,
                  right: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: SysColors.danger,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Color(0x88FF4D5E), blurRadius: 6)],
                    ),
                    child: Text(
                      badge! > 99 ? '99+' : '$badge',
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: SysText.mono.copyWith(fontSize: 10, height: 1.2, color: SysColors.textPrimary, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
