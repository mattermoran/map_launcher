import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// MAPS.ME — mobile only, destination only.
class MapsMeBuilder extends MapUrlBuilder {
  /// Creates a [MapsMeBuilder].
  const MapsMeBuilder();

  @override
  MapType get mapType => .mapswithme;

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
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'mapsme://route',
    queryParams: {
      'v': '1',
      'll': destination.latlng,
      if (destination.title != null) 'n': destination.title!,
    },
  );
}
