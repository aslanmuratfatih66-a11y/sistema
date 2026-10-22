// Подписи раздела «Финансы» (l10n): категории, счета, периоды, источники, причины ◆.
import '../../core/ai/ai_api.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/security/app_lock.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/finance_ledger_impl.dart';
import 'domain/fin_categories.dart';
import 'domain/fin_math.dart';

String builtinCategoryLabel(AppLocalizations l, String key) => switch (key) {
      FinCat.groceries => l.finCatGroceries,
      FinCat.cafe => l.finCatCafe,
      FinCat.fastfood => l.finCatFastfood,
      FinCat.transport => l.finCatTransport,
      FinCat.housing => l.finCatHousing,
      FinCat.utilities => l.finCatUtilities,
      FinCat.phone => l.finCatPhone,
      FinCat.health => l.finCatHealth,
      FinCat.beauty => l.finCatBeauty,
      FinCat.clothes => l.finCatClothes,
      FinCat.education => l.finCatEducation,
      FinCat.sport => l.finCatSport,
      FinCat.fun => l.finCatFun,
      FinCat.subscriptions => l.finCatSubscriptions,
      FinCat.gifts => l.finCatGifts,
      FinCat.marketplace => l.finCatMarketplace,
      FinCat.stipend => l.finCatStipend,
      FinCat.salary => l.finCatSalary,
      FinCat.giftIncome => l.finCatGiftIncome,
      FinCat.cashback => l.finCatCashback,
      FinCat.otherIncome => l.finCatOtherIncome,
      _ => l.finCatOther,
    };

String categoryName(AppLocalizations l, FinCategoryRow? c) {
  if (c == null) return l.finNoCategory;
  final n = c.name?.trim();
  if (n != null && n.isNotEmpty) return n;
  final k = c.builtinKey;
  return k == null ? l.finCatOther : builtinCategoryLabel(l, k);
}

SysGlyph categoryGlyph(FinCategoryRow? c) => glyphByName(c?.icon, fallback: builtinByKey(c?.builtinKey)?.glyph ?? SysGlyph.more);

String accountKindLabel(AppLocalizations l, String kind) => switch (kind) {
      'cash' => l.finAccKindCash,
      'deposit' => l.finAccKindDeposit,
      'crypto' => l.finAccKindCrypto,
      _ => l.finAccKindCard,
    };

SysGlyph accountGlyph(String kind) => switch (kind) {
      'cash' => SysGlyph.wallet,
      'deposit' => SysGlyph.shield,
      'crypto' => SysGlyph.diamond,
      _ => SysGlyph.wallet,
    };

/// Имя счёта: своё или «Наличные · RUB» / «Карта · Сбер».
String accountTitle(AppLocalizations l, FinAccountRow? a) {
  if (a == null) return '—';
  if (a.name.trim().isNotEmpty) return a.name.trim();
  final bank = a.bank;
  final kind = accountKindLabel(l, a.kind);
  if (bank != null && bank.isNotEmpty) return '$kind · $bank';
  return '$kind · ${a.currency}';
}

String txKindLabel(AppLocalizations l, FinTxKind k) => switch (k) {
      FinTxKind.expense => l.finExpense,
      FinTxKind.income => l.finIncome,
      FinTxKind.transfer => l.finTransfer,
    };

String periodLabel(AppLocalizations l, String p) => switch (p) {
      'week' => l.finPeriodWeek,
      'year' => l.finPeriodYear,
      _ => l.finPeriodMonth,
    };

String sourceLabel(AppLocalizations l, String s) => switch (s) {
      'receiptQr' => l.finSrcReceiptQr,
      'receiptPhoto' => l.finSrcReceiptPhoto,
      'food' => l.finSrcFood,
      'bankNotification' => l.finSrcBank,
      'sms' => l.finSrcSms,
      'statement' => l.finSrcStatement,
      'subscription' => l.finSrcSubscription,
      'market' => l.finSrcMarket,
      _ => l.finSrcManual,
    };

/// Подпись причины ◆ (для penaltyReasonLabel движка — см. отчёт).
String? finReasonLabel(AppLocalizations l, String reasonKey) => switch (reasonKey) {
      FinReasons.junkTax => l.finReasonJunkTax,
      FinReasons.budgetOver => l.finReasonBudgetOver,
      FinReasons.budgetKept => l.finReasonBudgetKept,
      _ => null,
    };

String lockModeLabel(AppLocalizations l, AppLockMode m) => switch (m) {
      AppLockMode.off => l.finLockModeOff,
      AppLockMode.biometric => l.finLockModeBiometric,
      AppLockMode.pin => l.finLockModePin,
      AppLockMode.biometricOrPin => l.finLockModeBoth,
    };

String finAiFailureText(AppLocalizations l, AiFailure f) => switch (f) {
      AiFailure.notSignedIn => l.finAiNotSignedIn,
      AiFailure.offline => l.finAiOffline,
      AiFailure.budget => l.finAiBudget,
      AiFailure.rateLimited => l.finAiRateLimited,
      AiFailure.unavailable || AiFailure.server => l.finAiUnavailable,
    };

/// «12.10 · 14:05».
String formatTxTime(DateTime t) =>
    '${formatDayShort(t)} · ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
