// Ручной ввод/изменение операции: расход, доход, перевод.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';

class TxEditScreen extends ConsumerStatefulWidget {
  const TxEditScreen({super.key, this.kind = FinTxKind.expense, this.existing, this.accountId});

  final FinTxKind kind;
  final FinTransactionRow? existing;
  final String? accountId;

  static Future<void> open(BuildContext context, {FinTxKind kind = FinTxKind.expense, FinTransactionRow? existing, String? accountId}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => TxEditScreen(kind: kind, existing: existing, accountId: accountId),
      ));

  @override
  ConsumerState<TxEditScreen> createState() => _TxEditScreenState();
}

class _TxEditScreenState extends ConsumerState<TxEditScreen> {
  late FinTxKind _kind = widget.existing == null ? widget.kind : FinTxKind.values.byName(widget.existing!.kind);
  late num? _amount = widget.existing == null ? null : toMajor(widget.existing!.amount);
  late num? _toAmount = widget.existing?.toAmount == null ? null : toMajor(widget.existing!.toAmount!);
  late String? _accountId = widget.existing?.accountId ?? widget.accountId;
  late String? _toAccountId = widget.existing?.toAccountId;
  late String? _categoryId = widget.existing?.categoryId;
  late DateTime _date = widget.existing?.occurredAt ?? DateTime.now();
  late String _merchant = widget.existing?.merchant ?? '';
  late String _note = widget.existing?.note ?? '';
  bool _tried = false;
  bool _saving = false;

  bool get _isNew => widget.existing == null;

  List<FinAccountRow> _accounts() =>
      (ref.read(finAccountsProvider).value ?? const <FinAccountRow>[])
          .where((a) => !a.archived && a.kind != FinAccountKind.crypto.name)
          .toList();

