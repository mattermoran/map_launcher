import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';
import 'package:map_launcher/src/utils.dart';

String getMapDirectionsUrl({
  @required MapType mapType,
  @required Coords destination,
  Coords origin,
  String title,
  String description,
  DirectionsMode directionsMode,
}) {
  switch (mapType) {
    case MapType.google:
      if (Platform.isIOS) {
        final queryParams = buildQueryParams({
          'daddr': '${destination.latitude},${destination.longitude}',
          'saddr':
              origin == null ? null : '${origin.latitude},${origin.longitude}',
          'directionsmode':
              directionsMode == null ? null : enumToString(directionsMode),
        });

        return 'comgooglemaps://?$queryParams';
      }

      final queryParams = buildQueryParams({
        'api': '1',
        'destination': '${destination.latitude},${destination.longitude}',
        'origin':
            origin == null ? null : '${origin.latitude},${origin.longitude}',
        'travelmode':
            directionsMode == null ? null : enumToString(directionsMode),
      });

      return 'https://www.google.com/maps/dir/?$queryParams';

    case MapType.apple:
      return 'http://maps.apple.com/maps?saddr=${destination.latitude},${destination.longitude}';
    default:
      return null;
  }
}
