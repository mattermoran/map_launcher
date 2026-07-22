import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Neshan — mobile only, directions with origin.
class NeshanBuilder extends MapUrlBuilder {
  /// Creates a [NeshanBuilder].
  const NeshanBuilder();

  @override
  MapType get mapType => .neshan;

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
  }) {
    if (platform == .ios) {
      return buildUrl(
        url: 'neshan://',
        queryParams: {'destination': coords.latlng},
      );
    }
    return buildUrl(
      url: 'https://nshn.ir',
      queryParams: {'lat': coords.lat.toString(), 'lng': coords.lng.toString()},
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: platform == .ios ? 'neshan://' : 'https://nshn.ir/',
    queryParams: {
      if (origin != null) 'origin': origin.latlng,
      'destination': destination.latlng,
    },
  );
}
