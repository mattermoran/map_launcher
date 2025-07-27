import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/directions_url.dart';
import 'package:map_launcher/src/marker_url.dart';
import 'package:map_launcher/src/models.dart';

import 'map_launcher_platform_interface.dart';

class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  /// Returns list of installed map apps on the device.
  @override
  Future<List<AvailableMap>> get installedMaps async {
    final maps = await methodChannel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  /// Opens map app specified in [mapType]
  /// and shows marker at [coords]
  @override
  Future<dynamic> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int? zoom,
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
      'url': Uri.encodeFull(url),
      'title': title,
      'description': description,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    return methodChannel.invokeMethod('showMarker', args);
  }

  /// Opens map app specified in [mapType]
  /// and shows directions to [destination]
  @override
  Future<dynamic> showDirections({
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
      'url': Uri.encodeFull(url),
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
    return methodChannel.invokeMethod('showDirections', args);
  }

  /// Returns boolean indicating if map app is installed
  @override
  Future<bool?> isMapAvailable(MapType mapType) async {
    return methodChannel.invokeMethod('isMapAvailable', {
      'mapType': mapType.name,
    });
  }
}
