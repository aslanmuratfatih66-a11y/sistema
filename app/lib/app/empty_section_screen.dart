import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../ui/ui.dart';

/// Пустой экран раздела (этап 0).
class EmptySectionScreen extends StatelessWidget {
  const EmptySectionScreen({super.key, required this.title, required this.glyph});

  final String title;
  final SysGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: SysPanel(
            title: title,
            child: Row(
              children: [
                SysIcon(glyph, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.sectionEmptyTitle, style: SysText.body),
                      const SizedBox(height: 4),
                      Text(l.sectionEmptyBody, style: SysText.secondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
