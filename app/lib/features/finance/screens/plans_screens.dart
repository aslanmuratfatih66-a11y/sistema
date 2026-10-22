// Цели накопления, подписки, долги.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/fx_rates_impl.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';
import 'tx_edit_screen.dart';

Future<void> _sheet(BuildContext context, Widget child) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (_) => child,
    );

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.children, required this.onSave, this.onDelete});

  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final del = onDelete;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: title),
          const SizedBox(height: 10),
          ...children,
          const SizedBox(height: 16),
          Row(children: [
            if (del != null) ...[
              Expanded(child: SysButton.danger(label: l.commonDelete, expand: true, onPressed: del)),
              const SizedBox(width: 10),
            ],
            Expanded(child: SysButton.primary(label: l.commonSave, expand: true, onPressed: onSave)),
          ]),
        ],
      ),
    );
  }
}

Widget _currencyPicker(String value, ValueChanged<String> onChanged) => SysSegmented<String>(
      choices: [for (final c in finCurrencies) SysChoice(c, c)],
      value: value,
      onChanged: onChanged,
    );

// ============================ Цели ============================

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoalsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final goals = ref.watch(finGoalsProvider).value ?? const <FinGoalRow>[];
    return ScheduleSubPage(
      title: l.finGoals,
      onBack: () => Navigator.of(context).maybePop(),
      child: SysPanel(
        title: l.finGoals,
        tone: PanelTone.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (goals.isEmpty) FinEmpty(l.finGoalsEmpty),
            for (final g in goals) GoalTile(goal: g),
            Text(l.finGoalsHint, style: SysText.caption),
            FinActions(children: [
              SysButton.primary(label: l.finGoalAdd, icon: SysGlyph.plus, onPressed: () => _sheet(context, const _GoalSheet())),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Накоплено по цели: остаток счёта-копилки в валюте цели; null — счёт не выбран.
int? goalSaved(FinGoalRow g, WidgetRef ref) {
  final acc = g.accountId;
  if (acc == null) return null;
  final ov = ref.watch(finOverviewProvider);
  final rates = ref.watch(finRatesProvider).value;
  for (final v in ov?.accounts ?? const []) {
    if (v.account.id != acc) continue;
    if (v.isCrypto) return convertMinor(rates, v.balance, 'RUB', g.currency);
    return convertMinor(rates, v.balance, v.account.currency, g.currency);
  }
  return null;
}

class GoalTile extends ConsumerWidget {
  const GoalTile({super.key, required this.goal});
  final FinGoalRow goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final g = goal;
    final saved = goalSaved(g, ref);
    final deadline = g.deadline;
    return InkWell(
      onTap: () => _sheet(context, _GoalSheet(existing: g)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinProgress(
              label: [g.title, if (deadline != null) l.finUntil(formatDay(deadline))].join(' · '),
              value: saved ?? 0,
              max: g.target,
              valueText: '${saved == null ? '—' : formatMoney(saved, g.currency)} / ${formatMoney(g.target, g.currency)}',
            ),
            if (saved == null) Text(l.finGoalNoAccount, style: SysText.caption),
            if (saved != null && saved >= g.target) Text(l.finGoalReached, style: SysText.caption.copyWith(color: SysColors.success)),
          ],
        ),
      ),
    );
  }
}

class _GoalSheet extends ConsumerStatefulWidget {
  const _GoalSheet({this.existing});
  final FinGoalRow? existing;

  @override
  ConsumerState<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends ConsumerState<_GoalSheet> {
  late FinGoalRow _g = widget.existing ?? ref.read(financeRepositoryProvider).newGoal();
  late num? _target = widget.existing == null ? null : toMajor(widget.existing!.target);
  bool _tried = false;

  Future<void> _save() async {
    setState(() => _tried = true);
    final t = _target;
    if (_g.title.trim().isEmpty || t == null || t <= 0) return;
    await ref.read(financeRepositoryProvider).saveGoal(_g.copyWith(title: _g.title.trim(), target: toMinor(t)));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accounts = (ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[]).where((a) => !a.archived).toList();
    final e = widget.existing;
    final now = DateTime.now();
    return _SheetBody(
      title: e == null ? l.finGoalAdd : l.finGoalEdit,
      onSave: _save,
      onDelete: e == null
          ? null
          : () async {
              await ref.read(financeRepositoryProvider).deleteGoal(e);
              if (context.mounted) Navigator.of(context).pop();
            },
      children: [
        SysTextField(
          value: _g.title,
          label: l.finGoalTitle,
          errorText: _tried && _g.title.trim().isEmpty ? l.commonRequired : null,
          onChanged: (v) => _g = _g.copyWith(title: v),
        ),
        const SysFieldGap(),
        SysNumberField(value: _target, label: l.finGoalTarget, unit: currencySymbol(_g.currency), min: 1, onChanged: (v) => _target = v),
        const SizedBox(height: 8),
        _currencyPicker(_g.currency, (c) => setState(() => _g = _g.copyWith(currency: c))),
        const SysFieldGap(),
        SysFieldLabel(l.finGoalAccount, hint: l.finGoalAccountHint),
        SysChoiceChips<String>(
          choices: [for (final a in accounts) SysChoice(a.id, accountTitle(l, a), glyph: accountGlyph(a.kind))],
          selected: {?_g.accountId},
          onChanged: (s) => setState(() => _g = _g.copyWith(accountId: Value(s.isEmpty ? null : s.first))),
        ),
        const SysFieldGap(),
        SysDateField(
          label: l.finGoalDeadline,
          date: _g.deadline,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 30),
          initialDate: DateTime(now.year, now.month + 6, now.day),
          onChanged: (d) => setState(() => _g = _g.copyWith(deadline: Value(d))),
        ),
      ],
    );
  }
}

// ============================ Подписки ============================

/// Скоро списание: в ближайшие сутки (и не позже завтрашнего дня).
bool subscriptionSoon(FinSubscriptionRow s, DateTime now) =>
    s.active && daysBetween(now, s.nextChargeOn) <= 1 && s.nextChargeOn.isAfter(now.subtract(const Duration(hours: 1)));

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SubscriptionsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final subs = ref.watch(finSubscriptionsProvider).value ?? const <FinSubscriptionRow>[];
    final rates = ref.watch(finRatesProvider).value;
    final now = DateTime.now();
    var monthly = 0;
    for (final s in subs) {
      if (!s.active) continue;
      final rub = s.currency == 'RUB' ? s.amount : rates?.toRub(s.amount, s.currency) ?? 0;
      monthly += switch (s.period) { 'week' => (rub * 52 / 12).round(), 'year' => (rub / 12).round(), _ => rub };
    }
    return ScheduleSubPage(
      title: l.finSubscriptions,
      onBack: () => Navigator.of(context).maybePop(),
      child: SysPanel(
        title: l.finSubscriptions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (subs.isEmpty) FinEmpty(l.finSubscriptionsEmpty),
            for (final s in subs)
              FinTile(
                title: s.title,
                subtitle: [
                  periodLabel(l, s.period),
                  s.active ? l.finNextCharge(formatDay(s.nextChargeOn)) : l.finPaused,
                  if (subscriptionSoon(s, now)) l.finChargeSoon,
                ].join(' · '),
                glyph: SysGlyph.clock,
                glyphColor: subscriptionSoon(s, now) ? SysColors.gold : (s.active ? SysColors.accentLight : SysColors.textInactive),
                trailing: formatMoney(s.amount, s.currency),
                onTap: () => _sheet(context, _SubscriptionSheet(existing: s)),
              ),
            if (subs.isNotEmpty) FinInfoRow(label: l.finSubscriptionsMonthly, value: formatRub(monthly), valueColor: SysColors.gold),
            Text(l.finSubscriptionsHint, style: SysText.caption),
            FinActions(children: [
              SysButton.primary(
                label: l.finSubscriptionAdd,
                icon: SysGlyph.plus,
                onPressed: () => _sheet(context, const _SubscriptionSheet()),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionSheet extends ConsumerStatefulWidget {
  const _SubscriptionSheet({this.existing});
  final FinSubscriptionRow? existing;

  @override
  ConsumerState<_SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends ConsumerState<_SubscriptionSheet> {
  late FinSubscriptionRow _s = widget.existing ?? ref.read(financeRepositoryProvider).newSubscription();
  late num? _amount = widget.existing == null ? null : toMajor(widget.existing!.amount);
  bool _tried = false;

  Future<void> _save() async {
    setState(() => _tried = true);
    final a = _amount;
    if (_s.title.trim().isEmpty || a == null || a <= 0) return;
    await ref.read(financeRepositoryProvider).saveSubscription(_s.copyWith(title: _s.title.trim(), amount: toMinor(a)));
    // Наступившее списание — сразу операция.
    await ref.read(financeLedgerImplProvider).processSubscriptions();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accounts = (ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[])
        .where((a) => !a.archived && a.kind != FinAccountKind.crypto.name)
        .toList();
    final e = widget.existing;
    final now = DateTime.now();
    return _SheetBody(
      title: e == null ? l.finSubscriptionAdd : l.finSubscriptionEdit,
      onSave: _save,
      onDelete: e == null
          ? null
          : () async {
              await ref.read(financeRepositoryProvider).deleteSubscription(e);
              if (context.mounted) Navigator.of(context).pop();
            },
      children: [
        SysTextField(
          value: _s.title,
          label: l.finSubscriptionTitle,
          errorText: _tried && _s.title.trim().isEmpty ? l.commonRequired : null,
          onChanged: (v) => _s = _s.copyWith(title: v),
        ),
        const SysFieldGap(),
        SysNumberField(value: _amount, label: l.finAmount, unit: currencySymbol(_s.currency), min: 0.01, onChanged: (v) => _amount = v),
        const SizedBox(height: 8),
        _currencyPicker(_s.currency, (c) => setState(() => _s = _s.copyWith(currency: c))),
        const SysFieldGap(),
        SysSegmented<String>(
          choices: [
            SysChoice('week', l.finPeriodWeek),
            SysChoice('month', l.finPeriodMonth),
            SysChoice('year', l.finPeriodYear),
          ],
          value: _s.period,
          onChanged: (p) => setState(() => _s = _s.copyWith(period: p)),
        ),
        const SysFieldGap(),
        SysDateField(
          label: l.finNextChargeDate,
          date: _s.nextChargeOn,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 5),
          onChanged: (d) => setState(() => _s = _s.copyWith(nextChargeOn: DateTime(d.year, d.month, d.day, 9))),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.finAccount, optional: true, optionalLabel: l.commonOptional),
        SysChoiceChips<String>(
          choices: [for (final a in accounts) SysChoice(a.id, accountTitle(l, a), glyph: accountGlyph(a.kind))],
          selected: {?_s.accountId},
          onChanged: (s) => setState(() => _s = _s.copyWith(accountId: Value(s.isEmpty ? null : s.first))),
        ),
        const SysFieldGap(),
        SysSwitchRow(label: l.finActive, value: _s.active, onChanged: (v) => setState(() => _s = _s.copyWith(active: v))),
      ],
    );
  }
}

// ============================ Долги ============================

class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const DebtsScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final debts = ref.watch(finDebtsProvider).value ?? const <FinDebtRow>[];
    final open = debts.where((d) => d.settledAt == null).toList();
    final closed = debts.where((d) => d.settledAt != null).toList();
    final now = DateTime.now();
    Widget tile(FinDebtRow d) {
      final due = d.dueOn;
      final overdue = d.settledAt == null && due != null && dayOf(due).isBefore(dayOf(now));
      return FinTile(
        title: d.person.isEmpty ? (d.direction == 'owe' ? l.finDebtOwe : l.finDebtLent) : d.person,
        subtitle: [
          d.direction == 'owe' ? l.finDebtOwe : l.finDebtLent,
          if (due != null) l.finUntil(formatDay(due)),
          if (overdue) l.finOverdue,
          if (d.settledAt != null) l.finSettled,
        ].join(' · '),
        glyph: d.direction == 'owe' ? SysGlyph.arrowUp : SysGlyph.arrowDown,
        glyphColor: overdue ? SysColors.danger : (d.direction == 'owe' ? SysColors.dangerLight : SysColors.success),
        trailing: formatMoney(d.amount, d.currency),
        trailingColor: d.settledAt != null ? SysColors.textInactive : SysColors.textPrimary,
        onTap: () => _sheet(context, _DebtSheet(existing: d)),
      );
    }

    return ScheduleSubPage(
      title: l.finDebts,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.finDebtsOpen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (open.isEmpty) FinEmpty(l.finDebtsEmpty),
                for (final d in open) tile(d),
                FinActions(children: [
                  SysButton.primary(label: l.finDebtAdd, icon: SysGlyph.plus, onPressed: () => _sheet(context, const _DebtSheet())),
                ]),
              ],
            ),
          ),
          if (closed.isNotEmpty) ...[
            const SizedBox(height: 14),
            SysPanel(title: l.finDebtsClosed, child: Column(children: [for (final d in closed) tile(d)])),
          ],
        ],
      ),
    );
  }
}

