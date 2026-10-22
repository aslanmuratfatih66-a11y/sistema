// Список операций с фильтрами: счёт, категория, период.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';
import 'tx_edit_screen.dart';

enum TxPeriodFilter { week, month, all }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.accountId, this.categoryId});

  final String? accountId;
  final String? categoryId;

  static Future<void> open(BuildContext context, {String? accountId, String? categoryId}) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => TransactionsScreen(accountId: accountId, categoryId: categoryId)));

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late String? _accountId = widget.accountId;
  late String? _categoryId = widget.categoryId;
  TxPeriodFilter _period = TxPeriodFilter.month;
  int _limit = 100;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final accounts = ref.watch(finAccountMapProvider);
    final cats = ref.watch(finCategoryMapProvider);
    final now = DateTime.now();
    final from = switch (_period) {
      TxPeriodFilter.week => periodRange(FinPeriod.week, now).start,
      TxPeriodFilter.month => periodRange(FinPeriod.month, now).start,
      TxPeriodFilter.all => null,
    };
    final shown = [
      for (final t in txs)
        if ((from == null || !t.occurredAt.isBefore(from)) &&
            (_accountId == null || t.accountId == _accountId || t.toAccountId == _accountId) &&
            (_categoryId == null || t.categoryId == _categoryId))
          t,
    ];

    return ScheduleSubPage(
      title: l.finOperations,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: SysButton.primary(
        label: l.finAddOperation,
        icon: SysGlyph.plus,
        expand: true,
        onPressed: () => TxEditScreen.open(context, accountId: _accountId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<TxPeriodFilter>(
            choices: [
              SysChoice(TxPeriodFilter.week, l.finPeriodWeek),
              SysChoice(TxPeriodFilter.month, l.finPeriodMonth),
              SysChoice(TxPeriodFilter.all, l.finPeriodAll),
            ],
            value: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: SysPickerField(
                label: l.finAccount,
                text: _accountId == null ? l.finAll : accountTitle(l, accounts[_accountId]),
                glyph: SysGlyph.wallet,
                onTap: () async {
                  final v = await pickFin<String>(context, title: l.finAccount, selected: _accountId ?? '', choices: [
                    SysChoice('', l.finAll),
                    for (final a in accounts.values) SysChoice(a.id, accountTitle(l, a), glyph: accountGlyph(a.kind)),
                  ]);
                  if (v != null) setState(() => _accountId = v.isEmpty ? null : v);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SysPickerField(
                label: l.finCategory,
                text: _categoryId == null ? l.finAll : categoryName(l, cats[_categoryId]),
                glyph: SysGlyph.star,
                onTap: () async {
                  final v = await pickFin<String>(context, title: l.finCategory, selected: _categoryId ?? '', choices: [
                    SysChoice('', l.finAll),
                    for (final c in cats.values) SysChoice(c.id, categoryName(l, c), glyph: categoryGlyph(c)),
                  ]);
                  if (v != null) setState(() => _categoryId = v.isEmpty ? null : v);
                },
              ),
            ),
          ]),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finOperationsCount(shown.length),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (shown.isEmpty) FinEmpty(l.finNoOperations),
                for (final t in shown.take(_limit)) TxTile(tx: t, accounts: accounts, categories: cats),
                if (shown.length > _limit)
                  FinActions(children: [
                    SysButton.secondary(label: l.finShowMore, onPressed: () => setState(() => _limit += 100)),
                  ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка операции.
class TxTile extends StatelessWidget {
  const TxTile({super.key, required this.tx, required this.accounts, required this.categories});

  final FinTransactionRow tx;
  final Map<String, FinAccountRow> accounts;
  final Map<String, FinCategoryRow> categories;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = tx;
    final kind = FinTxKind.values.byName(t.kind);
    final cat = t.categoryId == null ? null : categories[t.categoryId];
    final title = switch (kind) {
      FinTxKind.transfer => '${accountTitle(l, accounts[t.accountId])} → ${accountTitle(l, accounts[t.toAccountId])}',
      _ => t.merchant ?? categoryName(l, cat),
    };
    final sub = [
      formatTxTime(t.occurredAt),
      if (kind != FinTxKind.transfer) categoryName(l, cat),
      if (kind != FinTxKind.transfer) accountTitle(l, accounts[t.accountId]),
      if (t.source != FinTxSource.manual.name) sourceLabel(l, t.source),
    ].join(' · ');
    final (sign, color) = switch (kind) {
      FinTxKind.income => (1, SysColors.success),
      FinTxKind.expense => (-1, SysColors.textPrimary),
      FinTxKind.transfer => (0, SysColors.textCaption),
    };
    return FinTile(
      title: title,
      subtitle: sub,
      glyph: kind == FinTxKind.transfer ? SysGlyph.send : categoryGlyph(cat),
      glyphColor: cat?.junkFood == true ? SysColors.gold : SysColors.accentLight,
      trailing: formatMoney(sign == 0 ? t.amount : sign * t.amount, t.currency, sign: sign > 0),
      trailingColor: color,
      onTap: () => TxEditScreen.open(context, existing: t),
    );
  }
}
