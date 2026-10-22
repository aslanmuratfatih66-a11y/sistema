// Лимиты по категориям: ручные и предложенные ИИ (после ≥14 дней наблюдений), прогресс, подтверждение.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_api.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/finance_ai.dart';
import '../domain/fin_balance.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';

/// Потрачено по лимиту в текущем периоде (копейки).
int budgetSpent(FinBudgetRow b, List<FinTransactionRow> txs, FxRates? rates, DateTime now) {
  final r = periodRange(finPeriodOf(b.period), now);
  var sum = 0;
  for (final t in txs) {
    if (t.kind != FinTxKind.expense.name || t.categoryId != b.categoryId) continue;
    if (t.occurredAt.isBefore(r.start) || !t.occurredAt.isBefore(r.end)) continue;
    sum += txRub(t, rates);
  }
  return sum;
}

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BudgetsScreen()));

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  bool _asking = false;
  int? _days;

  @override
  void initState() {
    super.initState();
    ref.read(financeAiProvider).observationDays().then((d) {
      if (mounted) setState(() => _days = d);
    });
  }

  Future<void> _suggest() async {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    setState(() => _asking = true);
    try {
      final n = await ref.read(financeAiProvider).suggestBudgets(lang: lang, categoryName: (c) => categoryName(l, c));
      if (mounted) finSnack(context, n == 0 ? l.finAiNoSuggestions : l.finAiSuggested(n));
    } on AiException catch (e) {
      if (mounted) finSnack(context, finAiFailureText(l, e.failure));
    } catch (_) {
      if (mounted) finSnack(context, l.finAiUnavailable);
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final budgets = ref.watch(finBudgetsProvider).value ?? const <FinBudgetRow>[];
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final cats = ref.watch(finCategoryMapProvider);
    final rates = ref.watch(finRatesProvider).value;
    final now = DateTime.now();
    final active = budgets.where((b) => b.status == 'active').toList();
    final proposed = budgets.where((b) => b.status == 'proposed').toList();
    final days = _days;
    final canAsk = days != null && days >= FinanceAi.minObservationDays;
    final repo = ref.read(financeRepositoryProvider);

    return ScheduleSubPage(
      title: l.finBudgets,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.finBudgetsActive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (active.isEmpty) FinEmpty(l.finBudgetsEmpty),
                for (final b in active)
                  InkWell(
                    onTap: () => showBudgetSheet(context, existing: b),
                    child: FinProgress(
                      label: '${categoryName(l, cats[b.categoryId])} · ${periodLabel(l, b.period)}',
                      value: budgetSpent(b, txs, rates, now),
                      max: b.limitRub,
                      valueText: '${formatRub(budgetSpent(b, txs, rates, now))} / ${formatRub(b.limitRub)}',
                    ),
                  ),
                Text(l.finBudgetsRule, style: SysText.caption),
                FinActions(children: [
                  SysButton.primary(label: l.finBudgetAdd, icon: SysGlyph.plus, onPressed: () => showBudgetSheet(context)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finBudgetsAi,
            tone: PanelTone.boss,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  days == null
                      ? '…'
                      : canAsk
                          ? l.finBudgetsAiReady(days)
                          : l.finBudgetsAiNeedMore(days),
                  style: SysText.secondary,
                ),
                for (final b in proposed)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FinInfoRow(
                          label: '${categoryName(l, cats[b.categoryId])} · ${periodLabel(l, b.period)}',
                          value: formatRub(b.limitRub),
                          valueColor: SysColors.bossLight,
                        ),
                        if (b.reason case final r?) Text(r, style: SysText.caption),
                        Wrap(spacing: 10, runSpacing: 8, children: [
                          SysButton.primary(
                            label: l.finAccept,
                            icon: SysGlyph.check,
                            onPressed: () => repo.saveBudget(b.copyWith(
                              status: 'active',
                              startsOn: periodRange(finPeriodOf(b.period), DateTime.now()).start,
                            )),
                          ),
                          SysButton.secondary(
                            label: l.finReject,
                            onPressed: () => repo.saveBudget(b.copyWith(status: 'rejected')),
                          ),
                        ]),
                      ],
                    ),
                  ),
                FinActions(children: [
                  SysButton.secondary(
                    key: const Key('fin-budget-ai'),
                    label: _asking ? l.finAiThinking : l.finBudgetsAiAsk,
                    icon: SysGlyph.sparkle,
                    onPressed: canAsk && !_asking ? _suggest : null,
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showBudgetSheet(BuildContext context, {FinBudgetRow? existing}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (_) => _BudgetSheet(existing: existing),
    );

class _BudgetSheet extends ConsumerStatefulWidget {
  const _BudgetSheet({this.existing});
  final FinBudgetRow? existing;

  @override
  ConsumerState<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends ConsumerState<_BudgetSheet> {
  late String? _cat = widget.existing?.categoryId;
  late String _period = widget.existing?.period ?? 'month';
  late num? _limit = widget.existing == null ? null : widget.existing!.limitRub / 100;
  late num? _reward = widget.existing?.rewardDiamonds ?? 10;
  late num? _penalty = widget.existing?.penaltyDiamonds ?? 10;
  bool _tried = false;

  Future<void> _save() async {
    setState(() => _tried = true);
    final cat = _cat;
    final limit = _limit;
    if (cat == null || limit == null || limit <= 0) return;
    final repo = ref.read(financeRepositoryProvider);
    final e = widget.existing;
    final reward = (_reward ?? 0).toInt().clamp(0, 1000);
    final penalty = (_penalty ?? 0).toInt().clamp(0, 1000);
    if (e == null) {
      await repo.saveBudget(repo.newBudget(
        categoryId: cat,
        limitRub: toMinor(limit),
        period: _period,
        rewardDiamonds: reward,
        penaltyDiamonds: penalty,
      ));
    } else {
      await repo.saveBudget(e.copyWith(
        categoryId: cat,
        limitRub: toMinor(limit),
        period: _period,
        rewardDiamonds: reward,
        penaltyDiamonds: penalty,
        // Смена периода — новый отсчёт.
        startsOn: _period != e.period ? periodRange(finPeriodOf(_period), DateTime.now()).start : e.startsOn,
      ));
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cats = (ref.watch(finCategoriesProvider).value ?? const <FinCategoryRow>[])
        .where((c) => c.kind == FinTxKind.expense.name && !c.archived)
        .toList();
    final e = widget.existing;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: e == null ? l.finBudgetAdd : l.finBudgetEdit),
          const SizedBox(height: 10),
          SysFieldLabel(l.finCategory),
          SysChoiceChips<String>(
            choices: [for (final c in cats) SysChoice(c.id, categoryName(l, c), glyph: categoryGlyph(c))],
            selected: {?_cat},
            allowEmpty: false,
            onChanged: (s) => setState(() => _cat = s.first),
          ),
          if (_tried && _cat == null) Text(l.commonRequired, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
          const SysFieldGap(),
          SysSegmented<String>(
            choices: [SysChoice('week', l.finPeriodWeek), SysChoice('month', l.finPeriodMonth)],
            value: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
          const SysFieldGap(),
          SysNumberField(value: _limit, label: l.finLimit, unit: '₽', min: 1, onChanged: (v) => _limit = v),
          const SysFieldGap(),
          Row(children: [
            Expanded(
              child: SysNumberField(
                value: _reward,
                label: l.finRewardDiamonds,
                unit: '◆',
                decimal: false,
                min: 0,
                onChanged: (v) => _reward = v,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SysNumberField(
                value: _penalty,
                label: l.finPenaltyDiamonds,
                unit: '◆',
                decimal: false,
                min: 0,
                onChanged: (v) => _penalty = v,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            if (e != null) ...[
              Expanded(
                child: SysButton.danger(
                  label: l.commonDelete,
                  expand: true,
                  onPressed: () async {
                    await ref.read(financeRepositoryProvider).deleteBudget(e);
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
