import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'map_launcher_method_channel.dart';

/// The platform interface for the [MapLauncher] plugin.
///
/// This defines the contract for platform-specific implementations.
/// The platform layer is intentionally thin. It only handles:
/// 1. Launching URLs (opening in browser/app)
/// 2. Detecting installed native apps (mobile only)
abstract class MapLauncherPlatform extends PlatformInterface {
  /// Creates a [MapLauncherPlatform].
  MapLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static MapLauncherPlatform _instance = MethodChannelMapLauncher();

  /// The default instance of [MapLauncherPlatform].
  static MapLauncherPlatform get instance => _instance;

  static set instance(MapLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Launch a URL. Opens in the native app if it handles the URL,
  /// otherwise opens in the default browser.
  ///
  /// On Android, [androidPackageName] targets the specific app package
  /// so the system resolver doesn't open a different app (e.g. Go vs Maps).
  Future<void> launch(String url, {String? androidPackageName}) {
    throw UnimplementedError('launch() has not been implemented.');
  }

  /// Returns the ids of maps (from [maps]) that have native apps installed.
  ///
  /// The probing payload (URL schemes on iOS, package names on Android) is
  /// derived from each [MapApp] and sent to the native side. No map
  /// knowledge is hardcoded in native code.
  ///
  /// Returns an empty set on platforms that don't support app detection.
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) {
    throw UnimplementedError('getInstalledMaps() has not been implemented.');
  }

  /// The platform this app is running on, or `null` on web/desktop.
  ///
  /// Used for selecting the correct URL scheme (e.g. `comgooglemaps://`
  /// on iOS vs `geo:` on Android) and determining whether scheme URLs
  /// are supported at all (`null` = web/desktop, use universal links only).
  MapPlatform? get platform => null;
}
