import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/directions_url.dart';
import 'package:map_launcher/src/marker_url.dart';
import 'package:map_launcher/src/models.dart';

import 'map_launcher_platform_interface.dart';

/// An implementation of [MapLauncherPlatform] that uses a method channel
/// to communicate with the native iOS and Android code.
class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  /// Returns a list of [AvailableMap] objects representing the map apps
  /// currently installed on the device.
  @override
  Future<List<AvailableMap>> get installedMaps async {
    final maps = await methodChannel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  /// Opens the map application specified by [mapType] and displays a marker at [coords].
  ///
  /// - [mapType]: The map application to launch.
  /// - [coords]: Coordinates where the marker should be placed.
  /// - [title]: Title for the marker.
  /// - [description]: Optional description for the marker.
  /// - [zoom]: Optional zoom level (default is 16).
  /// - [extraParams]: Extra map-specific query parameters.
  @override
  Future<void> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int zoom = 16,
    Map<String, String>? extraParams,
  }) async {
    final String url = getMapMarkerUrl(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
      extraParams: extraParams,
    );

    final Map<String, String?> args = {
      'mapType': mapType.name,
      'url': url,
      'title': title,
      'description': description,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    await methodChannel.invokeMethod('showMarker', args);
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

  @override
  Future<void> showDirections({
    required MapType mapType,
    required Coords destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Waypoint>? waypoints,
    DirectionsMode? directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) async {
    final url = getMapDirectionsUrl(
      mapType: mapType,
      destination: destination,
      destinationTitle: destinationTitle,
      origin: origin,
      originTitle: originTitle,
      waypoints: waypoints,
      directionsMode: directionsMode,
      extraParams: extraParams,
    );

    final Map<String, dynamic> args = {
      'mapType': mapType.name,
      'url': url,
      'destinationTitle': destinationTitle,
      'destinationLatitude': destination.latitude.toString(),
      'destinationLongitude': destination.longitude.toString(),
      'destinationtitle': destinationTitle,
      'originLatitude': origin?.latitude.toString(),
      'originLongitude': origin?.longitude.toString(),
      'originTitle': originTitle,
      'directionsMode': directionsMode?.name,
      'waypoints': waypoints
          ?.map(
            (waypoint) => {
              'latitude': waypoint.latitude.toString(),
              'longitude': waypoint.longitude.toString(),
              'title': waypoint.title,
            },
          )
          .toList(),
    };
    await methodChannel.invokeMethod('showDirections', args);
  }

  /// Returns `true` if the map app of type [mapType] is installed on the device,
  /// `false` otherwise.
  @override
  Future<bool> isMapAvailable(MapType mapType) async {
    final result = await methodChannel.invokeMethod('isMapAvailable', {
      'mapType': mapType.name,
    });
    return result as bool;
  }
}
