import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../../core/db/database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../camera/capture_guide.dart';
import '../data/photo_repository.dart';

/// Слот фото позы: миниатюра (или контур-подсказка), подпись, статус. Тап — снять / переснять.
class PhotoSlot extends ConsumerWidget {
  const PhotoSlot({
    super.key,
    required this.label,
    required this.guide,
    required this.photo,
    required this.onTap,
    this.onDelete,
  });

  final String label;
  final CaptureGuide guide;
  final PhotoRow? photo;

  /// null — камера недоступна, слот неактивен.
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ph = photo;
    final root = kIsWeb ? null : ref.watch(photoRootProvider).value;
    final del = onDelete;
    final enabled = onTap != null;
    Widget content;
    if (ph != null && root != null) {
      content = Image.file(
        File(p.joinAll([root, ...p.posix.split(ph.localPath)])),
        fit: BoxFit.cover,
        cacheWidth: 360,
        errorBuilder: (_, _, _) => _guide(enabled),
      );
    } else {
      content = _guide(enabled);
    }
    return Semantics(
      button: enabled,
      label: '$label: ${ph == null ? l.qaPhotoNotTaken : l.qaPhotoTaken}',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SysDims.radius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SysDims.radius),
                    color: SysColors.accent.withValues(alpha: .05),
                    border: Border.all(
                      color: ph != null ? SysColors.accentLight : SysColors.accent.withValues(alpha: .35),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SysDims.radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        content,
                        if (ph != null)
                          const Positioned(
                            right: 6,
                            top: 6,
                            child: SysIcon(SysGlyph.check, size: 16, color: SysColors.success),
                          ),
                        if (del != null)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: IconButton(
                              tooltip: l.commonDelete,
                              onPressed: del,
                              icon: const SysIcon(SysGlyph.close, size: 16, color: SysColors.dangerLight),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(label, style: SysText.caption, textAlign: TextAlign.center, maxLines: 2),
              Text(
                ph == null
                    ? (enabled ? l.qaPhotoTap : l.qaPhotoNotTaken)
                    : (enabled ? l.qaPhotoRetakeHint : l.qaPhotoTaken),
                style: SysText.caption.copyWith(color: ph == null ? SysColors.textInactive : SysColors.success),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _guide(bool enabled) => Padding(
        padding: const EdgeInsets.all(6),
        child: CustomPaint(
          painter: CaptureGuidePainter(
            guide,
            color: enabled ? SysColors.accentLight : SysColors.textInactive,
            glow: enabled ? SysColors.accent : const Color(0x00000000),
          ),
        ),
      );
}

/// Сообщение «камера недоступна» — шаг при этом работает дальше.
class CameraUnavailableNote extends StatelessWidget {
  const CameraUnavailableNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SysIcon(SysGlyph.warning, size: 18, color: SysColors.gold),
          const SizedBox(width: 8),
          Expanded(child: Text(l.qaCameraUnavailableInline, style: SysText.secondary)),
        ],
      ),
    );
  }
}
