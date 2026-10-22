// Общие части экранов ввода финансов: выбор счёта/категории, суммы, сообщения.
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../finance/fin_texts.dart' show categoryName;

final fniAccountsProvider = StreamProvider<List<FinAccountRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.finAccounts)
        ..where((t) => t.deletedAt.isNull() & t.archived.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]))
      .watch();
});

final fniCategoriesProvider = StreamProvider.family<List<FinCategoryRow>, FinTxKind>((ref, kind) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.finCategories)
        ..where((t) => t.deletedAt.isNull() & t.archived.equals(false) & t.kind.equals(kind.name))
        ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]))
      .watch();
});


String fniLang(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr' ? 'tr' : 'ru';

void fniSnack(BuildContext context, String text) =>
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(text)));

/// Выбор из списка в нижнем листе. Возвращает (значение,) или null — отмена.
Future<(T?,)?> fniPick<T>(BuildContext context, String title, List<(T?, String)> options) =>
    showModalBottomSheet<(T?,)>(
      context: context,
      backgroundColor: SysColors.panelBottom,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text(title, style: SysText.label)),
            for (final o in options)
              InkWell(
                onTap: () => Navigator.of(c).pop((o.$1,)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: SysDims.minTap),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Align(alignment: Alignment.centerLeft, child: Text(o.$2, style: SysText.body)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

/// Поля «Счёт» и «Категория» (null — подберёт журнал).
class FniAccountCategory extends ConsumerWidget {
  const FniAccountCategory({
    super.key,
    required this.kind,
    required this.accountId,
    required this.categoryId,
    required this.onAccount,
    required this.onCategory,
    this.showCategory = true,
  });

  final FinTxKind kind;
  final String? accountId;
  final String? categoryId;
  final ValueChanged<String?> onAccount;
  final ValueChanged<String?> onCategory;
  final bool showCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final accounts = ref.watch(fniAccountsProvider).value ?? const <FinAccountRow>[];
    final cats = ref.watch(fniCategoriesProvider(kind == FinTxKind.income ? FinTxKind.income : FinTxKind.expense)).value ??
        const <FinCategoryRow>[];
    String? accName;
    for (final a in accounts) {
      if (a.id == accountId) accName = a.name;
    }
    String? catName;
    for (final c in cats) {
      if (c.id == categoryId) catName = categoryName(l, c);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysPickerField(
          label: l.fniAccount,
          text: accName,
          placeholder: l.fniAuto,
          glyph: SysGlyph.wallet,
          onTap: () async {
            final r = await fniPick<String>(context, l.fniAccount, [
              (null, l.fniAuto),
              for (final a in accounts) (a.id, '${a.name} · ${a.currency}'),
            ]);
            if (r != null) onAccount(r.$1);
          },
        ),
        if (showCategory) ...[
          const SysFieldGap(),
          SysPickerField(
            label: l.fniCategory,
            text: catName,
            placeholder: l.fniAuto,
            glyph: SysGlyph.star,
            onTap: () async {
              final r = await fniPick<String>(context, l.fniCategory, [
                (null, l.fniAuto),
                for (final c in cats) (c.id, categoryName(l, c)),
              ]);
              if (r != null) onCategory(r.$1);
            },
          ),
        ],
      ],
    );
  }
}

/// Строка «подпись — значение».
class FniRow extends StatelessWidget {
  const FniRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: SysText.secondary)),
            const SizedBox(width: 12),
            Flexible(child: Text(value, style: SysText.mono, textAlign: TextAlign.right)),
          ],
        ),
      );
}

/// Загрузка.
class FniBusy extends StatelessWidget {
  const FniBusy({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2)),
            if (text != null) ...[
              const SizedBox(height: 12),
              Text(text!, style: SysText.secondary, textAlign: TextAlign.center),
            ],
          ],
        ),
      );
}
