import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Citymapper — directions only, with optional origin.
class CitymapperBuilder extends MapUrlBuilder {
  /// Creates a [CitymapperBuilder].
  const CitymapperBuilder();

  /// Intentionally `false` even though [markerSchemeUrl] returns a non-null
  /// URL. Citymapper is a nav-only app — [markerSchemeUrl] routes to
  /// directions as a best-effort fallback, not a true marker pin.
  @override
  bool get supportsMarkerCoords => false;

  @override
  MapType get mapType => .citymapper;

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
  }) => _directionsUrl(coords); // best-effort: opens directions to that point

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => _directionsUrl(destination, origin: origin);

  static String _directionsUrl(
    LocationCoords destination, {
    LocationCoords? origin,
  }) {
    return buildUrl(
      url: 'citymapper://directions',
      queryParams: {
        'endcoord': destination.latlng,
        'endname': ?destination.title,
        if (origin != null) ...{
          'startcoord': origin.latlng,
          if (origin.title != null) 'startname': origin.title!,
        },
      },
    );
  }
}
