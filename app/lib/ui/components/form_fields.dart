import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'sys_icon.dart';

/// Подпись поля / группы полей (Oswald, капс) + необязательная подсказка.
class SysFieldLabel extends StatelessWidget {
  const SysFieldLabel(this.text, {super.key, this.hint, this.optional = false, this.optionalLabel});

  final String text;
  final String? hint;
  final bool optional;

  /// Текст пометки «необязательно» (из l10n вызывающего).
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    final opt = optionalLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(text: text.toUpperCase(), style: SysText.label.copyWith(color: SysColors.accentLight)),
              if (optional && opt != null)
                TextSpan(text: '  · $opt', style: SysText.caption.copyWith(color: SysColors.textInactive)),
            ]),
          ),
          if (h != null) ...[const SizedBox(height: 2), Text(h, style: SysText.caption)],
        ],
      ),
    );
  }
}

/// Отступ между полями анкеты.
class SysFieldGap extends StatelessWidget {
  const SysFieldGap({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}

/// Текстовое поле. Хранит свой контроллер; внешнее [value] подхватывает, пока поле не в фокусе.
class SysTextField extends StatefulWidget {
  const SysTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final int maxLines;
  final TextCapitalization textCapitalization;
  final String? errorText;

  @override
  State<SysTextField> createState() => _SysTextFieldState();
}

class _SysTextFieldState extends State<SysTextField> {
  late final TextEditingController _c = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(SysTextField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        focusNode: _focus,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        minLines: 1,
        textCapitalization: widget.textCapitalization,
        style: widget.keyboardType == TextInputType.number ||
                widget.keyboardType == const TextInputType.numberWithOptions(decimal: true)
            ? SysText.mono.copyWith(fontSize: 15)
            : SysText.body,
        cursorColor: SysColors.accentLight,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixText: widget.suffix,
          suffixStyle: SysText.secondary,
          errorText: widget.errorText,
        ),
      );
}

/// Числовое поле (вес, рост, обхваты…). Пустое → null. Запятая и точка допустимы.
class SysNumberField extends StatelessWidget {
  const SysNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.unit,
    this.decimal = true,
    this.min,
    this.max,
    this.outOfRangeText,
  });

  final num? value;
  final ValueChanged<num?> onChanged;
  final String? label;
  final String? unit;
  final bool decimal;
  final num? min;
  final num? max;

  /// Текст ошибки, если значение вне [min]..[max] (из l10n вызывающего).
  final String? outOfRangeText;

  static num? parse(String s, {bool decimal = true}) {
    final t = s.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return decimal ? double.tryParse(t) : int.tryParse(t);
  }

  static String format(num? v) {
    if (v == null) return '';
    if (v is int || v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  bool _inRange(num? v) => v == null || ((min == null || v >= min!) && (max == null || v <= max!));

  @override
  Widget build(BuildContext context) => SysTextField(
        value: format(value),
        label: label,
        suffix: unit,
        keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]'))],
        errorText: _inRange(value) ? null : outOfRangeText,
        onChanged: (s) => onChanged(parse(s, decimal: decimal)),
      );
}

/// Вариант для [SysChoiceChips] / [SysSegmented].
class SysChoice<T> {
  const SysChoice(this.value, this.label, {this.glyph});
  final T value;
  final String label;
  final SysGlyph? glyph;
}

/// Чипы выбора: одиночный (`selected` из одного элемента) или множественный выбор.
class SysChoiceChips<T> extends StatelessWidget {
  const SysChoiceChips({
    super.key,
    required this.choices,
    required this.selected,
    required this.onChanged,
    this.multi = false,
    this.allowEmpty = true,
  });

  final List<SysChoice<T>> choices;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final bool multi;

  /// Для одиночного выбора: можно ли снять выбор повторным нажатием.
  final bool allowEmpty;

  void _tap(T v) {
    final on = selected.contains(v);
    if (multi) {
      onChanged(on ? ({...selected}..remove(v)) : {...selected, v});
    } else if (on) {
      if (allowEmpty) onChanged(<T>{});
    } else {
      onChanged({v});
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final c in choices) _Chip(choice: c, selected: selected.contains(c.value), onTap: () => _tap(c.value))],
      );
}

class _Chip<T> extends StatelessWidget {
  const _Chip({required this.choice, required this.selected, required this.onTap});

