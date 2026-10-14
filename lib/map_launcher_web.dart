import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
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
    final opened = web.window.open(url, '_blank');
    if (opened == null) {
      throw const MapHandoffException(
        'The browser blocked the map window. Allow popups and retry.',
        blocked: true,
      );
    }
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    // Web doesn't have "installed" map apps. Universal links only.
    return {};
  }

  // platform defaults to null (web) from base class, no override needed
}
