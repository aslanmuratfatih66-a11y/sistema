import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'capability_service.dart';
import 'certificate_status.dart';

/// Тонкая панель «Сертификат истекает через N дн.» (SPEC §3). Без профиля — пусто.
class CertificateBanner extends ConsumerWidget {
  const CertificateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(deviceCapabilitiesProvider).value;
    final now = ref.watch(certificateClockProvider)();
    final status = CertificateStatus.from(caps?.provisioningExpiresAt, now);
    if (status == null || !status.visible) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final tone = switch (status.level) {
      CertificateLevel.info => PanelTone.accent,
      CertificateLevel.warning => PanelTone.gold,
      CertificateLevel.critical => PanelTone.danger,
    };
    final palette = tone.palette;
    final message = status.expired ? l.certExpired : l.certExpiresInDays(status.daysLeft);
    final showHint = status.level != CertificateLevel.info;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: SysPanel(
          tone: tone,
          animateIn: false,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SysIcon(SysGlyph.warning, size: 18, color: palette.light),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, style: SysText.body.copyWith(color: palette.light)),
                    if (showHint) ...[
                      const SizedBox(height: 2),
                      Text(l.certReinstallHint, style: SysText.caption),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
