// Правка окна напоминаний перед планированием (ReminderCoordinator.templateFilter): без шаблонного упрёка там,
// где упрекает ИИ (этап 6), + напоминания финансов о подписках и долгах (этап 7, instanceId с префиксом 'fin:').
import '../core/db/database.dart';
import '../core/notifications/ai_messages_sync.dart';
import '../core/notifications/notification_api.dart';
import '../core/notifications/reminder_texts.dart';
import '../features/finance/data/finance_repository.dart';
import '../features/finance/finance_summary.dart';

export '../features/finance/finance_summary.dart' show financeReminderPrefix;

Future<List<ReminderRequest>> Function(List<ReminderRequest>) reminderTemplateFilter(AppDatabase db) {
  final ai = aiReproachFilter(db);
  final finance = FinanceRepository(db);
  return (requests) async {
    final out = await ai(requests);
    try {
      return [...out, ...await financeReminderRequests(finance, await reminderL10n(db), DateTime.now())];
    } catch (_) {
      return out; // финансы не должны ломать напоминания квестов
    }
  };
}
