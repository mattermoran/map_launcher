import 'dart:async';

import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models.dart';

class MapLauncher {
  /// Returns list of installed map apps on the device.
  static Future<List<AvailableMap>> get installedMaps async {
    return MapLauncherPlatform.instance.installedMaps;
  }

  /// Opens map app specified in [mapType]
  /// and shows marker at [coords]
  static Future<dynamic> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int? zoom,
    Map<String, String>? extraParams,
  }) async {
    return MapLauncherPlatform.instance.showMarker(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
      extraParams: extraParams,
    );
  }

  /// Opens map app specified in [mapType]
  /// and shows directions to [destination]
  static Future<dynamic> showDirections({
    required MapType mapType,
    required Coords destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Waypoint>? waypoints,
    DirectionsMode? directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) async {
    MapLauncherPlatform.instance.showDirections(
      mapType: mapType,
      destination: destination,
      destinationTitle: destinationTitle,
      origin: origin,
      originTitle: originTitle,
      waypoints: waypoints,
      directionsMode: directionsMode,
      extraParams: extraParams,
    );
  }

  /// Returns boolean indicating if map app is installed
  static Future<bool?> isMapAvailable(MapType mapType) async {
    return MapLauncherPlatform.instance.isMapAvailable(mapType);
  }
}
