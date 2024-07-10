import 'dart:io';

import 'package:map_launcher_platform_interface/src/models.dart';

/// Constructs a url from [url] and [queryParams]
String buildUrl({
  required String url,
  required Map<String, String?> queryParams,
}) {
  return queryParams.entries.fold('$url?', (String previousValue, element) {
    if (element.value == null || element.value == '') {
      return previousValue;
    }
    return '$previousValue&${element.key}=${element.value}';
  }).replaceFirst('&', '');
}

/// Returns a url that is used by [showDirections]
String getMapDirectionsUrl({
  required Location destination,
  MapType? mapType,
  Location? origin,
  DirectionsMode? directionsMode,
  List<Location>? waypoints,
  Map<String, String>? extraParams,
}) {
  return 'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
}
