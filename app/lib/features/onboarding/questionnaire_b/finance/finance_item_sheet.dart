import 'package:flutter/material.dart';

import '../../../../core/db/database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

/// Списки раздела finance (ключ = имя списка в JSON).
enum FinanceList { incomes, accounts, crypto, debts }

/// Валюты, поддерживаемые на старте (SPEC §8.7). RUB — база.
const financeCurrencies = ['RUB', 'TRY', 'USD', 'EUR'];

/// Подсказки банков (названия собственные, не переводятся).
const financeBankSuggestions = ['ВТБ', 'Сбер', 'Т-Банк', 'Альфа', 'Ziraat', 'İş Bankası', 'Garanti'];

const financeIncomeKinds = ['stipend', 'salary', 'transfer', 'other'];

String financeIncomeKindLabel(AppLocalizations l, String kind) => switch (kind) {
      'stipend' => l.qbIncomeStipend,
      'salary' => l.qbIncomeSalary,
      'transfer' => l.qbIncomeTransfer,
      _ => l.qbIncomeOther,
    };

/// Дата долга в JSON — ISO `yyyy-MM-dd`.
String financeIsoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Открывает нижний лист редактирования элемента. Возвращает готовый JSON-элемент или null (отмена).
Future<Map<String, Object?>?> showFinanceItemSheet(
  BuildContext context,
  FinanceList list, {
  Map<String, Object?>? initial,
}) =>
    showModalBottomSheet<Map<String, Object?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (c) => FinanceItemSheet(list: list, initial: initial),
    );

class FinanceItemSheet extends StatefulWidget {
  const FinanceItemSheet({super.key, required this.list, this.initial});

  final FinanceList list;
  final Map<String, Object?>? initial;

  @override
  State<FinanceItemSheet> createState() => _FinanceItemSheetState();
}

class _FinanceItemSheetState extends State<FinanceItemSheet> {
  late final Map<String, Object?> _d = {
    ..._defaults(widget.list),
    ...?widget.initial,
  };

  static Map<String, Object?> _defaults(FinanceList list) => switch (list) {
        FinanceList.incomes => {
            'kind': 'stipend',
            'title': '',
            'amount': null,
            'currency': 'RUB',
            'dayOfMonth': null,
          },
        FinanceList.accounts => {'kind': 'card', 'bank': '', 'currency': 'RUB', 'balance': null},
        FinanceList.crypto => {'symbol': '', 'amount': null},
        FinanceList.debts => {
            'direction': 'iOwe',
            'person': '',
            'amount': null,
            'currency': 'RUB',
            'dueDate': null,
          },
      };

  void _set(String k, Object? v) => setState(() => _d[k] = v);

  String _s(String k) => _d[k] is String ? _d[k]! as String : '';
  num? _n(String k) => _d[k] is num ? _d[k]! as num : null;

  Map<String, Object?> _result() {
    final r = <String, Object?>{'id': (_d['id'] as String?) ?? newId()};
    for (final k in _defaults(widget.list).keys) {
      var v = _d[k];
      if (v is String) v = v.trim();
      r[k] = v;
    }
    if (widget.list == FinanceList.crypto) r['symbol'] = (r['symbol'] as String).toUpperCase();
    if (widget.list == FinanceList.accounts && r['kind'] == 'cash') r['bank'] = '';
    return r;
  }

  String _title(AppLocalizations l) => switch (widget.list) {
        FinanceList.incomes => l.qbFinIncome,
        FinanceList.accounts => l.qbFinAccount,
        FinanceList.crypto => l.qbFinCryptoItem,
        FinanceList.debts => l.qbFinDebt,
      };

  Widget _currency() => SysSegmented<String>(
        choices: [for (final c in financeCurrencies) SysChoice(c, c)],
        value: _s('currency'),
        onChanged: (v) => _set('currency', v),
      );

  Widget _amount(AppLocalizations l, String key, String label) => SysNumberField(
        key: const ValueKey('qbFinanceAmount'),
        value: _n(key),
        label: label,
        onChanged: (v) => _set(key, v),
      );

