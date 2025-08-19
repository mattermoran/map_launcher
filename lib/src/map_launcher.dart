import 'dart:async';

import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models.dart';

/// Provides a simple interface for launching installed map applications
/// to display markers, show directions, or query availability.
class MapLauncher {
  MapLauncher._();

  /// Returns a list of [AvailableMap] objects representing the map apps
  /// currently installed on the device.
  static Future<List<AvailableMap>> get installedMaps async {
    return MapLauncherPlatform.instance.installedMaps;
  }

  /// Opens the map application specified by [mapType] and displays a marker at [coords].
  ///
  /// - [mapType]: The map application to launch.
  /// - [coords]: Coordinates where the marker should be placed.
  /// - [title]: Title for the marker.
  /// - [description]: Optional description for the marker.
  /// - [zoom]: Optional zoom level (default is 16).
  /// - [extraParams]: Extra map-specific query parameters.
  static Future<void> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int zoom = 16,
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

  /// Opens the map application specified by [mapType] and shows directions to [destination].
  ///
  /// - [mapType]: The map application to launch.
  /// - [destination]: Coordinates of the destination.
  /// - [destinationTitle]: Optional label for the destination.
  /// - [origin]: Optional starting point. If omitted, the map app may use the current location.
  /// - [originTitle]: Optional label for the origin.
  /// - [waypoints]: Optional list of intermediate waypoints along the route.
  /// - [directionsMode]: Mode of transport (default is [DirectionsMode.driving]).
  /// - [extraParams]: Extra map-specific query parameters.
  static Future<void> showDirections({
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

  /// Returns `true` if the map app of type [mapType] is installed on the device,
  /// `false` otherwise.
  static Future<bool> isMapAvailable(MapType mapType) async {
    return MapLauncherPlatform.instance.isMapAvailable(mapType);
  }
}
