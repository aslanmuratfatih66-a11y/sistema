// Карта прогулки: тайлы OSM, линия маршрута по режимам, старт и текущая точка.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/enums.dart';
import '../../../domain/walks/walk_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../domain/geo.dart';

const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Тайлы из сети; тесты выключают (без HTTP).
final walkMapTilesProvider = Provider<bool>((ref) => true);

Color walkModeColor(WalkMode m) => switch (m) {
      WalkMode.walk => SysColors.accentLight,
      WalkMode.brisk => SysColors.gold,
      WalkMode.cardio => SysColors.danger,
      WalkMode.rest => SysColors.success,
    };

LatLng _ll(GeoPoint p) => LatLng(p.lat, p.lon);

class WalkMap extends ConsumerWidget {
  const WalkMap({super.key, this.plan, this.position, this.height = 260});

  final RoutePlan? plan;
  final GeoPoint? position;
  final double height;

  List<Polyline> _lines(RoutePlan plan) {
    final pts = plan.points;
    if (pts.length < 2) return const [];
    if (plan.segments.isEmpty) {
      return [Polyline(points: [for (final p in pts) _ll(p)], color: SysColors.accentLight, strokeWidth: 5)];
    }
    final cum = cumulativeDistances(pts);
    return [
      for (final s in plan.segments)
        Polyline(
          points: [for (final p in slicePolyline(pts, cum, s.fromM, s.toM)) _ll(p)],
          color: walkModeColor(s.mode),
          strokeWidth: 5,
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tiles = ref.watch(walkMapTilesProvider);
    final p = plan;
    final pos = position;
    final hasRoute = p != null && p.points.length >= 2;
    final center = pos ?? (hasRoute ? p.points.first : null);
    if (center == null) return const SizedBox.shrink();
    final options = hasRoute
        ? MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: [for (final q in p.points) _ll(q)],
              padding: const EdgeInsets.all(28),
            ),
          )
        : MapOptions(initialCenter: _ll(center), initialZoom: 15);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SysDims.radius),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          // Новый маршрут — новая камера.
          key: ValueKey(Object.hash(p, hasRoute ? null : center)),
          options: options,
          children: [
            if (tiles) TileLayer(urlTemplate: osmTileUrl, userAgentPackageName: 'com.sistema.sistema'),
            if (hasRoute) PolylineLayer(polylines: _lines(p)),
            MarkerLayer(markers: [
              if (hasRoute)
                Marker(point: _ll(p.points.first), width: 18, height: 18, child: const SysDiamond(size: 14)),
              if (pos != null)
                Marker(
                  point: _ll(pos),
                  width: 18,
                  height: 18,
                  child: Container(
                    key: const Key('wlk-position'),
                    decoration: BoxDecoration(
                      color: SysColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: SysColors.textPrimary, width: 2),
                    ),
                  ),
                ),
            ]),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                color: SysColors.background.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                child: Text(l.wlkMapAttribution, style: SysText.caption),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