class _DebtSheet extends ConsumerStatefulWidget {
  const _DebtSheet({this.existing});
  final FinDebtRow? existing;

  @override
  ConsumerState<_DebtSheet> createState() => _DebtSheetState();
}

class _DebtSheetState extends ConsumerState<_DebtSheet> {
  late FinDebtRow _d = widget.existing ?? ref.read(financeRepositoryProvider).newDebt();
  late num? _amount = widget.existing == null ? null : toMajor(widget.existing!.amount);
  bool _tried = false;

  Future<void> _save() async {
    setState(() => _tried = true);
    final a = _amount;
    if (a == null || a <= 0) return;
    await ref.read(financeRepositoryProvider).saveDebt(_d.copyWith(person: _d.person.trim(), amount: toMinor(a)));
    if (mounted) Navigator.of(context).pop();
  }

  /// Погашение: отметка + операция на сумму (расход — я вернул, доход — мне вернули).
  Future<void> _settle() async {
    final e = widget.existing;
    if (e == null) return;
    await ref.read(financeRepositoryProvider).saveDebt(_d.copyWith(settledAt: Value(DateTime.now())));
    if (!mounted) return;
    final nav = Navigator.of(context)..pop();
    await nav.push(MaterialPageRoute<void>(
      builder: (_) => TxEditScreen(kind: e.direction == 'owe' ? FinTxKind.expense : FinTxKind.income),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = widget.existing;
    final now = DateTime.now();
    return _SheetBody(
      title: e == null ? l.finDebtAdd : l.finDebtEdit,
      onSave: _save,
      onDelete: e == null
          ? null
          : () async {
              await ref.read(financeRepositoryProvider).deleteDebt(e);
              if (context.mounted) Navigator.of(context).pop();
            },
      children: [
        SysSegmented<String>(
          choices: [SysChoice('owe', l.finDebtOwe), SysChoice('lent', l.finDebtLent)],
          value: _d.direction,
          onChanged: (v) => setState(() => _d = _d.copyWith(direction: v)),
        ),
        const SysFieldGap(),
        SysTextField(value: _d.person, label: l.finDebtPerson, onChanged: (v) => _d = _d.copyWith(person: v)),
        const SysFieldGap(),
        SysNumberField(
          value: _amount,
          label: l.finAmount,
          unit: currencySymbol(_d.currency),
          min: 0.01,
          outOfRangeText: _tried && _amount == null ? l.commonRequired : null,
          onChanged: (v) => _amount = v,
        ),
        const SizedBox(height: 8),
        _currencyPicker(_d.currency, (c) => setState(() => _d = _d.copyWith(currency: c))),
        const SysFieldGap(),
        SysDateField(
          label: l.finDebtDue,
          date: _d.dueOn,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 10),
          initialDate: now,
          onChanged: (d) => setState(() => _d = _d.copyWith(dueOn: Value(DateTime(d.year, d.month, d.day, 10)))),
        ),
        const SysFieldGap(),
        SysTextField(value: _d.note ?? '', label: l.finNote, onChanged: (v) => _d = _d.copyWith(note: Value(v))),
        if (e != null && e.settledAt == null) ...[
          const SysFieldGap(),
          SysButton.secondary(label: l.finDebtSettle, icon: SysGlyph.check, expand: true, onPressed: _settle),
          Text(l.finDebtSettleHint, style: SysText.caption),
        ],
      ],
    );
  }
}
