export 'package:map_launcher/src/models.dart';

import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models.dart';

class MapLauncher {
  /// Returns list of installed map apps on the device.
  static Future<List<AvailableMap>> getInstalledMaps() {
    return MapLauncherPlatform.instance.getInstalledMaps();
  }

  /// Opens map app specified in [MapMarkerParams.mapType]
  /// and shows marker at [MapMarkerParams.coords]
  static Future<void> showMarker(MapMarkerParams params) async {
    return MapLauncherPlatform.instance.showMarker(params);
  }

  /// Opens map app specified in [MapDirectionsParams.mapType]
  /// and shows directions to [MapDirectionsParams.destination]
  static Future<void> showDirections(MapDirectionsParams params) async {
    return MapLauncherPlatform.instance.showDirections(params);
  }

  /// Returns boolean indicating if map app is installed
  static Future<bool> isMapAvailable(MapType mapType) async {
    return MapLauncherPlatform.instance.isMapAvailable(mapType);
  }
}
