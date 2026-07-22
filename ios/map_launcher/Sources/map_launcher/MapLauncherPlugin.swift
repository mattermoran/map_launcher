import Flutter
import UIKit

/// Map of Dart MapType enum name → iOS URL scheme prefix.
///
/// Used to detect installed map apps via `UIApplication.canOpenURL`.
/// Each scheme must be declared in the host app's `Info.plist` under
/// `LSApplicationQueriesSchemes`.
private let mapSchemes: [String: String] = [
    "apple": "", // Apple Maps is always available on iOS
    "google": "comgooglemaps://",
    "amap": "iosamap://",
    "baidu": "baidumap://",
    "waze": "waze://",
    "yandexNavi": "yandexnavi://",
    "yandexMaps": "yandexmaps://",
    "citymapper": "citymapper://",
    "mapswithme": "mapswithme://",
    "osmand": "osmandmaps://",
    "doubleGis": "dgis://",
    "tencent": "qqmap://",
    "here": "here-location://",
    "tomtomgo": "tomtomgo://",
    "sygicTruck": "com.sygic.aura://",
    "copilot": "copilot://",
    "naver": "nmap://",
    "kakao": "kakaomap://",
    "tmap": "tmap://",
    "mapyCz": "szn-mapy://",
    "mappls": "mappls://",
    "moovit": "moovit://",
    "neshan": "neshan://",
    "airnavPro": "airnavpro://",
    "magicEarth": "magicearth://",
]

/// Flutter plugin for map_launcher on iOS.
///
/// Provides two method channel calls:
/// - `launch` — opens a URL via `UIApplication.shared.open`
/// - `getInstalledMaps` — detects installed map apps via `canOpenURL`
public class MapLauncherPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "map_launcher",
            binaryMessenger: registrar.messenger()
        )
        let instance = MapLauncherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "launch":
            guard let args = call.arguments as? [String: Any],
                  let urlString = args["url"] as? String,
                  let url = URL(string: urlString) else {
                result(
                    FlutterError(
                        code: "INVALID_URL",
                        message: "Missing or invalid 'url' argument",
                        details: nil
                    )
                )
                return
            }
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "LAUNCH_FAILED",
                            message: "Failed to open URL: \(urlString)",
                            details: nil
                        )
                    )
                }
            }

        case "getInstalledMaps":
            let installed = mapSchemes.compactMap { (mapType, scheme) -> [String: String]? in
                if isMapAvailable(mapType: mapType, scheme: scheme) {
                    return ["mapType": mapType]
                }
                return nil
            }
            result(installed)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Checks whether a map app is available on the device.
    ///
    /// Apple Maps is always available. Other apps are detected
    /// via `UIApplication.canOpenURL` using their URL scheme prefix.
    private func isMapAvailable(mapType: String, scheme: String) -> Bool {
        if mapType == "apple" {
            return true
        }
        guard !scheme.isEmpty, let url = URL(string: scheme) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}