  Future<void> _pickAccount({required bool to}) async {
    final l = AppLocalizations.of(context);
    final id = await pickFin<String>(
      context,
      title: to ? l.finToAccount : l.finAccount,
      selected: to ? _toAccountId : _accountId,
      choices: [
        for (final a in _accounts())
          if (!to || a.id != _accountId) SysChoice(a.id, '${accountTitle(l, a)} · ${a.currency}', glyph: accountGlyph(a.kind)),
      ],
    );
    if (id != null) setState(() => to ? _toAccountId = id : _accountId = id);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    setState(() => _tried = true);
    final amount = _amount;
    final accounts = {for (final a in _accounts()) a.id: a};
    final acc = accounts[_accountId];
    if (amount == null || amount <= 0) return;
    // Без счетов расход/доход можно записать — журнал создаст «Наличные RUB».
    if (acc == null && (accounts.isNotEmpty || _kind == FinTxKind.transfer || widget.existing != null)) return;
    if (_kind == FinTxKind.transfer && (accounts[_toAccountId] == null || _toAccountId == _accountId)) return;
    setState(() => _saving = true);
    final ledger = ref.read(financeLedgerImplProvider);
    try {
      final minor = toMinor(amount);
      final to = accounts[_toAccountId];
      final toMinorAmount = _kind == FinTxKind.transfer && acc != null && to != null && to.currency != acc.currency && _toAmount != null
          ? toMinor(_toAmount!)
          : null;
      final existing = widget.existing;
      if (existing != null && acc != null) {
        await ledger.update(existing.copyWith(
          kind: _kind.name,
          accountId: acc.id,
          toAccountId: Value(_kind == FinTxKind.transfer ? _toAccountId : null),
          amount: minor,
          currency: acc.currency,
          toAmount: Value(toMinorAmount),
          categoryId: Value(_kind == FinTxKind.transfer ? null : _categoryId),
          occurredAt: _date,
          merchant: Value(_merchant.trim().isEmpty ? null : _merchant.trim()),
          note: Value(_note.trim().isEmpty ? null : _note.trim()),
        ));
      } else if (_kind == FinTxKind.transfer && acc != null) {
        await ledger.addTransfer(
          fromAccountId: acc.id,
          toAccountId: _toAccountId!,
          amount: minor,
          currency: acc.currency,
          toAmount: toMinorAmount,
          occurredAt: _date,
          note: _note,
        );
      } else {
        await ledger.add(TxDraft(
          kind: _kind,
          amount: minor,
          currency: acc?.currency ?? 'RUB',
          occurredAt: _date,
          source: FinTxSource.manual,
          accountId: acc?.id,
          categoryId: _categoryId,
          merchant: _merchant,
          note: _note,
        ));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) finSnack(context, l.finSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final e = widget.existing;
    if (e == null || !await confirmFinDelete(context, l.finTxDeleteConfirm)) return;
    await ref.read(financeRepositoryProvider).deleteTransaction(e);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accounts = (ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[])
        .where((a) => !a.archived && a.kind != FinAccountKind.crypto.name)
        .toList();
    final byId = {for (final a in accounts) a.id: a};
    if (_accountId == null && accounts.isNotEmpty) _accountId = accounts.first.id;
    final acc = byId[_accountId];
    final to = byId[_toAccountId];
    final cats = (ref.watch(finCategoriesProvider).value ?? const <FinCategoryRow>[])
        .where((c) => !c.archived && c.kind == (_kind == FinTxKind.income ? 'income' : 'expense'))
        .toList();
    final now = DateTime.now();
    final amountErr = _tried && (_amount == null || _amount! <= 0) ? l.commonRequired : null;

    return ScheduleSubPage(
      title: _isNew ? l.finTxNew : l.finTxEdit,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: Row(children: [
        if (!_isNew) ...[
          Expanded(child: SysButton.danger(label: l.commonDelete, expand: true, onPressed: _delete)),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: SysButton.primary(
            key: const Key('fin-tx-save'),
            label: l.commonSave,
            expand: true,
            onPressed: _saving ? null : _save,
          ),
        ),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<FinTxKind>(
            choices: [for (final k in FinTxKind.values) SysChoice(k, txKindLabel(l, k))],
            value: _kind,
            onChanged: (k) => setState(() {
              _kind = k;
              _categoryId = null;
            }),
          ),
          const SysFieldGap(),
          SysNumberField(
            key: const Key('fin-tx-amount'),
            value: _amount,
            label: l.finAmount,
            unit: currencySymbol(acc?.currency ?? 'RUB'),
            min: 0.01,
            outOfRangeText: amountErr,
            onChanged: (v) => setState(() => _amount = v),
          ),
          if (amountErr != null) Text(amountErr, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
          const SysFieldGap(),
          SysPickerField(
            label: _kind == FinTxKind.transfer ? l.finFromAccount : l.finAccount,
            text: acc == null ? null : '${accountTitle(l, acc)} · ${acc.currency}',
            placeholder: accounts.isEmpty ? l.finNoAccountsAuto : l.finChoose,
            glyph: SysGlyph.wallet,
            onTap: () => _pickAccount(to: false),
          ),
          if (accounts.isEmpty) Text(l.finNoAccountsAutoHint, style: SysText.caption),
          if (_kind == FinTxKind.transfer) ...[
            const SysFieldGap(),
            SysPickerField(
              label: l.finToAccount,
              text: to == null ? null : '${accountTitle(l, to)} · ${to.currency}',
              placeholder: l.finChoose,
              glyph: SysGlyph.wallet,
              onTap: () => _pickAccount(to: true),
            ),
            if (_tried && (to == null || _toAccountId == _accountId))
              Text(l.finTransferNeedsTwo, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
            if (to != null && acc != null && to.currency != acc.currency) ...[
              const SysFieldGap(),
              SysNumberField(
                value: _toAmount,
                label: l.finToAmount,
                unit: currencySymbol(to.currency),
                onChanged: (v) => setState(() => _toAmount = v),
              ),
              Text(l.finToAmountHint, style: SysText.caption),
            ],
          ] else ...[
            const SysFieldGap(),
            SysFieldLabel(l.finCategory, hint: _categoryId == null ? l.finCategoryAutoHint : null),
            SysChoiceChips<String>(
              choices: [for (final c in cats) SysChoice(c.id, categoryName(l, c), glyph: categoryGlyph(c))],
              selected: {?_categoryId},
              onChanged: (s) => setState(() => _categoryId = s.isEmpty ? null : s.first),
            ),
            const SysFieldGap(),
            SysTextField(
              value: _merchant,
              label: _kind == FinTxKind.income ? l.finPayer : l.finMerchant,
              onChanged: (v) => _merchant = v,
            ),
          ],
          const SysFieldGap(),
          Row(children: [
            Expanded(
              child: SysDateField(
                label: l.finDate,
                date: _date,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 1, 12, 31),
                onChanged: (d) => setState(() => _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SysTimeField(
                label: l.finTime,
                minute: _date.hour * 60 + _date.minute,
                onChanged: (m) => setState(() => _date = DateTime(_date.year, _date.month, _date.day, m ~/ 60, m % 60)),
              ),
            ),
          ]),
          const SysFieldGap(),
          SysTextField(value: _note, label: l.finNote, maxLines: 3, onChanged: (v) => _note = v),
          if (widget.existing case final e?) ...[
            const SysFieldGap(),
            Text('${l.finSource}: ${sourceLabel(l, e.source)}', style: SysText.caption),
          ],
        ],
      ),
    );
  }
}
