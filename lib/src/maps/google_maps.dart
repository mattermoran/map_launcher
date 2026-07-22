import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Google Maps — supports coordinates, text queries, directions with
/// origin, waypoints, and travel mode.
class GoogleMapsBuilder extends MapUrlBuilder {
  /// Creates a [GoogleMapsBuilder].
  const GoogleMapsBuilder();

  @override
  bool get supportsMarkerSearch => true;

  @override
  bool get supportsDirectionsSearch => true;

  @override
  bool get supportsWaypoints => true;

  @override
  MapType get mapType => .google;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) => buildUrl(
    url: 'https://www.google.com/maps/search/',
    queryParams: {
      'api': '1',
      'query': coords.latlng,
      if (zoom != null) 'z': zoom.toString(),
    },
  );

  @override
  String markerSearchUrl(String query) => buildUrl(
    url: 'https://www.google.com/maps/search/',
    queryParams: {'api': '1', 'query': query},
  );

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => _directionsUrlFull(
    destination: destination,
    origin: origin,
    waypoints: waypoints,
    travelMode: travelMode,
  );

  @override
  String directionsSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
  }) => _directionsUrlFull(
    destination: LocationSearch(query),
    origin: origin,
    travelMode: travelMode,
  );

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) {
    if (platform == .ios) {
      return buildUrl(
        url: 'comgooglemaps://',
        queryParams: {
          'q': coords.title != null
              ? '${coords.latlng}(${coords.title})'
              : coords.latlng,
          if (zoom != null) 'zoom': zoom.toString(),
        },
      );
    }
    return null;
  }

  @override
  String? markerSchemeSearchUrl(String query, {required MapPlatform platform}) {
    if (platform == .ios) {
      return buildUrl(url: 'comgooglemaps://', queryParams: {'q': query});
    }
    return null;
  }

  @override
  String? directionsSchemeSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    if (platform == .ios) {
      return buildUrl(
        url: 'comgooglemaps://',
        queryParams: {
          'daddr': query,
          if (origin != null) 'saddr': origin.latlng,
          if (travelMode != null) 'directionsmode': travelMode.name,
        },
      );
    }
    return null;
  }

  static String _directionsUrlFull({
    required Location destination,
    Location? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) {
    return buildUrl(
      url: 'https://www.google.com/maps/dir/',
      queryParams: {
        'api': '1',
        'destination': switch (destination) {
          LocationCoords c => c.latlng,
          LocationSearch q => q.query,
        },
        if (origin != null)
          'origin': switch (origin) {
            LocationCoords c => c.latlng,
            LocationSearch q => q.query,
          },
        if (waypoints != null && waypoints.isNotEmpty)
          'waypoints': waypoints.map((w) => w.latlng).join('|'),
        if (travelMode != null) 'travelmode': travelMode.name,
      },
    );
  }
}
