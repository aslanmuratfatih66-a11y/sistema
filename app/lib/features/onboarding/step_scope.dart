import 'package:flutter/widgets.dart';

/// Связь содержимого шага анкеты с хостом (онбординг или редактирование в настройках).
///
/// Контракт для виджетов шагов:
/// - шаг рисует только поля (без Scaffold, без прокрутки — их даёт хост);
/// - данные сохраняет сразу при изменении (SPEC §5);
/// - если обязательные поля не заполнены — вызывает `StepScope.of(context).setCanProceed(false)`;
/// - [editing] = true в настройках: можно скрыть вводный текст.
class StepController extends ChangeNotifier {
  StepController({required this.editing});

  final bool editing;
  bool _canProceed = true;

  bool get canProceed => _canProceed;

  void setCanProceed(bool value) {
    if (_canProceed == value) return;
    _canProceed = value;
    // Шаги зовут это из build — уведомляем после кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}

class StepScope extends InheritedNotifier<StepController> {
  const StepScope({super.key, required StepController controller, required super.child})
      : super(notifier: controller);

  static StepController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<StepScope>();
    assert(scope != null, 'StepScope не найден: шаг анкеты должен рендериться внутри хоста');
    return scope!.notifier!;
  }

  /// Для тестов и предпросмотра шага вне хоста.
  static StepController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<StepScope>()?.notifier;
}
