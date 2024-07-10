import FlutterMacOS
import Foundation

public class MapLauncherPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "map_launcher_macos",
      binaryMessenger: registrar.messenger)
    let instance = MapLauncherPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformName":
      result("MacOS")    
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
