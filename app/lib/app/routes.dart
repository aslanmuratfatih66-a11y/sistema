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

  /// Редактирование раздела анкеты из настроек.
  static String editStep(OnboardingStep step) => '/edit/${step.name}';
}
