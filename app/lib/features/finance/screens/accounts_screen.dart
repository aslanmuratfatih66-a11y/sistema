// Счета (нал, карты, вклады, крипто-кошельки) и крипто-активы: список, создание, изменение, удаление.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/finance_repository.dart';
import '../data/fx_rates_impl.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';
import 'transactions_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AccountsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final overview = ref.watch(finOverviewProvider);
    final all = ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[];
    final archived = all.where((a) => a.archived).toList();
    final crypto = ref.watch(finCryptoProvider).value ?? const <CryptoHoldingRow>[];
    final rates = ref.watch(finRatesProvider).value;
    final accMap = ref.watch(finAccountMapProvider);
    return ScheduleSubPage(
      title: l.finAccounts,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.finAccounts,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (overview == null || overview.accounts.isEmpty) FinEmpty(l.finNoAccounts),
                for (final v in overview?.accounts ?? const [])
                  FinTile(
                    title: accountTitle(l, v.account),
                    subtitle: [
                      accountKindLabel(l, v.account.kind),
                      if (v.account.cardLast4 != null) '•${v.account.cardLast4}',
                      if (!v.isCrypto && v.account.currency != 'RUB' && v.balanceRub != null) '≈ ${formatRub(v.balanceRub!)}',
                    ].join(' · '),
                    glyph: accountGlyph(v.account.kind),
                    trailing: v.isCrypto ? formatRub(v.balance) : formatMoney(v.balance, v.account.currency),
                    trailingColor: v.balance < 0 ? SysColors.dangerLight : SysColors.textPrimary,
                    onTap: () => AccountEditScreen.open(context, existing: v.account),
                  ),
                FinActions(children: [
                  SysButton.primary(
                    key: const Key('fin-acc-add'),
                    label: l.finAccountAdd,
                    icon: SysGlyph.plus,
                    onPressed: () => AccountEditScreen.open(context),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finCrypto,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (crypto.isEmpty) FinEmpty(l.finCryptoEmpty),
                for (final h in crypto)
                  FinTile(
                    title: '${h.symbol} · ${formatQty(h.amount)}',
                    subtitle: [
                      h.coinId,
                      if (h.accountId != null) accountTitle(l, accMap[h.accountId]),
                    ].join(' · '),
                    glyph: SysGlyph.diamond,
                    trailing: switch (cryptoRub(rates, h.coinId, h.amount)) {
                      final v? => formatRub(v),
                      null => l.finNoRate,
                    },
                    onTap: () => showCryptoSheet(context, ref, existing: h),
                  ),
                Text(l.finCryptoRateNote, style: SysText.caption),
                FinActions(children: [
                  SysButton.secondary(
                    label: l.finCryptoAdd,
                    icon: SysGlyph.plus,
                    onPressed: () => showCryptoSheet(context, ref),
                  ),
                ]),
              ],
            ),
          ),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 14),
            SysPanel(
              title: l.finArchived,
              child: Column(children: [
                for (final a in archived)
                  FinTile(
                    title: accountTitle(l, a),
                    glyph: accountGlyph(a.kind),
                    glyphColor: SysColors.textInactive,
                    onTap: () => AccountEditScreen.open(context, existing: a),
                  ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

class AccountEditScreen extends ConsumerStatefulWidget {
  const AccountEditScreen({super.key, this.existing});

  final FinAccountRow? existing;

  static Future<void> open(BuildContext context, {FinAccountRow? existing}) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => AccountEditScreen(existing: existing)));

  @override
  ConsumerState<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends ConsumerState<AccountEditScreen> {
  late final FinanceRepository _repo = ref.read(financeRepositoryProvider);
  late FinAccountRow _a = widget.existing ?? _repo.newAccount();
  late num? _opening = widget.existing == null ? null : toMajor(widget.existing!.openingBalance);

  void _set(FinAccountRow a) => setState(() => _a = a);

  Future<void> _save() async {
    final last4 = _a.cardLast4?.replaceAll(RegExp(r'\D'), '');
    await _repo.saveAccount(_a.copyWith(
      name: _a.name.trim(),
      openingBalance: toMinor(_opening ?? 0),
      bank: Value(_a.bank?.trim().isEmpty ?? true ? null : _a.bank!.trim()),
      cardLast4: Value(last4 == null || last4.isEmpty ? null : last4.substring(last4.length > 4 ? last4.length - 4 : 0)),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final e = widget.existing;
    if (e == null || !await confirmFinDelete(context, l.finAccountDeleteConfirm)) return;
    await _repo.deleteAccount(e);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isNew = widget.existing == null;
    final kind = _a.kind;
    return ScheduleSubPage(
      title: isNew ? l.finAccountNew : l.finAccountEdit,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: Row(children: [
        if (!isNew) ...[
          Expanded(child: SysButton.danger(label: l.commonDelete, expand: true, onPressed: _delete)),
          const SizedBox(width: 10),
        ],
        Expanded(child: SysButton.primary(key: const Key('fin-acc-save'), label: l.commonSave, expand: true, onPressed: _save)),
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysFieldLabel(l.finAccountKind),
          SysChoiceChips<String>(
            choices: [
              for (final k in FinAccountKind.values) SysChoice(k.name, accountKindLabel(l, k.name), glyph: accountGlyph(k.name)),
            ],
            selected: {kind},
            allowEmpty: false,
            onChanged: (s) => _set(_a.copyWith(kind: s.first)),
          ),
          const SysFieldGap(),
          SysTextField(
            value: _a.name,
            label: l.finAccountName,
            hint: accountTitle(l, _a.copyWith(name: '')),
            onChanged: (v) => _a = _a.copyWith(name: v),
          ),
          if (kind != FinAccountKind.crypto.name) ...[
            const SysFieldGap(),
            SysFieldLabel(l.finCurrency),
            SysSegmented<String>(
              choices: [for (final c in finCurrencies) SysChoice(c, c)],
              value: _a.currency,
              onChanged: (c) => _set(_a.copyWith(currency: c)),
            ),
            const SysFieldGap(),
            SysNumberField(
              value: _opening,
              label: l.finOpeningBalance,
              unit: currencySymbol(_a.currency),
              onChanged: (v) => _opening = v,
            ),
            Text(l.finOpeningBalanceHint, style: SysText.caption),
          ],
          if (kind == FinAccountKind.card.name || kind == FinAccountKind.deposit.name) ...[
            const SysFieldGap(),
            SysTextField(
              value: _a.bank ?? '',
              label: l.finBank,
              hint: l.finBankHint,
              onChanged: (v) => _a = _a.copyWith(bank: Value(v)),
            ),
          ],
          if (kind == FinAccountKind.card.name) ...[
            const SysFieldGap(),
            SysTextField(
              value: _a.cardLast4 ?? '',
              label: l.finCardLast4,
              hint: l.finCardLast4Hint,
              keyboardType: TextInputType.number,
              onChanged: (v) => _a = _a.copyWith(cardLast4: Value(v)),
            ),
          ],
          if (!isNew) ...[
            const SysFieldGap(),
            SysSwitchRow(
              label: l.finArchive,
              hint: l.finArchiveHint,
              value: _a.archived,
              onChanged: (v) => _set(_a.copyWith(archived: v)),
            ),
            const SysFieldGap(),
            SysButton.secondary(
              label: l.finOperations,
              onPressed: () => TransactionsScreen.open(context, accountId: _a.id),
            ),
          ],
        ],
      ),
    );
  }
}

/// Добавление/изменение крипто-актива (количество вручную).
Future<void> showCryptoSheet(BuildContext context, WidgetRef ref, {CryptoHoldingRow? existing}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (_) => _CryptoSheet(existing: existing),
    );

class _CryptoSheet extends ConsumerStatefulWidget {
  const _CryptoSheet({this.existing});
  final CryptoHoldingRow? existing;

  @override
  ConsumerState<_CryptoSheet> createState() => _CryptoSheetState();
}

class _CryptoSheetState extends ConsumerState<_CryptoSheet> {
  late final FinanceRepository _repo = ref.read(financeRepositoryProvider);
  late CryptoHoldingRow _h = widget.existing ?? _repo.newCrypto();
  late num? _amount = widget.existing?.amount;
  bool _coinTouched = false;
  bool _tried = false;

  Future<void> _save() async {
    setState(() => _tried = true);
    final sym = _h.symbol.trim().toUpperCase();
    final amount = _amount;
    if (sym.isEmpty || amount == null || amount < 0) return;
    final coin = _h.coinId.trim().isEmpty ? coinIdGuess(sym) : _h.coinId.trim().toLowerCase();
    await _repo.saveCrypto(_h.copyWith(symbol: sym, coinId: coin, amount: amount.toDouble()));
    // Новая монета — курс подтянется при следующем запросе.
    ref.invalidate(finRatesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cryptoAccounts = (ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[])
        .where((a) => a.kind == FinAccountKind.crypto.name && !a.archived)
        .toList();
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: widget.existing == null ? l.finCryptoAdd : l.finCryptoEdit),
          const SizedBox(height: 10),
          SysTextField(
            value: _h.symbol,
            label: l.finCryptoSymbol,
            hint: 'BTC',
            textCapitalization: TextCapitalization.characters,
            errorText: _tried && _h.symbol.trim().isEmpty ? l.commonRequired : null,
            onChanged: (v) => setState(() {
              _h = _h.copyWith(symbol: v);
              if (!_coinTouched) _h = _h.copyWith(coinId: coinIdGuess(v.trim()));
            }),
          ),
          const SysFieldGap(),
          SysTextField(
            value: _h.coinId,
            label: l.finCryptoCoinId,
            hint: l.finCryptoCoinIdHint,
            textCapitalization: TextCapitalization.none,
            onChanged: (v) {
              _coinTouched = true;
              _h = _h.copyWith(coinId: v);
            },
          ),
          const SysFieldGap(),
          SysNumberField(value: _amount, label: l.finCryptoAmount, min: 0, onChanged: (v) => _amount = v),
          if (cryptoAccounts.isNotEmpty) ...[
            const SysFieldGap(),
            SysFieldLabel(l.finAccount, optional: true, optionalLabel: l.commonOptional),
            SysChoiceChips<String>(
              choices: [for (final a in cryptoAccounts) SysChoice(a.id, accountTitle(l, a))],
              selected: {?_h.accountId},
              onChanged: (s) => setState(() => _h = _h.copyWith(accountId: Value(s.isEmpty ? null : s.first))),
            ),
          ],
          const SizedBox(height: 16),
          Row(children: [
            if (widget.existing != null) ...[
              Expanded(
                child: SysButton.danger(
                  label: l.commonDelete,
                  expand: true,
                  onPressed: () async {
                    await _repo.deleteCrypto(widget.existing!);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(child: SysButton.primary(label: l.commonSave, expand: true, onPressed: _save)),
          ]),
        ],
      ),
    );
  }
}
