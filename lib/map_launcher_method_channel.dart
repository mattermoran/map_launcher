import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/directions_url.dart';
import 'package:map_launcher/src/marker_url.dart';
import 'package:map_launcher/src/models.dart';

import 'map_launcher_platform_interface.dart';

/// An implementation of [MapLauncherPlatform] that uses method channels.
class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  @override
  Future<List<AvailableMap>> getInstalledMaps() async {
    final maps = await methodChannel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  @override
  Future<void> showMarker(MapMarkerParams params) async {
    final String url = getMapMarkerUrl(params);

    final Map<String, String?> args = {
      'mapType': params.mapType.name,
      'url': Uri.encodeFull(url),
      'title': params.title,
      'description': params.description,
      'latitude': params.coords.latitude.toString(),
      'longitude': params.coords.longitude.toString(),
    };

    return methodChannel.invokeMethod('showMarker', args);
  }

  @override
  Future<void> showDirections(MapDirectionsParams params) async {
    final url = getMapDirectionsUrl(params);

    final Map<String, dynamic> args = {
      'mapType': params.mapType.name,
      'url': Uri.encodeFull(url),
      'destinationTitle': params.destinationTitle,
      'destinationLatitude': params.destination.latitude.toString(),
      'destinationLongitude': params.destination.longitude.toString(),
      'destinationtitle': params.destinationTitle,
      'originLatitude': params.origin?.latitude.toString(),
      'originLongitude': params.origin?.longitude.toString(),
      'originTitle': params.originTitle,
      'directionsMode': params.directionsMode?.name,
      'waypoints': (params.waypoints ?? [])
          .map((waypoint) => {
                'latitude': waypoint.latitude.toString(),
                'longitude': waypoint.longitude.toString(),
              })
          .toList(),
    };
    return methodChannel.invokeMethod('showDirections', args);
  }

  @override
  Future<bool> isMapAvailable(MapType mapType) async {
    final isAvailable = await methodChannel.invokeMethod<bool>(
      'isMapAvailable',
      {'mapType': mapType.name},
    );
    return isAvailable ?? false;
  }
}
