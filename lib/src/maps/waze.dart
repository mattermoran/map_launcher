import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Waze — navigation only. Coordinates, single destination.
class WazeBuilder extends MapUrlBuilder {
  /// Creates a [WazeBuilder].
  const WazeBuilder();

  @override
  bool get supportsMarkerCoords => false;

  @override
  bool supportsTravelMode(TravelMode mode) => mode == .driving;

  @override
  MapType get mapType => .waze;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => buildUrl(
    url: 'https://waze.com/ul',
    queryParams: {'ll': destination.latlng, 'navigate': 'yes'},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'waze://',
    queryParams: {'ll': destination.latlng, 'navigate': 'yes'},
  );
}
