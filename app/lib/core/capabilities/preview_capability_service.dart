import 'capability_service.dart';
import 'platform_capability_service.dart';

/// Заглушка [CapabilityService] для веб-предпросмотра (`lib/main_preview.dart`).
/// Нативного канала нет: возвращает матрицу возможностей выбранной платформы
/// (SPEC §3) и выдуманную дату истечения профиля, чтобы был виден баннер.
///
/// Настраивается через `--dart-define`:
/// - `PREVIEW_PLATFORM=ios|android` (по умолчанию ios);
/// - `PREVIEW_CERT_DAYS=N` — через сколько дней «истекает» сертификат
///   (по умолчанию 5; отрицательное — уже истёк; только для ios).
class PreviewCapabilityService implements CapabilityService {
  PreviewCapabilityService({
    this.platform = const String.fromEnvironment('PREVIEW_PLATFORM', defaultValue: 'ios'),
    this.certDays = const int.fromEnvironment('PREVIEW_CERT_DAYS', defaultValue: 5),
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final String platform;
  final int certDays;
  final DateTime Function() now;

  @override
  Future<DeviceCapabilities> load() async => DeviceCapabilities(
        platform: platform,
        available: PlatformCapabilityService.capabilitiesFor(platform),
        // Профиль подписи бывает только у iOS-сайдлоада.
        provisioningExpiresAt: platform == 'ios' ? now().add(Duration(days: certDays)) : null,
      );
}
