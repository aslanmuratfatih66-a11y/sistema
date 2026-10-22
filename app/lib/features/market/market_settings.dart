// Параметры покупок (Настройки → «Персонаж и ИИ» → «Покупки»): магазины и месячный бюджет на покупки.
// Хранятся в AppSettings; маркет показывает ссылки только выбранных магазинов, передаёт их и бюджет в контекст
// подбора, а товар дороже месячного бюджета помечает «не по бюджету».
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'market_screen.dart' show storeName;

const _storesKey = 'market.stores';
const _budgetKey = 'market.monthBudgetRub';

/// Все магазины, на которые сервер даёт ссылки.
const marketStores = ['ozon', 'wildberries', 'yandex_market', 'pyaterochka', 'trendyol'];

class MarketPrefs {
  const MarketPrefs({this.stores, this.monthBudgetRub});

  /// null — все магазины.
  final Set<String>? stores;

  /// Рублей в месяц; null — без лимита.
  final int? monthBudgetRub;

  bool allows(String store) => stores == null || stores!.contains(store);
}

final marketPrefsProvider = FutureProvider<MarketPrefs>((ref) async {
  final db = ref.watch(databaseProvider);
  final rawStores = await db.getSetting(_storesKey);
  final rawBudget = await db.getSetting(_budgetKey);
  final stores = rawStores == null ? null : {for (final s in rawStores.split(',')) if (s.isNotEmpty) s};
  return MarketPrefs(
    stores: stores == null || stores.isEmpty ? null : stores,
    monthBudgetRub: int.tryParse(rawBudget ?? ''),
  );
});

Future<void> saveMarketPrefs(WidgetRef ref, MarketPrefs p) async {
  final db = ref.read(databaseProvider);
  final stores = p.stores;
  if (stores == null || stores.length == marketStores.length) {
    await db.deleteSetting(_storesKey);
  } else {
    await db.setSetting(_storesKey, stores.join(','));
  }
  final budget = p.monthBudgetRub;
  if (budget == null || budget <= 0) {
    await db.deleteSetting(_budgetKey);
  } else {
    await db.setSetting(_budgetKey, '$budget');
  }
  ref.invalidate(marketPrefsProvider);
}

Future<void> showMarketSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _MarketSettingsSheet(),
    );

class _MarketSettingsSheet extends ConsumerStatefulWidget {
  const _MarketSettingsSheet();

  @override
  ConsumerState<_MarketSettingsSheet> createState() => _MarketSettingsSheetState();
}

class _MarketSettingsSheetState extends ConsumerState<_MarketSettingsSheet> {
  Set<String>? _stores;
  num? _budget;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(marketPrefsProvider).value;
    if (!_loaded && prefs != null) {
      _loaded = true;
      _stores = prefs.stores ?? marketStores.toSet();
      _budget = prefs.monthBudgetRub;
    }
    final stores = _stores ?? marketStores.toSet();
    return SingleChildScrollView(
      key: const Key('market-settings-sheet'),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: l.mktSettingsTitle),
          const SizedBox(height: 12),
          SysFieldLabel(l.mktSettingsStores),
          const SizedBox(height: 8),
          SysChoiceChips<String>(
            multi: true,
            choices: [for (final s in marketStores) SysChoice(s, storeName(s))],
            selected: stores,
            onChanged: (v) => setState(() => _stores = v),
          ),
          const SizedBox(height: 16),
          SysNumberField(
            label: l.mktSettingsBudget,
            unit: '₽',
            decimal: false,
            min: 0,
            value: _budget,
            onChanged: (v) => _budget = v,
          ),
          const SizedBox(height: 4),
          Text(l.mktSettingsBudgetHint, style: SysText.caption),
          const SizedBox(height: 16),
          SysButton.primary(
            key: const Key('market-settings-save'),
            label: l.commonDone,
            expand: true,
            onPressed: () async {
              final nav = Navigator.of(context);
              await saveMarketPrefs(
                ref,
                MarketPrefs(stores: stores.isEmpty ? null : stores, monthBudgetRub: _budget?.round()),
              );
              nav.pop();
            },
          ),
        ],
      ),
    );
  }
}
