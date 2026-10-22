// «Магазин рядом»: ближайшие магазины/вода → пеший маршрут до выбранного (RouteService.toPlace).
// Открывается кнопкой на экране прогулок или извне: `context.push('/walks?shop=water')` (или shop=1 — продукты).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/walks/walk_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'walk_l10n.dart';

/// Текущая точка: доступ «При использовании» (запросить при необходимости) → фикс. null — нет доступа/фикса.
Future<GeoPoint?> currentWalkPoint(LocationService loc) async {
  try {
    var access = await loc.access();
    if (access == LocationAccess.denied) access = await loc.requestWhenInUse();
    if (access != LocationAccess.whenInUse && access != LocationAccess.always) return null;
    return (await loc.current())?.point;
  } on Object catch (e) {
    debugPrint('Walks: location: $e');
    return null;
  }
}

/// Шит выбора места. Возвращает маршрут до выбранного места или null (закрыли/не построился).
Future<RoutePlan?> showNearbyShopSheet(BuildContext context, {PlaceCategory category = PlaceCategory.grocery}) =>
    showModalBottomSheet<RoutePlan>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SysColors.background,
      builder: (_) => NearbyShopSheet(initialCategory: category),
    );

class NearbyShopSheet extends ConsumerStatefulWidget {
  const NearbyShopSheet({super.key, this.initialCategory = PlaceCategory.grocery});

  final PlaceCategory initialCategory;

  @override
  ConsumerState<NearbyShopSheet> createState() => _NearbyShopSheetState();
}

class _NearbyShopSheetState extends ConsumerState<NearbyShopSheet> {
  late PlaceCategory _category = widget.initialCategory;
  GeoPoint? _start;
  List<Place>? _places;
  bool _loading = false;
  bool _routing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _places = null;
    });
    final l = AppLocalizations.of(context);
    final start = _start ?? await currentWalkPoint(ref.read(locationServiceProvider));
    if (!mounted) return;
    if (start == null) {
      setState(() {
        _loading = false;
        _error = l.wlkNoLocation;
      });
      return;
    }
    _start = start;
    final category = _category;
    final places = await ref.read(routeServiceProvider).nearby(start, category);
    if (!mounted || category != _category) return;
    setState(() {
      _loading = false;
      _places = places;
    });
  }

  Future<void> _go(Place place) async {
    final start = _start;
    if (start == null || _routing) return;
    setState(() => _routing = true);
    final plan = await ref.read(routeServiceProvider).toPlace(start, place.point);
    if (!mounted) return;
    if (plan == null) {
      setState(() {
        _routing = false;
        _error = AppLocalizations.of(context).wlkNoRoute;
      });
      return;
    }
    Navigator.of(context).pop(plan);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final places = _places;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SysPanel(
          key: const Key('wlk-shop-sheet'),
          title: l.wlkShop,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SysSegmented<PlaceCategory>(
                choices: [
                  SysChoice(PlaceCategory.grocery, l.wlkGrocery),
                  SysChoice(PlaceCategory.water, l.wlkWater),
                ],
                value: _category,
                onChanged: (c) {
                  if (c == _category) return;
                  _category = c;
                  _load();
                },
              ),
              const SizedBox(height: 12),
              if (_loading || _routing)
                Text(l.wlkSearching, key: const Key('wlk-shop-loading'), style: SysText.secondary)
              else if (_error != null)
                Text(_error!, key: const Key('wlk-shop-error'), style: SysText.secondary)
              else if (places != null && places.isEmpty)
                SysEmptyState.inline(l.wlkNothingNearby, key: const Key('wlk-shop-empty'), glyph: SysGlyph.shop)
              else if (places != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final (i, p) in places.indexed)
                        InkWell(
                          key: Key('wlk-place-$i'),
                          onTap: () => _go(p),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: SysDims.minTap),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SysIcon(_category == PlaceCategory.water ? SysGlyph.water : SysGlyph.shop, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name.isEmpty ? l.wlkUnnamed : p.name, style: SysText.body),
                                        if (p.address != null) Text(p.address!, style: SysText.caption),
                                      ],
                                    ),
                                  ),
                                  Text(l.wlkKm(formatKm(p.distanceM ?? 0)), style: SysText.mono),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
