import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/map_type.dart';
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
  Future<void> launch(String url, {MapType? mapType}) async {
    web.window.open(url, '_blank');
  }

  @override
  Future<List<MapType>> getInstalledMaps() async {
    // Web doesn't have "installed" map apps — universal links only
    return [];
  }

  // platform defaults to null (web) from base class — no override needed
}
