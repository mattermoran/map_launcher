import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:web/web.dart' as web;

/// Web implementation.
///
/// Uses `window.open()` to open map URLs in a new browser tab.
/// Registered via `pluginClass` / `fileName` in pubspec.yaml.
class MapLauncherWeb extends MapLauncherPlatform {
  /// Registers this class as the platform implementation.
  static void registerWith([Object? registrar]) {
    MapLauncherPlatform.instance = MapLauncherWeb();
  }

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    web.window.open(url, '_blank');
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    // Web doesn't have "installed" map apps. Universal links only.
    return {};
  }

  // platform defaults to null (web) from base class, no override needed
}
