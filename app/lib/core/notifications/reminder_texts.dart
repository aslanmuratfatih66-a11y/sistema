// Тексты уведомлений в стиле «Системы»: квест → ReminderRequest, последствия → немедленные уведомления.
import 'dart:ui';

import '../../domain/quests/quest_api.dart';
import '../../domain/quests/quest_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../data/profile_repository.dart';
import '../db/database.dart';
import '../models/enums.dart';
import 'notification_api.dart';

/// Язык уведомлений: Profiles.locale, иначе первый поддерживаемый язык системы, иначе русский.
Locale resolveReminderLocale(String? profileCode, List<Locale> system) {
  const supported = ['ru', 'tr'];
  if (profileCode != null && supported.contains(profileCode)) return Locale(profileCode);
  for (final l in system) {
    if (supported.contains(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('ru');
}

/// Локализация для уведомлений вне дерева виджетов (main, фоновые isolate'ы).
Future<AppLocalizations> reminderL10n(AppDatabase db) async {
  String? code;
  try {
    code = (await ProfileRepository(db).get())?.locale;
  } catch (_) {
    code = null; // профиля ещё нет / БД недоступна — язык системы
  }
  return lookupAppLocalizations(resolveReminderLocale(code, PlatformDispatcher.instance.locales));
}

/// «14:05» — без intl (в фоновом isolate данные локалей intl не загружены).
String reminderTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Когда звенит первое напоминание: конец «+10 мин», иначе начало квеста, иначе дедлайн.
DateTime reminderDueAt(QuestItem q) => q.snoozedUntil ?? q.startsAt ?? q.deadlineAt;

/// Запрос напоминания по квесту; null — квест закрыт.
ReminderRequest? reminderRequestFor(AppLocalizations l, QuestItem q) {
  if (!q.isPending) return null;
  final title = questTitleText(l, q.title);
  final time = reminderTime(q.deadlineAt);
  final String head;
  final String body;
  switch (q.kind) {
    case QuestKind.penalty:
      head = l.ntfPenaltyQuestTitle(title);
      body = l.ntfPenaltyQuestBody(time);
    case QuestKind.boss:
      head = l.ntfBossTitle(title);
      body = q.reward.diamonds > 0 ? l.ntfQuestBody(time, q.reward.diamonds) : l.ntfQuestBodyNoReward(time);
    default:
      head = l.ntfQuestTitle(title);
      body = q.reward.diamonds > 0 ? l.ntfQuestBody(time, q.reward.diamonds) : l.ntfQuestBodyNoReward(time);
  }
  return ReminderRequest(
    instanceId: q.instanceId,
    title: head,
    body: body,
    dueAt: reminderDueAt(q),
    deadlineAt: q.deadlineAt,
    // Босс недели длится неделю — каждую минуту не надоедаем.
    nag: q.nag && q.kind != QuestKind.boss,
    reproachTitle: l.ntfReproachTitle,
    reproachBody: l.ntfReproachBody(title),
  );
}

/// Немедленное уведомление о последствии.
typedef ReminderNotice = ({String title, String body});

/// Последствия, о которых стоит сообщить уведомлением, когда приложение не на экране
/// (на переднем плане их показывают системные окна).
List<ReminderNotice> outcomeNotices(AppLocalizations l, Iterable<GameOutcome> outcomes) => [
      for (final o in outcomes) ?_notice(l, o),
    ];

ReminderNotice? _notice(AppLocalizations l, GameOutcome o) => switch (o) {
      QuestFailed(:final quest, :final penaltyDiamonds) => (
          title: l.ntfFailedTitle,
          body: l.ntfFailedBody(questTitleText(l, quest.title), penaltyDiamonds.abs()),
        ),
      PenaltyApplied(:final reasonKey, :final diamonds) => (
          title: l.ntfPenaltyTitle(diamonds.abs()),
          body: penaltyReasonLabel(l, reasonKey),
        ),
      LevelUp(:final level, :final freeStatPoints) => (
          title: l.ntfLevelUpTitle,
          body: l.ntfLevelUpBody(level, freeStatPoints),
        ),
      _ => null,
    };
