// Пути маршрутов. Отдельно от роутера, чтобы фичи могли импортировать без циклов.
import '../features/onboarding/onboarding_step.dart';

abstract final class Routes {
  // Вкладки.
  static const status = '/status';
  static const quests = '/quests';
  static const nutrition = '/nutrition';
  static const shop = '/shop';
  static const more = '/more';

  // Полноэкранные.
  static const onboarding = '/onboarding';
  static const plan = '/plan';
  static const schedule = '/schedule';
  static const editStepPattern = '/edit/:step';
  static const reminders = '/reminders';
  static const discipline = '/discipline';
  static const body = '/body';
  static const workouts = '/workouts';
  static const walks = '/walks';
  static const account = '/account';
  static const chat = '/chat';
  static const learning = '/learning';

  /// Расходы ИИ и журнал действий ИИ (с отменой).
  static const aiJournal = '/ai';

  // Этап 7.
  static const finance = '/finance';

  /// Чек: `?mode=qr` или `?mode=photo`.
  static const financeReceipt = '/finance/receipt';

  /// Банки: выбор, разрешения (Android), входящие уведомления/SMS.
  static const financeBanks = '/finance/banks';

  /// Импорт выписки (CSV/PDF), в первую очередь iOS.
  static const financeStatement = '/finance/statement';
  static const market = '/market';

  /// Настройка блокировки приложений (Android — разрешения и список; iOS — мастер «Команд»).
  static const blocker = '/blocker';

  /// Заглушка «Система: отбой». Deep link из «Команд»: `sistema://app/blocked?app=tiktok` (хост app — без пути
  /// Flutter не передаёт маршрут).
  static const blocked = '/blocked';
  static const alarms = '/alarms';

  /// Звонящий будильник: `?id=<alarmId>`.
  static const alarmRing = '/alarm/ring';

  /// Редактирование раздела анкеты из настроек.
  static String editStep(OnboardingStep step) => '/edit/${step.name}';
}
