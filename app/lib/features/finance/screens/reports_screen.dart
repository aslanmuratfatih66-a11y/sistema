// Отчёты неделя/месяц: расходы по категориям (круговая), доходы vs расходы за 6 периодов (столбцы), комментарий ИИ.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/ai_api.dart';
import '../../../core/db/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/fin_balance.dart';
import '../domain/fin_math.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';
import 'budgets_screen.dart' show budgetSpent;
import 'transactions_screen.dart';

const _palette = <Color>[
  SysColors.accent,
  SysColors.gold,
  SysColors.success,
  SysColors.boss,
  SysColors.dangerLight,
  SysColors.accentLighter,
  Color(0xFFFF9F43),
  SysColors.bossLight,
];

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ReportsScreen()));

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  FinPeriod _period = FinPeriod.month;
  int _offset = 0;
  String? _comment;
  String? _commentError;
  bool _asking = false;

  ({DateTime start, DateTime end}) get _range =>
      shiftPeriod(_period, periodRange(_period, DateTime.now()).start, _offset);

  String _rangeLabel(({DateTime start, DateTime end}) r) => _period == FinPeriod.month
      ? '${r.start.month.toString().padLeft(2, '0')}.${r.start.year}'
      : '${formatDayShort(r.start)} – ${formatDayShort(r.end.subtract(const Duration(days: 1)))}';

  void _shift(int d) => setState(() {
        _offset = math.min(0, _offset + d);
        _comment = null;
        _commentError = null;
      });

  Future<void> _ask(PeriodTotals totals, List<({String name, int spent})> byCat, List<({String name, int limit, int spent})> budgets) async {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    setState(() {
      _asking = true;
      _commentError = null;
    });
    try {
      final c = await ref.read(financeAiProvider).reportComment(
            lang: lang,
            period: _period,
            totals: totals,
            byCategory: byCat,
            budgets: budgets,
          );
      if (mounted) setState(() => _comment = c);
    } on AiException catch (e) {
      if (mounted) setState(() => _commentError = finAiFailureText(l, e.failure));
    } catch (_) {
      if (mounted) setState(() => _commentError = l.finAiUnavailable);
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final cats = ref.watch(finCategoryMapProvider);
    final rates = ref.watch(finRatesProvider).value;
    final budgets = (ref.watch(finBudgetsProvider).value ?? const <FinBudgetRow>[]).where((b) => b.status == 'active');
    final r = _range;
    final totals = totalsFor(txs, r.start, r.end, rates);
    final byCat = totals.byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final catItems = [for (final e in byCat) (name: categoryName(l, cats[e.key]), spent: e.value, id: e.key)];
    final history = [
      for (var i = -5; i <= 0; i++)
        () {
          final pr = shiftPeriod(_period, r.start, i);
          return (label: _period == FinPeriod.month ? pr.start.month.toString().padLeft(2, '0') : formatDayShort(pr.start),
              t: totalsFor(txs, pr.start, pr.end, rates));
        }(),
    ];
    final budgetItems = [
      for (final b in budgets)
        if (b.period == _period.name)
          (name: categoryName(l, cats[b.categoryId]), limit: b.limitRub, spent: budgetSpent(b, txs, rates, r.start)),
    ];

    return ScheduleSubPage(
      title: l.finReports,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<FinPeriod>(
            choices: [SysChoice(FinPeriod.week, l.finPeriodWeek), SysChoice(FinPeriod.month, l.finPeriodMonth)],
            value: _period,
            onChanged: (p) => setState(() {
              _period = p;
              _offset = 0;
              _comment = null;
            }),
          ),
          const SizedBox(height: 8),
          Row(children: [
            SysIconButton(glyph: SysGlyph.chevronLeft, tooltip: l.finPrevPeriod, onPressed: () => _shift(-1)),
            Expanded(child: Text(_rangeLabel(r), textAlign: TextAlign.center, style: SysText.mono)),
            SysIconButton(
              glyph: SysGlyph.chevronRight,
              tooltip: l.finNextPeriod,
              onPressed: _offset < 0 ? () => _shift(1) : null,
            ),
          ]),
          const SizedBox(height: 8),
          SysPanel(
            title: l.finTotals,
            child: Column(children: [
              FinInfoRow(label: l.finIncomes, value: formatRub(totals.income), valueColor: SysColors.success),
              FinInfoRow(label: l.finExpenses, value: formatRub(totals.expense), valueColor: SysColors.dangerLight),
              FinInfoRow(
                label: l.finNet,
                value: formatRub(totals.net, sign: true),
                valueColor: totals.net >= 0 ? SysColors.success : SysColors.danger,
              ),
            ]),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finByCategory,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (catItems.isEmpty)
                  FinEmpty(l.finNoExpensesPeriod)
                else ...[
                  Semantics(
                    label: l.finByCategory,
                    excludeSemantics: true,
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 46,
                          pieTouchData: PieTouchData(enabled: false),
                          sections: [
                            for (var i = 0; i < catItems.length; i++)
                              PieChartSectionData(
                                value: catItems[i].spent.toDouble(),
                                color: _palette[math.min(i, _palette.length - 1)],
                                radius: 34,
                                showTitle: false,
                              ),
                          ],
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < catItems.length; i++)
                    InkWell(
                      onTap: catItems[i].id == null ? null : () => TransactionsScreen.open(context, categoryId: catItems[i].id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Container(width: 10, height: 10, color: _palette[math.min(i, _palette.length - 1)]),
                          const SizedBox(width: 8),
                          Expanded(child: Text(catItems[i].name, style: SysText.secondary)),
                          Text(
                            '${formatRub(catItems[i].spent)} · ${totals.expense == 0 ? 0 : (catItems[i].spent * 100 / totals.expense).round()}%',
                            style: SysText.monoSmall,
                          ),
                        ]),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.finDynamics,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _IncomeExpenseChart(items: history, semanticLabel: l.finDynamics),
                const SizedBox(height: 6),
                Wrap(spacing: 14, runSpacing: 4, children: [
                  for (final (color, text) in [(SysColors.success, l.finIncomes), (SysColors.dangerLight, l.finExpenses)])
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 10, height: 10, color: color),
                      const SizedBox(width: 6),
                      Text(text, style: SysText.caption),
                    ]),
                ]),
              ],
            ),
          ),
          if (budgetItems.isNotEmpty) ...[
            const SizedBox(height: 14),
            SysPanel(
              title: l.finBudgets,
              child: Column(children: [
                for (final b in budgetItems)
                  FinProgress(label: b.name, value: b.spent, max: b.limit, valueText: '${formatRub(b.spent)} / ${formatRub(b.limit)}'),
              ]),
            ),
          ],
          const SizedBox(height: 14),
          SysPanel(
            title: l.finAiComment,
            tone: PanelTone.boss,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_comment case final c?) Text(c, style: SysText.body),
                if (_commentError case final e?)
                  SysEmptyState.inline(e, glyph: SysGlyph.warning, color: SysColors.dangerLight),
                if (_comment == null && _commentError == null) Text(l.finAiCommentHint, style: SysText.secondary),
                FinActions(children: [
                  SysButton.secondary(
                    key: const Key('fin-report-ai'),
                    label: _asking ? l.finAiThinking : l.finAiCommentAsk,
                    icon: SysGlyph.sparkle,
                    onPressed: _asking || (totals.income == 0 && totals.expense == 0)
                        ? null
                        : () => _ask(totals, [for (final c in catItems) (name: c.name, spent: c.spent)], budgetItems),
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

class _IncomeExpenseChart extends StatelessWidget {
  const _IncomeExpenseChart({required this.items, this.semanticLabel});

  final List<({String label, PeriodTotals t})> items;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final maxV = items.fold<int>(0, (m, e) => math.max(m, math.max(e.t.income, e.t.expense))) / 100;
    final top = maxV <= 0 ? 1.0 : maxV * 1.15;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: top,
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            gridData: FlGridData(
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: SysColors.accent.withValues(alpha: .12), strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, m) {
                    if (v == m.max) return const SizedBox.shrink();
                    final s = v >= 1000 ? '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}k' : v.toStringAsFixed(0);
                    return SideTitleWidget(
                      meta: m,
                      child: Text(s, style: SysText.monoSmall.copyWith(color: SysColors.textCaption, fontSize: 9)),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, m) {
                    final i = v.round();
                    if (i < 0 || i >= items.length) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: m,
                      child: Text(items[i].label, style: SysText.monoSmall.copyWith(color: SysColors.textCaption, fontSize: 9)),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < items.length; i++)
                BarChartGroupData(x: i, barsSpace: 3, barRods: [
                  BarChartRodData(toY: items[i].t.income / 100, width: 9, color: SysColors.success, borderRadius: BorderRadius.circular(1)),
                  BarChartRodData(toY: items[i].t.expense / 100, width: 9, color: SysColors.dangerLight, borderRadius: BorderRadius.circular(1)),
                ]),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}
