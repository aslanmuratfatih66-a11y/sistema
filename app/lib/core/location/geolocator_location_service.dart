// LocationService на geolocator; «Всегда» — через permission_handler (geolocator на Android 11+ фон сам не просит).
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../domain/walks/walk_api.dart';

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static LocationAccess mapPermission(LocationPermission p) => switch (p) {
        LocationPermission.always => LocationAccess.always,
        LocationPermission.whileInUse => LocationAccess.whenInUse,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.denied,
      };

  @override
  Future<LocationAccess> access() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.unavailable;
      return mapPermission(await Geolocator.checkPermission());
    } catch (_) {
      return LocationAccess.unavailable;
    }
  }

  @override
  Future<LocationAccess> requestWhenInUse() async {
    final now = await access();
    if (now != LocationAccess.denied) return now;
    try {
      return mapPermission(await Geolocator.requestPermission());
    } catch (_) {
      return LocationAccess.unavailable;
    }
  }

  @override
  Future<LocationAccess> requestAlways() async {
    // Сначала «при использовании» — без него система «всегда» не предложит.
    final base = await requestWhenInUse();
    if (base != LocationAccess.whenInUse) return base;
    try {
      await ph.Permission.locationAlways.request();
    } catch (e) {
      debugPrint('locationAlways: $e');
    }
    return access();
  }

  @override
  Future<LocationFix?> current() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      return positionToFix(p);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        return last == null ? null : positionToFix(last);
      } catch (_) {
        return null;
      }
    }
  }
}

LocationFix positionToFix(Position p) => LocationFix(
      point: GeoPoint(p.latitude, p.longitude),
      at: p.timestamp,
      accuracyM: p.accuracy > 0 ? p.accuracy : null,
      speedMps: p.speed >= 0 ? p.speed : null,
    );

/// Тексты постоянного уведомления Android (foreground service).
typedef TrackingNotice = ({String title, String text, String channel});

/// Настройки потока для прогулки с выключенным экраном.
LocationSettings walkLocationSettings(TrackingNotice notice) {
  const distanceFilter = 3;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    case TargetPlatform.android:
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notice.title,
          notificationText: notice.text,
          notificationChannelName: notice.channel,
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    default:
      return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distanceFilter);
  }
}

/// Поток точек geolocator для трекинга (ошибки потока — пропускаются, чтобы трекинг не падал).
Stream<LocationFix> geolocatorFixes(TrackingNotice notice) => Geolocator.getPositionStream(
      locationSettings: walkLocationSettings(notice),
    ).handleError((Object e) => debugPrint('position stream: $e')).map(positionToFix);
