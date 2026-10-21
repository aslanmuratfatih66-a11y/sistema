import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/questionnaire_repository.dart';
import '../../../../core/models/enums.dart';

/// Общая основа шагов анкеты B, хранящих данные в JSON-разделе.
///
/// Раздел читается один раз при открытии шага, дальше локальное состояние —
/// источник правды для UI, а каждое изменение сразу пишется в БД (`patch`).
/// Записи выполняются строго по очереди, чтобы быстрые нажатия не затирали друг друга.
abstract class SectionStepState<W extends ConsumerStatefulWidget> extends ConsumerState<W> {
  QuestionnaireSection get section;

  /// Текущее содержимое раздела (после загрузки).
  Map<String, Object?> data = {};
  bool loaded = false;

  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    ref.read(questionnaireRepositoryProvider).read(section).then((d) {
      if (!mounted) return;
      setState(() {
        data = d;
        loaded = true;
      });
      final defaults = initialDefaults(d);
      if (defaults.isNotEmpty) setValues(defaults);
      onLoaded();
    });
  }

  /// Значения по умолчанию, которые нужно записать, если их ещё нет.
  Map<String, Object?> initialDefaults(Map<String, Object?> current) => const {};

  /// Вызывается после загрузки раздела.
  void onLoaded() {}

  void setValue(String key, Object? value) => setValues({key: value});

  /// Обновляет несколько ключей разом (null удаляет ключ).
  void setValues(Map<String, Object?> values) {
    setState(() {
      for (final e in values.entries) {
        if (e.value == null) {
          data.remove(e.key);
        } else {
          data[e.key] = e.value;
        }
      }
    });
    final repo = ref.read(questionnaireRepositoryProvider);
    final copy = Map<String, Object?>.of(values);
    _queue = _queue.then((_) => repo.patch(section, copy)).catchError((Object e) {
      debugPrint('Ошибка сохранения раздела ${section.name}: $e');
    });
  }

  /// Дождаться завершения всех записей (для тестов).
  Future<void> flush() => _queue;

  String str(String key) => data[key] is String ? data[key]! as String : '';
  num? numOf(String key) => data[key] is num ? data[key]! as num : null;
  int? intOf(String key) => numOf(key)?.round();

  List<String> strList(String key) {
    final v = data[key];
    return v is List ? [for (final e in v) if (e is String) e] : <String>[];
  }

  List<int> intList(String key) {
    final v = data[key];
    return v is List ? [for (final e in v) if (e is num) e.round()] : <int>[];
  }

  List<Map<String, Object?>> mapList(String key) {
    final v = data[key];
    return v is List ? [for (final e in v) if (e is Map) Map<String, Object?>.from(e)] : <Map<String, Object?>>[];
  }
}

/// Пустое место, пока раздел загружается.
class SectionLoading extends StatelessWidget {
  const SectionLoading({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 120);
}

/// Вводный текст шага (скрывается при редактировании из настроек).
class StepIntro extends StatelessWidget {
  const StepIntro(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(text, style: style));
}
