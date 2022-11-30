import 'dart:async';

import 'package:flutter/services.dart';
import 'package:map_launcher/src/directions_url.dart';
import 'package:map_launcher/src/marker_url.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

class MapLauncher {
  static const MethodChannel _channel = const MethodChannel('map_launcher');

  /// Returns list of installed map apps on the device.
  static Future<List<AvailableMap>> get installedMaps async {
    final maps = await _channel.invokeMethod('getInstalledMaps');
    return List<AvailableMap>.from(
      maps.map((map) => AvailableMap.fromJson(map)),
    );
  }

  @Deprecated('use showMarker instead')
  static Future<dynamic> launchMap({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
  }) {
    return showMarker(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
    );
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
    final String url = getMapMarkerUrl(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
      extraParams: extraParams,
    );

    final Map<String, String?> args = {
      'mapType': Utils.enumToString(mapType),
      'url': Uri.encodeFull(url),
      'title': title,
      'description': description,
      'latitude': coords.latitude.toString(),
      'longitude': coords.longitude.toString(),
    };
    return _channel.invokeMethod('showMarker', args);
  }

  /// Opens map app specified in [mapType]
  /// and shows directions to [destination]
  ///
  /// [destination], the coordinates of the destination. When it is `null`, use
  /// [destinationTitle] to search destination, currently only some maps support it.
  ///
  /// - [MapType.apple], supported
  /// - [MapType.google], supported
  /// - [MapType.googleGo], supported
  /// - [MapType.amap], supported
  /// - [MapType.baidu], supported
  /// - [MapType.tencent], partially supported, you need to manually click the input box to search.
  /// - others map not tested, fallback to [Coords.zero]
  static Future<dynamic> showDirections({
    required MapType mapType,
    required Coords? destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Coords>? waypoints,
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
      'mapType': Utils.enumToString(mapType),
      'url': Uri.encodeFull(url),
      // On iOS, MapKit does not support destination being null, use `UIApplication.shared.open()` instead.
      'perfectUseMapKit': destination != null,
      'destinationTitle': destinationTitle,
      'destinationLatitude': (destination?.latitude ?? 0.0).toString(),
      'destinationLongitude': (destination?.longitude ?? 0.0).toString(),
      'originLatitude': origin?.latitude.toString(),
      'originLongitude': origin?.longitude.toString(),
      'originTitle': originTitle,
      'directionsMode': Utils.enumToString(directionsMode),
    };
    return _channel.invokeMethod('showDirections', args);
  }

  /// Returns boolean indicating if map app is installed
  static Future<bool?> isMapAvailable(MapType mapType) async {
    return _channel.invokeMethod(
      'isMapAvailable',
      {'mapType': Utils.enumToString(mapType)},
    );
  }
}
