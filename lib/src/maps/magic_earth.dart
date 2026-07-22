import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Magic Earth — mobile only, uses `magicearth://` scheme.
///
/// Marker: `magicearth://?show_on_map&lat=..&lon=..&name=..&zoom=..`
/// Directions: `magicearth://?<mode>&lat=..&lon=..` (iOS)
///             `magicearth://?get_directions&<mode>&lat=..&lon=..` (Android)
class MagicEarthBuilder extends MapUrlBuilder {
  /// Creates a [MagicEarthBuilder].
  const MagicEarthBuilder();

  @override
  MapType get mapType => .magicEarth;

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
    final url = buildUrl(
      url: 'magicearth://',
      queryParams: {
        'lat': coords.lat.toString(),
        'lon': coords.lng.toString(),
        if (coords.title != null) 'name': coords.title!,
        if (zoom != null) 'zoom': zoom.toString(),
      },
    );
    return url.replaceFirst('?', '?show_on_map&');
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    final mode = _directionsMode(travelMode);
    final flags = platform == MapPlatform.ios ? mode : 'get_directions&$mode';
    final url = buildUrl(
      url: 'magicearth://',
      queryParams: {
        'lat': destination.lat.toString(),
        'lon': destination.lng.toString(),
      },
    );
    return url.replaceFirst('?', '?$flags&');
  }

  String _directionsMode(TravelMode? mode) => switch (mode) {
    TravelMode.driving => 'drive_to',
    TravelMode.walking => 'walk_to',
    TravelMode.transit => 'public_transport_to',
    TravelMode.bicycling => 'bike_to',
    null => 'drive_to',
  };
}