  List<Widget> _fields(AppLocalizations l) {
    switch (widget.list) {
      case FinanceList.incomes:
        return [
          SysFieldLabel(l.qbFinIncomeKind),
          SysChoiceChips<String>(
            choices: [for (final k in financeIncomeKinds) SysChoice(k, financeIncomeKindLabel(l, k))],
            selected: {_s('kind')},
            allowEmpty: false,
            onChanged: (s) => _set('kind', s.first),
          ),
          const SysFieldGap(),
          SysTextField(value: _s('title'), label: l.qbFinTitle, onChanged: (v) => _set('title', v)),
          const SysFieldGap(),
          _amount(l, 'amount', l.qbFinAmount),
          const SizedBox(height: 8),
          _currency(),
          const SysFieldGap(),
          SysNumberField(
            value: _n('dayOfMonth'),
            label: l.qbFinDayOfMonth,
            decimal: false,
            min: 1,
            max: 31,
            outOfRangeText: l.commonOutOfRange,
            onChanged: (v) => _set('dayOfMonth', v?.round()),
          ),
        ];
      case FinanceList.accounts:
        final isCard = _s('kind') == 'card';
        return [
          SysSegmented<String>(
            choices: [SysChoice('cash', l.qbFinCash), SysChoice('card', l.qbFinCard)],
            value: _s('kind'),
            onChanged: (v) => _set('kind', v),
          ),
          if (isCard) ...[
            const SysFieldGap(),
            SysTextField(value: _s('bank'), label: l.qbFinBank, onChanged: (v) => _set('bank', v)),
            const SizedBox(height: 8),
            SysChoiceChips<String>(
              choices: [for (final b in financeBankSuggestions) SysChoice(b, b)],
              selected: {if (financeBankSuggestions.contains(_s('bank'))) _s('bank')},
              onChanged: (s) {
                FocusScope.of(context).unfocus();
                _set('bank', s.isEmpty ? '' : s.first);
              },
            ),
          ],
          const SysFieldGap(),
          SysFieldLabel(l.qbFinCurrency),
          _currency(),
          const SysFieldGap(),
          _amount(l, 'balance', l.qbFinBalance),
        ];
      case FinanceList.crypto:
        return [
          SysTextField(
            value: _s('symbol'),
            label: l.qbFinCryptoSymbol,
            hint: 'BTC',
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) => _set('symbol', v),
          ),
          const SysFieldGap(),
          _amount(l, 'amount', l.qbFinCryptoAmount),
          const SizedBox(height: 8),
          Text(l.qbFinCryptoRateNote, style: SysText.caption),
        ];
      case FinanceList.debts:
        final due = DateTime.tryParse(_s('dueDate'));
        return [
          SysSegmented<String>(
            choices: [SysChoice('iOwe', l.qbFinIOwe), SysChoice('oweMe', l.qbFinOweMe)],
            value: _s('direction'),
            onChanged: (v) => _set('direction', v),
          ),
          const SysFieldGap(),
          SysTextField(
            value: _s('person'),
            label: _s('direction') == 'oweMe' ? l.qbFinDebtWho : l.qbFinDebtToWhom,
            onChanged: (v) => _set('person', v),
          ),
          const SysFieldGap(),
          _amount(l, 'amount', l.qbFinAmount),
          const SizedBox(height: 8),
          _currency(),
          const SysFieldGap(),
          Row(
            children: [
              Expanded(
                child: SysDateField(
                  date: due,
                  label: l.qbFinDueDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  onChanged: (d) => _set('dueDate', financeIsoDate(d)),
                ),
              ),
              if (due != null)
                IconButton(
                  tooltip: l.qbFinClearDate,
                  onPressed: () => _set('dueDate', null),
                  icon: const SysIcon(SysGlyph.close, size: 18),
                ),
            ],
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SysPanelHeader(title: _title(l)),
              const SizedBox(height: 12),
              ..._fields(l),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SysButton.secondary(
                      label: l.commonCancel,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SysButton.primary(
                      key: const ValueKey('qbFinanceSave'),
                      label: l.commonSave,
                      expand: true,
                      onPressed: () => Navigator.of(context).pop(_result()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
