import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Google Maps Go — Android only, coordinates, directions with travel mode.
class GoogleMapsGoBuilder extends MapUrlBuilder {
  /// Creates a [GoogleMapsGoBuilder].
  const GoogleMapsGoBuilder();

  @override
  MapType get mapType => .googleGo;

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
    url: 'geo:0,0',
    queryParams: {
      'q': coords.title != null
          ? '${coords.latlng}(${coords.title})'
          : coords.latlng,
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
    url: 'google.navigation:',
    queryParams: {
      'q': destination.latlng,
      if (travelMode != null) 'mode': travelMode.name.substring(0, 1),
    },
  );
}
