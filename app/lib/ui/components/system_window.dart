// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/material.dart';

/// Вид системного сообщения: «[ Уведомление ]», «[ Предупреждение ]», «Квест провален».
enum SystemWindowKind { notice, warning, failed }

/// Системное окно-сообщение. Метку задаёт вызывающий (локализованную),
/// например «Уведомление» — компонент сам обрамляет её в «[ … ]».
class SystemWindow extends StatelessWidget {
  const SystemWindow({
    super.key,
    required this.kind,
    required this.label,
    required this.message,
    this.title,
    this.actions = const [],
  });

  final SystemWindowKind kind;
  final String label;
  final String? title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Text(message);
}

/// Показать системное окно модально (с анимацией появления).
Future<T?> showSystemWindow<T>(BuildContext context, {required SystemWindow window}) =>
    showDialog<T>(context: context, builder: (_) => Center(child: window));
