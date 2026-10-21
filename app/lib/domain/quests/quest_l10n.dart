// Локализация сущностей движка квестов. Сигнатуры — КОНТРАКТ каркаса (используют C, B, D);
// реализацию дописывает сабагент A (системные ключи квестов, эффекты, титулы, причины штрафов).
import '../../core/models/enums.dart';
import '../../features/plan/model/plan.dart' show QuestCategory, QuestDraft, QuestKey;
import '../../features/plan/plan_l10n.dart' show planQuestTitle;
import '../../l10n/app_localizations.dart';
import 'quest_api.dart';

/// Название квеста: свой текст, ключ плана (QuestKey) или системный ключ движка.
String questTitleText(AppLocalizations l, QuestTitle t) {
  final text = t.text;
  if (text != null && text.trim().isNotEmpty) return text;
  final key = enumByName(QuestKey.values, t.key);
  if (key != null) {
    return planQuestTitle(
      l,
      QuestDraft(
        key: key,
        category: QuestCategory.daily,
        params: t.params,
        minute: t.params['minute'] as int?,
        diamonds: 0,
        xp: 0,
      ),
    );
  }
  // TODO(A): системные ключи движка (штрафной, босс, дисциплина, усиленный план…).
  return t.key ?? '';
}

/// Подпись эффекта («Бодрость +5% опыта»).
String effectLabel(AppLocalizations l, ActiveEffect e) => e.kind; // TODO(A)

/// Титул по ключу; null — без титула.
String? titleLabel(AppLocalizations l, String? titleKey) => titleKey; // TODO(A)

/// Причина отдельного штрафа (PenaltyApplied.reasonKey).
String penaltyReasonLabel(AppLocalizations l, String reasonKey) => reasonKey; // TODO(A)
