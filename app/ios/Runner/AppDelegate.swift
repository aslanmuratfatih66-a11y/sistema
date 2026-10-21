import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Канал платформенных данных (SPEC §3: CapabilityService).
  private var platformChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
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
