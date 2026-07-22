import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Petal Maps — Android only, directions with origin and travel mode.
class PetalMapsBuilder extends MapUrlBuilder {
  /// Creates a [PetalMapsBuilder].
  const PetalMapsBuilder();

  @override
  MapType get mapType => .petal;

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
    url: 'petalmaps://poidetail',
    queryParams: {
      'marker': coords.latlng,
      if (zoom != null) 'z': zoom.toString(),
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
    url: 'petalmaps://route',
    queryParams: {
      'daddr': '${destination.latlng}${_label(destination)}',
      if (origin != null) 'saddr': '${origin.latlng}${_label(origin)}',
      'type': switch (travelMode) {
        .driving => 'drive',
        .walking => 'walk',
        .transit => 'bus',
        .bicycling => 'bike',
        null => 'drive',
      },
    },
  );

  static String _label(LocationCoords c) =>
      c.title != null ? '(${Uri.encodeComponent(c.title!)})' : '';
}
