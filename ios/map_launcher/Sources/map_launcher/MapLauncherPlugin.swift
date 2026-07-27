import Flutter
import UIKit



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
            let probes = call.arguments as? [String: String] ?? [:]
            // Schemes must be declared in the host app's Info.plist under
            // LSApplicationQueriesSchemes for canOpenURL to work. Report
            // undeclared ones separately so the Dart side can warn: for
            // those, canOpenURL returns false whether or not the app is
            // installed, which is otherwise indistinguishable.
            let declared = Set(
                (Bundle.main.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes")
                    as? [String] ?? []).map { $0.lowercased() }
            )
            var installed: [String] = []
            var undeclared: [String] = []
            for (id, probe) in probes {
                guard let url = URL(string: probe),
                      let scheme = url.scheme?.lowercased() else { continue }
                if !declared.contains(scheme) {
                    undeclared.append(id)
                } else if UIApplication.shared.canOpenURL(url) {
                    installed.append(id)
                }
            }
            result(["installed": installed, "undeclared": undeclared])

        default:
            result(FlutterMethodNotImplemented)
        }
    }

}
