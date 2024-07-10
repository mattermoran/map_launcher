import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

export 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart'
    show AvailableMap, DirectionsMode, Location, MapType;

MapLauncherPlatform get _platform => MapLauncherPlatform.instance;

/// The namespace for the map_launcher methods.
class MapLauncher {
  /// Gets a list of available maps on the device.
  static Future<List<AvailableMap>> getAvailableMaps() async {
    return _platform.getAvailableMaps();
  }

  /// Shows the map with the given location.
  static Future<void> showMarker({
    required Location location,
    MapType? mapType,
    int? zoom,
    Map<String, String>? extraParams,
  }) {
    return _platform.showMarker(
      location: location,
      mapType: mapType,
      zoom: zoom,
      extraParams: extraParams,
    );
  }

  /// Shows the directions from the origin to the destination.
  static Future<void> showDirections({
    required Location destination,
    MapType? mapType,
    Location? origin,
    List<Location>? waypoints,
    DirectionsMode directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) {
    return _platform.showDirections(
      destination: destination,
      mapType: mapType,
      origin: origin,
      waypoints: waypoints,
      directionsMode: directionsMode,
      extraParams: extraParams,
    );
  }
}
