// Для других модулей: мини-сводка финансов («Ещё»: траты на еду / лимит / до поступления)
// и напоминания о подписках и долгах в формате планировщика уведомлений.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/notifications/notification_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/finance_repository.dart';
import 'domain/fin_balance.dart';
import 'domain/fin_categories.dart';
import 'domain/fin_math.dart';
import 'finance_providers.dart';
import 'widgets/fin_common.dart';

const _foodKeys = {FinCat.groceries, FinCat.cafe, FinCat.fastfood};

/// Панель «Финансы» для экрана «Ещё» (нажатие — раздел).
class FinanceSummaryPanel extends ConsumerWidget {
  const FinanceSummaryPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final cats = ref.watch(finCategoryMapProvider);
    final budgets = ref.watch(finBudgetsProvider).value ?? const <FinBudgetRow>[];
    final rates = ref.watch(finRatesProvider).value;
    final forecast = ref.watch(finForecastProvider).value;
    final now = DateTime.now();
    final month = periodRange(FinPeriod.month, now);
    final foodIds = {for (final c in cats.values) if (_foodKeys.contains(c.builtinKey)) c.id};
    var food = 0;
    for (final t in txs) {
      if (t.kind != FinTxKind.expense.name || !foodIds.contains(t.categoryId)) continue;
      if (t.occurredAt.isBefore(month.start) || !t.occurredAt.isBefore(month.end)) continue;
      food += txRub(t, rates);
    }
    var foodLimit = 0;
    for (final b in budgets) {
      if (b.status != 'active' || !foodIds.contains(b.categoryId)) continue;
      foodLimit += b.period == 'week' ? (b.limitRub * 30 / 7).round() : b.limitRub;
    }
    final next = forecast?.nextIncomeOn;
    return SysPanel(
      key: const Key('fin-summary'),
      title: l.finTitle,
      child: InkWell(
        onTap: () => context.push(Routes.finance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinInfoRow(
              label: l.finSummaryFood,
              value: foodLimit > 0 ? '${formatRub(food)} / ${formatRub(foodLimit)}' : formatRub(food),
              valueColor: foodLimit > 0 && food > foodLimit ? SysColors.danger : SysColors.calories,
              glyph: SysGlyph.nutrition,
            ),
            if (next != null)
              FinInfoRow(
                label: l.finSummaryUntilIncome,
                value: l.finDays(daysBetween(now, next).clamp(0, 999)),
                glyph: SysGlyph.clock,
              ),
            if (forecast != null)
              FinInfoRow(
                label: l.finFreeToMonthEnd,
                value: formatRub(forecast.freeNow),
                valueColor: forecast.freeNow >= 0 ? SysColors.success : SysColors.danger,
                glyph: SysGlyph.wallet,
              ),
          ],
        ),
      ),
    );
  }
}

/// Префикс instanceId напоминаний раздела (обработчик ответа уведомления должен их пропускать мимо движка квестов).
const financeReminderPrefix = 'fin:';

/// Напоминания: подписка — за день до списания (10:00); долг — за день и в день срока (10:00).
/// Для ReminderScheduler.sync: добавить к списку квестов (например, в ReminderCoordinator.templateFilter).
Future<List<ReminderRequest>> financeReminderRequests(FinanceRepository repo, AppLocalizations l, DateTime now) async {
  final out = <ReminderRequest>[];
  final horizon = now.add(const Duration(days: 7));
  DateTime at10(DateTime d) => DateTime(d.year, d.month, d.day, 10);
  for (final s in await repo.subscriptions()) {
    if (!s.active) continue;
    final due = at10(s.nextChargeOn.subtract(const Duration(days: 1)));
    if (due.isBefore(now) || due.isAfter(horizon)) continue;
    out.add(ReminderRequest(
      instanceId: '${financeReminderPrefix}sub:${s.id}:${isoDay(s.nextChargeOn)}',
      title: l.finRemindSubTitle(s.title),
      body: l.finRemindSubBody(formatMoney(s.amount, s.currency), formatDay(s.nextChargeOn)),
      dueAt: due,
      deadlineAt: due,
      nag: false,
    ));
  }
  for (final d in await repo.debts()) {
    final dueOn = d.dueOn;
    if (d.settledAt != null || dueOn == null) continue;
    for (final (i, at) in [at10(dueOn.subtract(const Duration(days: 1))), at10(dueOn)].indexed) {
      if (at.isBefore(now) || at.isAfter(horizon)) continue;
      final owe = d.direction == 'owe';
      out.add(ReminderRequest(
        instanceId: '${financeReminderPrefix}debt:${d.id}:$i',
        title: owe ? l.finRemindDebtOweTitle : l.finRemindDebtLentTitle,
        body: l.finRemindDebtBody(d.person, formatMoney(d.amount, d.currency), formatDay(dueOn)),
        dueAt: at,
        deadlineAt: at,
        nag: false,
      ));
    }
  }
  return out;
}
