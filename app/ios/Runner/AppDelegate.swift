import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Канал платформенных данных (SPEC §3: CapabilityService).
  private var platformChannel: FlutterMethodChannel?
  private var stepCounter: StepCounterChannel?
  private var maps: MapKitChannel?
  private var nowPlaying: NowPlayingChannel?
  private var live: LiveActivityChannel?
  private var alarm: AlarmKitChannel?

  /// BGAppRefresh: перепланирование окна уведомлений (SPEC §7). Совпадает с Info.plist и Dart (notifications).
  static let refreshTaskId = "com.sistema.sistema.refresh"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Уведомления на переднем плане и кнопки действий (flutter_local_notifications).
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // Фоновая задача: обработчик регистрируется до конца запуска (требование BGTaskScheduler).
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: AppDelegate.refreshTaskId, earliestBeginInSeconds: NSNumber(value: 15 * 60))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Кнопки уведомлений обрабатываются в отдельном isolate — ему тоже нужны плагины.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "sistema/platform",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getProvisioningInfo":
        var info: [String: Any] = ["expiresAt": NSNull()]
        if let date = AppDelegate.provisioningExpirationDate() {
          let formatter = ISO8601DateFormatter()
          formatter.formatOptions = [.withInternetDateTime]
          info["expiresAt"] = formatter.string(from: date)
        }
        result(info)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    platformChannel = channel
    // Шаги (этап 3): CoreMotion.
    stepCounter = StepCounterChannel(messenger: engineBridge.applicationRegistrar.messenger())
    // Этап 4: маршруты, аудио, Live Activity.
    let messenger = engineBridge.applicationRegistrar.messenger()
    maps = MapKitChannel(messenger: messenger)
    nowPlaying = NowPlayingChannel(messenger: messenger)
    live = LiveActivityChannel(messenger: messenger)
    // Этап 7: будильник-квест (AlarmKit).
    alarm = AlarmKitChannel(messenger: messenger)
  }

  /// Дата истечения профиля подписи из embedded.mobileprovision.
  /// nil — файла нет (App Store, симулятор) или его не удалось разобрать.
  static func provisioningExpirationDate() -> Date? {
    guard
      let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision"),
      let data = FileManager.default.contents(atPath: path),
      // Файл — CMS-подпись с вложенным XML plist; Latin-1 декодирует любые байты.
      let text = String(data: data, encoding: .isoLatin1),
      let start = text.range(of: "<?xml"),
      let end = text.range(of: "</plist>", range: start.lowerBound..<text.endIndex)
    else {
      return nil
    }
    let plistText = String(text[start.lowerBound..<end.upperBound])
    guard
      let plistData = plistText.data(using: .isoLatin1),
      let plist = try? PropertyListSerialization.propertyList(
        from: plistData, options: [], format: nil),
      let dict = plist as? [String: Any]
    else {
      return nil
    }
    return dict["ExpirationDate"] as? Date
  }
}
