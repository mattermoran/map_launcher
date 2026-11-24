import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/organic_maps_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// Organic Maps. Mobile only; routes require an explicit origin.
///
/// Uses the legacy `om://map` and `om://route` links. The advertised v2
/// `om://v2/dir` link is not handled by the released app: on iOS it opens
/// the app without doing anything.
class OrganicMaps extends MapApp {
  /// Creates an [OrganicMaps].
  const OrganicMaps();

  @override
  String get id => 'organicMaps';

  @override
  String get name => 'Organic Maps';

  @override
  String? get playStoreId => 'app.organicmaps';

  @override
  String? get appStoreId => '1567437057';

  @override
  String? get iosScheme => 'om://';

  @override
  Uint8List get iconBytes => organicMapsIcon;

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
    url: 'om://map',
    queryParams: {
      'v': '1',
      'll': coords.latlng,
      if (coords.title != null) 'n': coords.title!,
      if (zoom != null) 'z': zoom.toString(),
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
    // Same legacy parser as MAPS.ME: these five keys in this order, even when
    // names are empty, and percent escapes only (no form-encoded '+').
    return Uri(
      scheme: 'om',
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
