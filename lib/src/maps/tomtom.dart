import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// TomTom Go — navigation only, destination only.
class TomTomGoBuilder extends MapUrlBuilder {
  /// Creates a [TomTomGoBuilder].
  const TomTomGoBuilder();

  @override
  MapType get mapType => .tomtomgo;

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
      // iOS: uses navigate endpoint even for markers (original behavior)
      return buildUrl(
        url: 'tomtomgo://x-callback-url/navigate',
        queryParams: {'destination': coords.latlng},
      );
    }
    // Android: geo: intent with optional title
    final titleFormatted = coords.title != null
        ? '(${Uri.encodeComponent(coords.title!)})'
        : '';
    return buildUrl(
      url: 'geo:${coords.latlng}',
      queryParams: {'q': '${coords.latlng}$titleFormatted'},
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    if (platform == .ios) {
      return buildUrl(
        url: 'tomtomgo://x-callback-url/navigate',
        queryParams: {'destination': destination.latlng},
      );
    }
    // The TomTom Go app cannot handle the ? at the start of the query
    return buildUrl(
      url: 'google.navigation:',
      queryParams: {'q': destination.latlng},
    ).replaceFirst('?', '');
  }
}

/// TomTom Go Fleet — Android only, navigation only.
class TomTomGoFleetBuilder extends TomTomGoBuilder {
  /// Creates a [TomTomGoFleetBuilder].
  const TomTomGoFleetBuilder();

  @override
  MapType get mapType => .tomtomgofleet;
}
