// Категории: встроенные (можно скрыть, переименовать, пометить «вредная еда») и свои.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../fin_texts.dart';
import '../finance_providers.dart';
import '../widgets/fin_common.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cats = ref.watch(finCategoriesProvider).value ?? const <FinCategoryRow>[];
    Widget block(FinTxKind kind, String title) {
      final list = cats.where((c) => c.kind == kind.name).toList();
      return SysPanel(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in list)
              FinTile(
                title: categoryName(l, c),
                subtitle: [
                  if (c.junkFood) l.finJunkFood,
                  if (c.archived) l.finHidden,
                ].join(' · ').let((s) => s.isEmpty ? null : s),
                glyph: categoryGlyph(c),
                glyphColor: c.archived ? SysColors.textInactive : (c.junkFood ? SysColors.gold : SysColors.accentLight),
                onTap: () => showCategorySheet(context, ref, kind: kind, existing: c),
              ),
            FinActions(children: [
              SysButton.secondary(
                label: l.finCategoryAdd,
                icon: SysGlyph.plus,
                onPressed: () => showCategorySheet(context, ref, kind: kind),
              ),
            ]),
          ],
        ),
      );
    }

    return ScheduleSubPage(
      title: l.finCategories,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          block(FinTxKind.expense, l.finExpenses),
          const SizedBox(height: 14),
          block(FinTxKind.income, l.finIncomes),
        ],
      ),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

const _glyphs = [
  SysGlyph.nutrition, SysGlyph.flame, SysGlyph.walk, SysGlyph.home, SysGlyph.bolt, SysGlyph.heart, SysGlyph.sparkle, //
  SysGlyph.shop, SysGlyph.book, SysGlyph.dumbbell, SysGlyph.star, SysGlyph.clock, SysGlyph.diamond, SysGlyph.wallet,
  SysGlyph.send, SysGlyph.water, SysGlyph.moon, SysGlyph.more,
];

Future<void> showCategorySheet(BuildContext context, WidgetRef ref, {required FinTxKind kind, FinCategoryRow? existing}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (_) => _CategorySheet(kind: kind, existing: existing),
    );

class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({required this.kind, this.existing});
  final FinTxKind kind;
  final FinCategoryRow? existing;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late FinCategoryRow _c = widget.existing ?? ref.read(financeRepositoryProvider).newCategory(widget.kind, '');
  bool _tried = false;

  bool get _builtin => _c.builtinKey != null;

  Future<void> _save() async {
    setState(() => _tried = true);
    final name = (_c.name ?? '').trim();
    if (!_builtin && name.isEmpty) return;
    await ref.read(financeRepositoryProvider).saveCategory(_c.copyWith(name: Value(name.isEmpty ? null : name)));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final existing = widget.existing;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: existing == null ? l.finCategoryAdd : categoryName(l, existing)),
          const SizedBox(height: 10),
          SysTextField(
            value: _c.name ?? '',
            label: l.finCategoryName,
            hint: _builtin ? builtinCategoryLabel(l, _c.builtinKey!) : null,
            errorText: _tried && !_builtin && (_c.name ?? '').trim().isEmpty ? l.commonRequired : null,
            onChanged: (v) => _c = _c.copyWith(name: Value(v)),
          ),
          const SysFieldGap(),
          SysFieldLabel(l.finCategoryIcon),
          SysChoiceChips<String>(
            choices: [for (final g in _glyphs) SysChoice(g.name, '', glyph: g)],
            selected: {categoryGlyph(_c).name},
            allowEmpty: false,
            onChanged: (s) => setState(() => _c = _c.copyWith(icon: Value(s.first))),
          ),
          if (widget.kind == FinTxKind.expense) ...[
            const SysFieldGap(),
            SysSwitchRow(
              label: l.finJunkFood,
              hint: l.finJunkFoodHint,
              value: _c.junkFood,
              onChanged: (v) => setState(() => _c = _c.copyWith(junkFood: v)),
            ),
          ],
          if (existing != null) ...[
            const SysFieldGap(),
            SysSwitchRow(
              label: l.finHide,
              hint: l.finHideHint,
              value: _c.archived,
              onChanged: (v) => setState(() => _c = _c.copyWith(archived: v)),
            ),
          ],
          const SizedBox(height: 16),
          Row(children: [
            if (existing != null && !_builtin) ...[
              Expanded(
                child: SysButton.danger(
                  label: l.commonDelete,
                  expand: true,
                  onPressed: () async {
                    await ref.read(financeRepositoryProvider).deleteCategory(existing);
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
