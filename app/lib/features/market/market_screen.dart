// Маркет покупок (SPEC §8.8): подборка от ИИ под план, примерные цены с датой и источником, пометка по бюджету,
// ссылки на магазины (поиск или товар), сохранить / скрыть / «купил» (→ операция в финансах), обновить цену.
// Без входа и сети подборка недоступна, сохранённое видно офлайн.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/ai/ai_api.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/widgets/shopping_list_panel.dart';
import 'market_data.dart';
import 'market_settings.dart';

enum _Tab { fresh, saved, bought }

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String? _category; // null — все
  _Tab _tab = _Tab.fresh;
  bool _suggesting = false;
  final Set<String> _pricing = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshBudget());
  }

  Future<void> _refreshBudget() async {
    try {
      final items = await ref.read(marketRepositoryProvider).all();
      await ref.read(marketBudgetUpdaterProvider).refresh(items);
    } catch (_) {}
  }

  ({String lang, String country}) get _region =>
      marketRegion(ref.read(marketProfileLocaleProvider), Localizations.localeOf(context).languageCode);

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  String _aiError(AppLocalizations l, AiException e) => switch (e.failure) {
        AiFailure.notSignedIn => l.mktErrNotSignedIn,
        AiFailure.offline => l.mktErrOffline,
        AiFailure.budget => l.mktErrBudget,
        AiFailure.unavailable => l.mktErrUnavailable,
        AiFailure.rateLimited => l.mktErrRateLimited,
        AiFailure.server => l.mktErrServer,
      };

  Future<void> _showError(String message) async {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    await showSystemWindow<void>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.warning,
        label: l.mktNoticeLabel,
        message: message,
        actions: [Builder(builder: (b) => SysButton.secondary(label: l.commonClose, onPressed: () => Navigator.of(b).pop()))],
      ),
    );
  }

  Future<void> _suggest() async {
    if (_suggesting) return;
    final l = AppLocalizations.of(context);
    final region = _region;
    setState(() => _suggesting = true);
    try {
      final repo = ref.read(marketRepositoryProvider);
      final ctx = await ref.read(marketContextBuilderProvider).build();
      final existing = await repo.all();
      final exclude = [
        for (final r in existing.take(60)) r.title,
      ];
      final list = await ref.read(marketApiProvider).suggest(
            lang: region.lang,
            country: region.country,
            category: _category,
            context: ctx,
            exclude: exclude,
          );
      final added = await repo.addSuggestions(list);
      if (added == 0) {
        await _showError(l.mktNothingFound);
      } else {
        if (mounted) setState(() => _tab = _Tab.fresh);
        _toast(l.mktAdded(added));
        await _refreshBudget();
      }
    } on AiException catch (e) {
      await _showError(_aiError(l, e));
    } catch (_) {
      await _showError(l.mktErrServer);
    } finally {
      if (mounted) setState(() => _suggesting = false);
    }
  }

  Future<void> _refreshPrice(MarketItemRow row) async {
    if (_pricing.contains(row.id)) return;
    final l = AppLocalizations.of(context);
    setState(() => _pricing.add(row.id));
    try {
      final p = await ref.read(marketApiProvider).price(title: row.title, country: _region.country, force: true);
      if (p == null) {
        _toast(l.mktPriceNotFound);
      } else {
        final repo = ref.read(marketRepositoryProvider);
        await repo.setPrice(row, p);
        final fresh = await repo.byId(row.id);
        if (fresh != null) await ref.read(marketBudgetUpdaterProvider).refresh([fresh]);
        _toast(l.mktPriceUpdated);
      }
    } on AiException catch (e) {
      await _showError(_aiError(l, e));
    } catch (_) {
      await _showError(l.mktErrServer);
    } finally {
      if (mounted) setState(() => _pricing.remove(row.id));
    }
  }

  Future<void> _bought(MarketItemRow row) async {
    final l = AppLocalizations.of(context);
    final paid = await showDialog<int>(
      context: context,
      barrierColor: SysColors.barrier,
      builder: (_) => _BoughtDialog(row: row),
    );
    if (paid == null || !mounted) return;
    final links = MarketLink.decode(row.links);
    final store = links.where((x) => !x.search).firstOrNull?.store;
    final res = await ref
        .read(marketPurchaseRecorderProvider)
        .record(row, paid: paid, currency: row.currency, store: store == null ? null : storeName(store));
    await ref
        .read(marketRepositoryProvider)
        .markBought(row, paid: paid, currency: row.currency, transactionId: res.id);
    if (mounted) setState(() => _tab = _Tab.bought);
    _toast(res.ok ? l.mktBoughtRecorded : l.mktBoughtNoFinance);
  }

  Future<void> _openLink(MarketLink link) async {
    final l = AppLocalizations.of(context);
    var ok = false;
    try {
      ok = await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!ok) {
      await Clipboard.setData(ClipboardData(text: link.url));
      _toast(l.mktOpenFailed);
    }
  }

  Future<void> _copyLink(MarketLink link) async {
    await Clipboard.setData(ClipboardData(text: link.url));
    if (mounted) _toast(AppLocalizations.of(context).mktLinkCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = ref.watch(marketItemsProvider).value ?? const <MarketItemRow>[];
    final prefs = ref.watch(marketPrefsProvider).value ?? const MarketPrefs();
    bool inTab(MarketItemRow r, _Tab t) => switch (t) {
          _Tab.fresh => r.status == MarketStatus.suggested,
          _Tab.saved => r.status == MarketStatus.saved,
          _Tab.bought => r.status == MarketStatus.bought,
        };
    final byCat = [for (final r in all) if (_category == null || r.category == _category) r];
    final items = [for (final r in byCat) if (inTab(r, _tab)) r];
    int count(_Tab t) => byCat.where((r) => inTab(r, t)).length;

    // Во вкладке «Магазин» → «Покупки»: без своей шапки, сверху — список покупок.
    final embedded = EmbeddedTab.of(context);
    final list = ListView(
            key: const Key('market-list'),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (embedded) ...[
                const ShoppingListPanel(),
                const SizedBox(height: 12),
              ] else
                Row(
                  children: [
                    const SysBackButton(),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(l.mktTitle.toUpperCase(), style: SysText.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              SysButton.primary(
                label: _suggesting ? l.mktSuggesting : l.mktSuggest,
                icon: SysGlyph.shop,
                expand: true,
                onPressed: _suggesting ? null : _suggest,
              ),
              if (_suggesting) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 2, color: SysColors.accent, backgroundColor: Colors.transparent),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: l.mktCatAll, selected: _category == null, onTap: () => setState(() => _category = null)),
                  for (final c in marketCategories)
                    _Chip(
                      label: categoryLabel(l, c),
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _Tab.values)
                    _Chip(
                      label: '${switch (t) {
                        _Tab.fresh => l.mktTabNew,
                        _Tab.saved => l.mktTabSaved,
                        _Tab.bought => l.mktTabBought,
                      }} · ${count(t)}',
                      selected: _tab == t,
                      tone: PanelTone.gold,
                      onTap: () => setState(() => _tab = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                SysEmptyState(
                  title: l.mktTitle,
                  hint: switch (_tab) {
                    _Tab.fresh => l.mktEmptyNew,
                    _Tab.saved => l.mktEmptySaved,
                    _Tab.bought => l.mktEmptyBought,
                  },
                  glyph: switch (_tab) {
                    _Tab.fresh => SysGlyph.sparkle,
                    _Tab.saved => SysGlyph.star,
                    _Tab.bought => SysGlyph.check,
                  },
                )
              else ...[
                for (final r in items) ...[
                  _ItemCard(
                    row: r,
                    pricing: _pricing.contains(r.id),
                    prefs: prefs,
                    onSave: () => ref.read(marketRepositoryProvider).setStatus(r, MarketStatus.saved),
                    onHide: () => ref.read(marketRepositoryProvider).setStatus(r, MarketStatus.dismissed),
                    onBought: () => _bought(r),
                    onRefreshPrice: () => _refreshPrice(r),
                    onOpen: _openLink,
                    onCopy: _copyLink,
                  ),
                  const SizedBox(height: 10),
                ],
                Text(l.mktEstimateNote, style: SysText.caption, textAlign: TextAlign.center),
              ],
            ],
          );
    if (embedded) return Material(type: MaterialType.transparency, child: list);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(child: SafeArea(child: list)),
    );
  }
}

