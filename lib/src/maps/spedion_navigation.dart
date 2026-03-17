import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// SPEDION Navigation — Android only, uses `geo:` scheme.
class SpedionNavigationBuilder extends MapUrlBuilder {
  /// Creates a [SpedionNavigationBuilder].
  const SpedionNavigationBuilder();

  @override
  MapType get mapType => .spedionNavigation;

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
    url: 'geo:${coords.latlng}',
    queryParams: {if (coords.title != null) 'q': '(${coords.title})'},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'geo:${destination.latlng}',
    queryParams: {if (destination.title != null) 'q': '(${destination.title})'},
  );
}
