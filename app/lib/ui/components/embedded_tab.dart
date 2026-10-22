import 'package:flutter/widgets.dart';

/// Метка «страница показана внутри вкладки с переключателем» (Здоровье, Магазин).
/// Обёртки страниц (ScheduleSubPage, WorkoutPage и т.п.) в этом режиме не рисуют свой
/// Scaffold и кнопку «назад» — только прокручиваемое содержимое.
class EmbeddedTab extends InheritedWidget {
  const EmbeddedTab({super.key, required super.child});

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<EmbeddedTab>() != null;

  @override
  bool updateShouldNotify(EmbeddedTab oldWidget) => false;
}

/// Содержимое встроенной страницы: прокрутка с отступами вкладки, нижняя панель (если есть) — под ней.
class EmbeddedTabBody extends StatelessWidget {
  const EmbeddedTabBody({super.key, required this.child, this.bottom, this.actions = const []});

  final Widget child;
  final Widget? bottom;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final b = bottom;
    return Column(
      children: [
        if (actions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ),
        Expanded(
          child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), child: child),
        ),
        if (b != null) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: b),
      ],
    );
  }
}