String categoryLabel(AppLocalizations l, String c) => switch (c) {
      'skin' => l.mktCatSkin,
      'nutrition' => l.mktCatNutrition,
      'equipment' => l.mktCatEquipment,
      _ => l.mktCatOther,
    };

/// Названия магазинов (имена собственные, не переводятся).
String storeName(String store) => switch (store) {
      'ozon' => 'Ozon',
      'wildberries' => 'Wildberries',
      'yandex_market' => 'Яндекс Маркет',
      'pyaterochka' => 'Пятёрочка',
      'trendyol' => 'Trendyol',
      _ => store,
    };

/// Сумма в мин. единицах → «1 290 ₽».
String formatMoney(int minor, String currency, String locale) {
  final v = minor / 100;
  final nf = v == v.roundToDouble() ? NumberFormat.decimalPattern(locale) : NumberFormat('#,##0.00', locale);
  final sym = switch (currency) {
    'RUB' => '₽',
    'TRY' => '₺',
    'USD' => r'$',
    'EUR' => '€',
    _ => currency,
  };
  return '${nf.format(v == v.roundToDouble() ? v.round() : v)} $sym';
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap, this.tone = PanelTone.accent});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final PanelTone tone;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SysDims.minTap),
            child: Align(
              widthFactor: 1,
              child: Opacity(opacity: selected ? 1 : .7, child: SysPill(label: label, tone: tone)),
            ),
          ),
        ),
      );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.row,
    required this.pricing,
    required this.prefs,
    required this.onSave,
    required this.onHide,
    required this.onBought,
    required this.onRefreshPrice,
    required this.onOpen,
    required this.onCopy,
  });

  final MarketItemRow row;
  final bool pricing;
  final MarketPrefs prefs;
  final VoidCallback onSave;
  final VoidCallback onHide;
  final VoidCallback onBought;
  final VoidCallback onRefreshPrice;
  final ValueChanged<MarketLink> onOpen;
  final ValueChanged<MarketLink> onCopy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.localeName;
    final bought = row.status == MarketStatus.bought;
    // Только выбранные в настройках магазины; если ни одного не осталось — все ссылки.
    final allLinks = MarketLink.decode(row.links);
    final picked = [for (final x in allLinks) if (prefs.allows(x.store)) x];
    final links = picked.isEmpty ? allLinks : picked;
    final price = row.price;
    final at = row.priceAt;
    final String priceText;
    if (price == null) {
      priceText = l.mktPriceUnknown;
    } else if (bought) {
      priceText = l.mktPricePaid(formatMoney(price, row.currency, locale));
    } else {
      final money = formatMoney(price, row.currency, locale);
      final date = at == null ? '—' : DateFormat.yMd(locale).format(at.toLocal());
      final src = row.priceSource?.trim() ?? '';
      priceText = src.isEmpty ? l.mktPriceShort(money, date) : l.mktPriceLine(money, src, date);
    }
    final budget = MarketBudget.values.where((b) => b.name == row.budget).firstOrNull;

    return SysPanel(
      animateIn: false,
      tone: bought ? PanelTone.success : PanelTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(categoryLabel(l, row.category).toUpperCase(), style: SysText.caption),
          const SizedBox(height: 2),
          Text(row.title, style: SysText.title),
          if ((row.reason ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(row.reason!, style: SysText.secondary),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(priceText, style: SysText.monoSmall)),
              if (!bought)
                pricing
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: SysLoader(size: 20, semanticLabel: l.mktRefreshPrice),
                      )
                    : SysIconButton(glyph: SysGlyph.refresh, tooltip: l.mktRefreshPrice, onPressed: onRefreshPrice),
            ],
          ),
          if (!bought && budget != null) ...[
            const SizedBox(height: 4),
            SysPill(
              label: switch (budget) {
                MarketBudget.ok => l.mktBudgetOk,
                MarketBudget.afterIncome => l.mktBudgetAfterIncome,
                MarketBudget.over => l.mktBudgetOver,
              },
              tone: switch (budget) {
                MarketBudget.ok => PanelTone.success,
                MarketBudget.afterIncome => PanelTone.gold,
                MarketBudget.over => PanelTone.danger,
              },
            ),
          ],
          if (links.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in links)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onOpen(link),
                      onLongPress: () => onCopy(link),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: SysDims.minTap),
                        child: Align(
                          widthFactor: 1,
                          child: SysPill(
                            label: link.search ? '${storeName(link.store)} · ${l.mktSearchSuffix}' : storeName(link.store),
                            tone: link.search ? PanelTone.accent : PanelTone.boss,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (!bought) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (row.status == MarketStatus.suggested) SysButton.secondary(label: l.mktSave, onPressed: onSave),
                SysButton.primary(label: l.mktBought, onPressed: onBought),
                SysButton.secondary(label: l.mktHide, onPressed: onHide),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Ввод фактической цены покупки (в валюте товара). Возвращает мин. единицы.
class _BoughtDialog extends StatefulWidget {
  const _BoughtDialog({required this.row});

  final MarketItemRow row;

  @override
  State<_BoughtDialog> createState() => _BoughtDialogState();
}

class _BoughtDialogState extends State<_BoughtDialog> {
  num? _value;

  @override
  void initState() {
    super.initState();
    final p = widget.row.price;
    if (p != null) _value = p % 100 == 0 ? p ~/ 100 : p / 100;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = _value;
    final valid = v != null && v > 0 && v < 100000000;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SysPanel(
        title: l.mktBoughtTitle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.mktBoughtMessage(widget.row.title), style: SysText.body),
            const SizedBox(height: 12),
            SysNumberField(
              value: _value,
              label: l.mktBoughtPrice,
              unit: widget.row.currency,
              min: 0,
              max: 100000000,
              onChanged: (x) => setState(() => _value = x),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 8),
                SysButton.primary(
                  label: l.mktBoughtConfirm,
                  onPressed: valid ? () => Navigator.of(context).pop((v * 100).round()) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
