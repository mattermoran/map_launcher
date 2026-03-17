import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// CoPilot — mobile only, destination only.
class CoPilotBuilder extends MapUrlBuilder {
  /// Creates a [CoPilotBuilder].
  const CoPilotBuilder();

  @override
  MapType get mapType => .copilot;

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
    url: 'copilot://mydestination',
    queryParams: {
      'type': 'LOCATION',
      'action': 'VIEW',
      'marker': coords.latlng,
      if (coords.title != null) 'name': coords.title!,
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
    url: 'copilot://mydestination',
    queryParams: {
      'type': 'LOCATION',
      'action': 'GOTO',
      'name': destination.title ?? '',
      'lat': destination.lat.toString(),
      'long': destination.lng.toString(),
    },
  );
}
