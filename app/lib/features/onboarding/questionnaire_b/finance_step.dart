import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'common/section_state.dart';
import 'finance/finance_item_sheet.dart';

/// Этап 10 — финансы (раздел finance). Всё необязательно.
class FinanceStep extends ConsumerStatefulWidget {
  const FinanceStep({super.key});

  @override
  ConsumerState<FinanceStep> createState() => _FinanceStepState();
}

class _FinanceStepState extends SectionStepState<FinanceStep> {
  @override
  QuestionnaireSection get section => QuestionnaireSection.finance;

  @override
  Map<String, Object?> initialDefaults(Map<String, Object?> current) =>
      current['currencies'] is List ? const {} : const {'currencies': ['RUB']};

  Future<void> _edit(FinanceList list, [Map<String, Object?>? item]) async {
    final result = await showFinanceItemSheet(context, list, initial: item);
    if (result == null || !mounted) return;
    final items = mapList(list.name);
    final i = items.indexWhere((e) => e['id'] == result['id']);
    if (i >= 0) {
      items[i] = result;
    } else {
      items.add(result);
    }
    setValue(list.name, items);
  }

  void _delete(FinanceList list, String id) =>
      setValue(list.name, mapList(list.name).where((e) => e['id'] != id).toList());

  static String _money(Object? amount, Object? currency) {
    final a = amount is num ? SysNumberField.format(amount) : '—';
    return currency is String && currency.isNotEmpty ? '$a $currency' : a;
  }

  String _primary(AppLocalizations l, FinanceList list, Map<String, Object?> e) {
    String s(String k) => e[k] is String ? (e[k]! as String) : '';
    switch (list) {
      case FinanceList.incomes:
        final kind = financeIncomeKindLabel(l, s('kind'));
        return s('title').isEmpty ? kind : '$kind · ${s('title')}';
      case FinanceList.accounts:
        if (s('kind') == 'cash') return l.qbFinCash;
        return s('bank').isEmpty ? l.qbFinCard : '${l.qbFinCard} · ${s('bank')}';
      case FinanceList.crypto:
        return s('symbol').isEmpty ? '—' : s('symbol');
      case FinanceList.debts:
        final dir = s('direction') == 'oweMe' ? l.qbFinOweMe : l.qbFinIOwe;
        return s('person').isEmpty ? dir : '$dir · ${s('person')}';
    }
  }

  String? _secondary(AppLocalizations l, FinanceList list, Map<String, Object?> e) {
    switch (list) {
      case FinanceList.incomes:
        final day = e['dayOfMonth'];
        return day is num ? l.qbFinDayOfMonthShort(day.round()) : null;
      case FinanceList.debts:
        final due = e['dueDate'] is String ? DateTime.tryParse(e['dueDate']! as String) : null;
        return due == null ? null : l.qbFinDueShort(SysDateField.format(due));
      case FinanceList.accounts:
      case FinanceList.crypto:
        return null;
    }
  }

  String _amountText(FinanceList list, Map<String, Object?> e) => switch (list) {
        FinanceList.accounts => _money(e['balance'], e['currency']),
        FinanceList.crypto => e['amount'] is num ? SysNumberField.format(e['amount']! as num) : '—',
        _ => _money(e['amount'], e['currency']),
      };

  Widget _listBlock(AppLocalizations l, FinanceList list, String title, String addLabel, {String? hint}) {
    final items = mapList(list.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysFieldLabel(title, hint: hint, optional: true, optionalLabel: l.commonOptional),
        for (final e in items)
          _ItemRow(
            key: ValueKey('qbFinanceItem_${e['id']}'),
            primary: _primary(l, list, e),
            secondary: _secondary(l, list, e),
            amount: _amountText(list, e),
            editLabel: l.commonEdit,
            deleteLabel: l.commonDelete,
            deleteKey: ValueKey('qbFinanceDelete_${e['id']}'),
            onEdit: () => _edit(list, e),
            onDelete: () => _delete(list, e['id'].toString()),
          ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: SysButton.secondary(
            key: ValueKey('qbFinanceAdd_${list.name}'),
            label: addLabel,
            icon: SysGlyph.plus,
            onPressed: () => _edit(list),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = StepScope.maybeOf(context)?.editing ?? false;
    if (!loaded) return const SectionLoading();

    final currencies = strList('currencies').toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbFinanceIntro, style: SysText.secondary),
        _listBlock(l, FinanceList.incomes, l.qbFinIncomes, l.qbFinAddIncome, hint: l.qbFinIncomesHint),
        const SysFieldGap(),
        _listBlock(l, FinanceList.accounts, l.qbFinAccounts, l.qbFinAddAccount),
        const SysFieldGap(),
        SysFieldLabel(l.qbFinCurrencies, hint: l.qbFinCurrenciesHint),
        SysChoiceChips<String>(
          multi: true,
          choices: [for (final c in financeCurrencies) SysChoice(c, c)],
          selected: currencies,
          onChanged: (s) {
            // RUB — базовая валюта отчётов, всегда остаётся.
            setValue('currencies', [for (final c in financeCurrencies) if (c == 'RUB' || s.contains(c)) c]);
          },
        ),
        const SysFieldGap(),
        _listBlock(l, FinanceList.crypto, l.qbFinCrypto, l.qbFinAddCrypto, hint: l.qbFinCryptoRateNote),
        const SysFieldGap(),
        _listBlock(l, FinanceList.debts, l.qbFinDebts, l.qbFinAddDebt),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    super.key,
    required this.primary,
    required this.secondary,
    required this.amount,
    required this.editLabel,
    required this.deleteLabel,
    required this.deleteKey,
    required this.onEdit,
    required this.onDelete,
  });

  final String primary;
  final String? secondary;
  final String amount;
  final String editLabel;
  final String deleteLabel;
  final Key deleteKey;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final sec = secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SysColors.accent.withValues(alpha: .06),
          border: Border.all(color: SysColors.accent.withValues(alpha: .35)),
          borderRadius: BorderRadius.circular(SysDims.radius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: true,
                hint: editLabel,
                child: InkWell(
                  onTap: onEdit,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: SysDims.minTap),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(primary, style: SysText.body),
                                if (sec != null) Text(sec, style: SysText.caption),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(amount, style: SysText.mono),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              key: deleteKey,
              tooltip: deleteLabel,
              constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
              onPressed: onDelete,
              icon: const SysIcon(SysGlyph.close, size: 18, color: SysColors.dangerLight),
            ),
          ],
        ),
      ),
    );
  }
}