  final SysChoice<T> choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? SysColors.textPrimary : SysColors.textSecondary;
    final g = choice.glyph;
    return Semantics(
      button: true,
      selected: selected,
      label: choice.label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SysDims.minTap),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SysDims.radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SysDims.radius),
                color: selected ? SysColors.accent.withValues(alpha: .22) : SysColors.accent.withValues(alpha: .05),
                border: Border.all(color: selected ? SysColors.accentLight : SysColors.accent.withValues(alpha: .35)),
                boxShadow: selected ? const [BoxShadow(color: Color.fromRGBO(63, 180, 255, .30), blurRadius: 10)] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[const SysIcon(SysGlyph.check, size: 14, color: SysColors.accentLighter), const SizedBox(width: 6)]
                  else if (g != null) ...[SysIcon(g, size: 14, color: fg), const SizedBox(width: 6)],
                  Flexible(child: Text(choice.label, style: SysText.body.copyWith(color: fg))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Сегментированный переключатель на 2–4 варианта (одиночный выбор, всегда выбран один или ни одного).
class SysSegmented<T> extends StatelessWidget {
  const SysSegmented({super.key, required this.choices, required this.value, required this.onChanged});

  final List<SysChoice<T>> choices;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SysDims.radius),
          border: Border.all(color: SysColors.accent.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            for (final c in choices)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: c.value == value,
                  label: c.label,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onChanged(c.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      constraints: const BoxConstraints(minHeight: SysDims.minTap),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      color: c.value == value ? SysColors.accent.withValues(alpha: .24) : Colors.transparent,
                      child: Text(
                        c.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: SysText.label.copyWith(
                          color: c.value == value ? SysColors.textPrimary : SysColors.textCaption,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Строка-переключатель (вкл/выкл) с подписью и подсказкой.
class SysSwitchRow extends StatelessWidget {
  const SysSwitchRow({super.key, required this.label, required this.value, required this.onChanged, this.hint});

  final String label;
  final String? hint;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: SysText.body),
                    if (h != null) Text(h, style: SysText.caption),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: SysColors.accentLighter,
                activeTrackColor: SysColors.accent.withValues(alpha: .55),
                inactiveThumbColor: SysColors.textInactive,
                inactiveTrackColor: SysColors.accent.withValues(alpha: .08),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка-поле, открывающая выбор (время, дата, список). Показывает значение моноширинным шрифтом.
class SysPickerField extends StatelessWidget {
  const SysPickerField({super.key, required this.text, required this.onTap, this.label, this.glyph, this.placeholder});

  final String? text;
  final String? label;
  final String? placeholder;
  final SysGlyph? glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = text;
    final g = glyph;
    return Semantics(
      button: true,
      label: [?label, t ?? placeholder ?? ''].join(': '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SysDims.radius),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          isEmpty: false,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t ?? placeholder ?? '—',
                  style: t == null ? SysText.secondary.copyWith(color: SysColors.textInactive) : SysText.mono.copyWith(fontSize: 15),
                ),
              ),
              if (g != null) SysIcon(g, size: 18, color: SysColors.accentLight),
            ],
          ),
        ),
      ),
    );
  }
}

/// Минута суток → «07:05».
String formatMinuteOfDay(int minute) {
  final m = minute % (24 * 60);
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

/// Поле времени (минута суток 0..1439) с системным выбором времени в 24-часовом формате.
class SysTimeField extends StatelessWidget {
  const SysTimeField({super.key, required this.minute, required this.onChanged, this.label});

  final int? minute;
  final ValueChanged<int> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final m = minute;
    return SysPickerField(
      label: label,
      text: m == null ? null : formatMinuteOfDay(m),
      glyph: SysGlyph.clock,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: (m ?? 480) ~/ 60, minute: (m ?? 480) % 60),
          builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked.hour * 60 + picked.minute);
      },
    );
  }
}

/// Поле даты с системным календарём. Формат — dd.MM.yyyy.
class SysDateField extends StatelessWidget {
  const SysDateField({
    super.key,
    required this.date,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.label,
    this.initialDate,
  });

  final DateTime? date;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final String? label;

  static String format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final d = date;
    return SysPickerField(
      label: label,
      text: d == null ? null : format(d),
      glyph: SysGlyph.clock,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: d ?? initialDate ?? lastDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
