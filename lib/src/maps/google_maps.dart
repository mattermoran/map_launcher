import 'package:flutter/foundation.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/google_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Google Maps. Supports coordinates, text queries, directions with
/// origin, waypoints, and travel mode.
class GoogleMaps extends MapApp {
  /// Creates a [GoogleMaps].
  const GoogleMaps();

  @override
  String get id => 'google';

  @override
  String get name => 'Google Maps';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.google.android.apps.maps';

  @override
  String? get appStoreId => '585027354';

  @override
  String? get iosScheme => 'comgooglemaps://';

  @override
  Uint8List get iconBytes => googleIcon;

  @override
  bool get supportsMarkerSearch => true;

  @override
  bool get supportsDirectionsSearch => true;

  @override
  String directionsSearchOriginKey(String url) =>
      url.startsWith('comgooglemaps:') ? 'saddr' : 'origin';

  @override
  bool get supportsWaypoints => true;

  @override
  bool requiresUniversalUrl(Map<String, String> extra) => const {
    'query_place_id',
    'dir_action',
    'destination_place_id',
    'origin_place_id',
    'waypoint_place_ids',
  }.any(extra.containsKey);

  @override
  void validateLaunchUrl(String url) {
    final uri = Uri.parse(url);
    final params = uri.queryParameters;
    for (final entry in const {
      'query_place_id': 'query',
      'destination_place_id': 'destination',
      'origin_place_id': 'origin',
      'waypoint_place_ids': 'waypoints',
    }.entries) {
      if (params.containsKey(entry.key) &&
          params[entry.value]?.trim().isNotEmpty != true) {
        throw MapConfigurationError('${entry.key} requires ${entry.value}.');
      }
    }
    if (params.containsKey('dir_action') &&
        !uri.path.startsWith('/maps/dir/')) {
      throw MapConfigurationError('dir_action requires a directions request.');
    }
  }

  @override
  void validateLaunchTransport(
    String url, {
    MapPlatform? platform,
    bool packageTargeted = false,
  }) {
    if (Uri.parse(url).scheme == 'https' && url.length > 2048) {
      throw MapConfigurationError(
        'Google Maps URLs must not exceed 2048 characters.',
      );
    }
    final stops = Uri.parse(url).queryParameters['waypoints'];
    if (stops == null || stops.isEmpty) return;
    final mobile =
        platform != null ||
        (kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS));
    // Unpinned HTTPS may open in a mobile browser, even if an app is installed.
    final limit = mobile && !packageTargeted ? 3 : 9;
    if (stops.split('|').length > limit) {
      throw MapConfigurationError(
        'This Google Maps transport supports at most $limit waypoints.',
      );
    }
  }

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) => buildUrl(
    url: 'https://www.google.com/maps/search/',
    queryParams: {'api': '1', 'query': coords.latlng},
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
