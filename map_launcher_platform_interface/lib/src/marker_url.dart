import 'dart:io';

import 'package:map_launcher_platform_interface/src/models.dart';

/// Returns a url that is used by [showMarker]
String getMapMarkerUrl({
  required Location location,
  MapType? mapType,
  String? title,
  String? description,
  int? zoom,
  Map<String, String>? extraParams,
}) {
  final zoomLevel = zoom ?? 16;
  return 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
  // switch (mapType) {
  //   case MapType.google:
  //     return Utils.buildUrl(
  //       url: Platform.isIOS ? 'comgooglemaps://' : 'geo:0,0',
  //       queryParams: {
  //         'q':
  //             '${coords.latitude},${coords.longitude}${title != null && title.isNotEmpty ? '($title)' : ''}',
  //         'zoom': '$zoomLevel',
  //         ...(extraParams ?? {}),
  //       },
  //     );
  // }
}
