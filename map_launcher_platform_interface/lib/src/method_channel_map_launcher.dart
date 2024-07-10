import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';
import 'package:map_launcher_platform_interface/src/directions_url.dart';
import 'package:map_launcher_platform_interface/src/marker_url.dart';
import 'package:map_launcher_platform_interface/src/models.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// An implementation of [MapLauncherPlatform] that uses method channels.
class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  @override
  Future<List<AvailableMap>> getAvailableMaps() async {
    final availableMapsJson = await methodChannel
        .invokeMethod<List<Map<String, dynamic>>>('getAvailableMaps');

    if (availableMapsJson == null) {
      throw Exception('Failed to fetch available maps');
    }

    return List<AvailableMap>.from(
      availableMapsJson.map(AvailableMap.fromJson),
    );
  }

  @override
  Future<void> showMarker({
    required Location location,
    MapType? mapType,
    int? zoom,
    Map<String, String>? extraParams,
  }) {
    final mapUrl = getMapMarkerUrl(
      location: location,
      mapType: mapType,
      zoom: zoom,
      extraParams: extraParams,
    );
    return launchUrlString(mapUrl);
  }

  @override
  Future<void> showDirections({
    required Location destination,
    MapType? mapType,
    Location? origin,
    List<Location>? waypoints,
    DirectionsMode directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) async {
    final directionsUrl = getMapDirectionsUrl(
      destination: destination,
      mapType: mapType,
      origin: origin,
      waypoints: waypoints,
      directionsMode: directionsMode,
      extraParams: extraParams,
    );
    await launchUrlString(directionsUrl);
  }
}
