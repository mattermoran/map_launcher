import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/mapswithme_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// MAPS.ME. Mobile only; routes require an explicit origin.
class MapsMe extends MapApp {
  /// Creates a [MapsMe].
  const MapsMe();

  @override
  String get id => 'mapswithme';

  @override
  String get name => 'MAPS.ME';

  @override
  String? get playStoreId => 'com.mapswithme.maps.pro';

  @override
  String? get appStoreId => '510623322';

  // The app registers both mapswithme:// and mapsme://. Detection uses
  // mapswithme:// because that is the scheme consumers declare in
  // LSApplicationQueriesSchemes (per the README, unchanged since 5.x).
  @override
  String? get iosScheme => 'mapswithme://';

  @override
  Uint8List get iconBytes => mapswithmeIcon;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => null;

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'mapsme://map',
    queryParams: {
      'v': '1',
      'll': coords.latlng,
      if (coords.title != null) 'n': coords.title!,
    },
  ).replaceAll('+', '%20');

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    if (origin == null) return null;
    // The legacy parser requires these five keys in this order, even when
    // names are empty. buildUrl deliberately drops empty values. Its decoder
    // only handles percent escapes, so spaces must not use form-encoded '+'.
    return Uri(
      scheme: 'mapsme',
      host: 'route',
      queryParameters: {
        'sll': origin.latlng,
        'saddr': origin.title ?? '',
        'dll': destination.latlng,
        'daddr': destination.title ?? '',
        'type': switch (travelMode ?? TravelMode.driving) {
          .driving => 'vehicle',
          .walking => 'pedestrian',
          .transit => 'transit',
          .bicycling => 'bicycle',
        },
      },
    ).toString().replaceAll('+', '%20');
  }
}
