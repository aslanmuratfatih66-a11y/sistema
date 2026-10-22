// Общие части экранов анализа фото: выбор источника, ошибки ИИ, пометка «оценка», состояние загрузки.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../core/ai/ai_api.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../common/ai_error_view.dart';
import '../nutrition/platform/nutrition_platform.dart';
import '../onboarding/questionnaire_a/data/photo_repository.dart';

/// Язык ответов ИИ — язык интерфейса.
String visionLang(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr' ? 'tr' : 'ru';

/// Текст ошибки для пользователя.
String visionErrorText(AppLocalizations l, Object e) => switch (e) {
      AiException(failure: AiFailure.offline) => l.visErrOffline,
      AiException(failure: AiFailure.notSignedIn) => l.visErrNotSignedIn,
      AiException(failure: AiFailure.budget) => l.visErrBudget,
      AiException(failure: AiFailure.unavailable) => l.visErrUnavailable,
      AiException(failure: AiFailure.rateLimited) => l.visErrBudget,
      _ => l.visErrServer,
    };

/// Чтение провайдера: `ref.read` или `ProviderScope.containerOf(context).read`.
typedef VisionRead = T Function<T>(ProviderListenable<T> provider);

/// Камера или галерея → путь к временному файлу (JPEG ≤1600px) или null.
Future<String?> pickVisionPhoto(BuildContext context, VisionRead read, {String? message}) async {
  final l = AppLocalizations.of(context);
  final camera = await showSystemWindow<bool>(
    context,
    window: SystemWindow(
      kind: SystemWindowKind.notice,
      label: l.visNoticeLabel,
      title: l.visSourceTitle,
      message: message ?? l.visSourceMessage,
      actions: [
        Builder(
          builder: (c) => SysButton.secondary(label: l.visGallery, onPressed: () => Navigator.of(c).pop(false)),
        ),
        Builder(
          builder: (c) => SysButton.primary(label: l.visCamera, onPressed: () => Navigator.of(c).pop(true)),
        ),
      ],
    ),
  );
  if (camera == null || !context.mounted) return null;
  return read(foodPhotoPickerProvider).pick(camera: camera);
}

/// Сохраняет снятое фото в каталог приложения и в Photos. Возвращает (id, относительный путь).
Future<({String id, String rel})> storeVisionPhoto(VisionRead read, String path, PhotoKind kind) async {
  final rel = await read(photoStorageProvider).import(path, kind);
  final id = await read(photoRepositoryProvider).add(kind: kind, pose: PhotoPose.other, localPath: rel);
  return (id: id, rel: rel);
}

Future<void> dropVisionPhoto(VisionRead read, ({String id, String rel}) photo) async {
  await read(photoRepositoryProvider).softDelete(photo.id);
  await read(photoStorageProvider).delete(photo.rel);
}

/// Пометка «оценка».
class EstimateBadge extends StatelessWidget {
  const EstimateBadge({super.key});

  @override
  Widget build(BuildContext context) =>
      SysPill(label: AppLocalizations.of(context).visEstimate, tone: PanelTone.gold, icon: SysGlyph.info);
}

/// Загрузка с подписью.
class VisionBusy extends StatelessWidget {
  const VisionBusy({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: SysLoader(label: text ?? AppLocalizations.of(context).visAnalyzing)),
      );
}

/// Ошибка с кнопкой «Повторить».
class VisionError extends StatelessWidget {
  const VisionError({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AiErrorView.fromError(
      error,
      message: visionErrorText(l, error),
      retryLabel: l.visRetry,
      onRetry: onRetry,
      alwaysRetry: true,
    );
  }
}

/// Строка «подпись — значение».
class VisionRow extends StatelessWidget {
  const VisionRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: Text(label, style: SysText.secondary)),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: Text(value, style: SysText.body)),
          ],
        ),
      );
}
