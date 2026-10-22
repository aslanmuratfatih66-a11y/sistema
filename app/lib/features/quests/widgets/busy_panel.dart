// Занятость (SPEC §8.13): «занят на N часов» — квесты в это время сдвигаются на конец занятости (не штрафуются),
// напоминания тихие. Пары/работа/дорога из расписания учитываются сами (настройка «Режимы дня»).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/day_modes/day_modes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';

class BusyPanel extends ConsumerWidget {
  const BusyPanel({super.key});

  static const _options = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(homeClockProvider);
    final busy = ref.watch(dayBusyProvider).value;
    final until = busy != null && busy.activeAt(now) ? busy.until : null;
    // Сервис — только по нажатию (без БД при отрисовке).
    DayModesService service() => ref.read(dayModesServiceProvider);
    String hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return SysPanel(
      key: const Key('busy-panel'),
      title: l.busyTitle,
      tone: until != null ? PanelTone.gold : PanelTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (until != null) ...[
            Text(
              l.busyActive(hm(until)),
              key: const Key('busy-active'),
              style: SysText.body.copyWith(color: SysColors.gold),
            ),
            const SizedBox(height: 4),
            Text(l.busyHint, style: SysText.caption),
            const SizedBox(height: 10),
            SysButton.secondary(
              key: const Key('busy-clear'),
              label: l.busyClear,
              expand: true,
              onPressed: () => service().clearBusy(),
            ),
          ] else ...[
            Text(l.busyHint, style: SysText.secondary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final h in _options)
                  SysButton.secondary(
                    key: ValueKey('busy-$h'),
                    label: l.busyHours(h),
                    onPressed: () => service().setBusy(Duration(hours: h)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
