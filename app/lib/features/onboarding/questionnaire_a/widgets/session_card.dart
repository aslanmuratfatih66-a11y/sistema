import 'package:flutter/widgets.dart';

import '../../../../core/db/database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../camera/capture_guide.dart';
import 'photo_slot.dart';

/// Миниатюра ракурса в карточке сессии.
class SessionThumb {
  const SessionThumb(this.label, this.guide, this.photo);

  final String label;
  final CaptureGuide guide;
  final PhotoRow? photo;
}

/// Карточка «Фото-сессия: … (3 ракурса)»: пояснение, миниатюры снятых ракурсов, «Начать сессию».
class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.title, required this.thumbs, required this.onStart});

  final String title;
  final List<SessionThumb> thumbs;

  /// null — камера недоступна.
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final any = thumbs.any((t) => t.photo != null);
    return SysPanel(
      title: title,
      animateIn: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.qaShootCardHint, style: SysText.caption),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, t) in thumbs.indexed) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: PhotoSlot(label: t.label, guide: t.guide, photo: t.photo, onTap: null)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          SysButton.primary(
            label: any ? l.qaShootRestartSession : l.qaShootStartSession,
            onPressed: onStart,
            expand: true,
          ),
        ],
      ),
    );
  }
}
