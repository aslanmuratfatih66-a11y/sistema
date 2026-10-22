import '../../core/ai/ai_api.dart';
import '../../l10n/app_localizations.dart';

/// Понятное сообщение о недоступности ИИ.
String aiFailureText(AppLocalizations l, AiFailure f) => switch (f) {
      AiFailure.notSignedIn => l.chtErrNotSignedIn,
      AiFailure.offline => l.chtErrOffline,
      AiFailure.budget => l.chtErrBudget,
      AiFailure.unavailable => l.chtErrUnavailable,
      AiFailure.rateLimited => l.chtErrRateLimited,
      AiFailure.server => l.chtErrServer,
    };

/// Шаблонная реплика персонажа, когда ИИ недоступен (по режиму мотивации).
String chatFallbackLine(AppLocalizations l, String motivation) => switch (motivation) {
      'soft' => l.chtFallbackSoft,
      'strict' => l.chtFallbackStrict,
      'harsh' => l.chtFallbackHarsh,
      _ => l.chtFallbackNormal,
    };
