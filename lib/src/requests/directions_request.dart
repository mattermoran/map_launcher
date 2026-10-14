import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/supported_map.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/launch_helper.dart';

/// An immutable request to show directions on a map.
///
/// Created via [MapLauncher.directions]. Call [show] to open,
/// [getSupportedMaps] to discover available maps, or [getUrl]
/// to get the raw URL.
///
/// ```dart
/// await MapLauncher.directions(
///   .coords(48.85, 2.29, title: 'Eiffel Tower'),
///   from: .coords(48.86, 2.34, title: 'Louvre'),
///   mode: TravelMode.walking,
/// ).show();
/// ```
class DirectionsRequest {
  /// Creates a [DirectionsRequest]. Prefer [MapLauncher.directions].
  ///
  /// * [destination] The destination location (coordinates or search query).
  /// * [from] Optional origin; accepts coordinates or search text. When null,
  ///   the map app may use the device's current location.
  /// * [mode] Travel mode (driving, walking, transit, bicycling).
  /// * [waypoints] Intermediate stops (coordinates only). Not supported by all maps.
  /// * [extra] Raw query options for explicit `show(map: ...)` only.
  /// * [providerExtras] Conditional options bound to each provider ID.
  ///
  /// Collections are copied into unmodifiable snapshots.
  DirectionsRequest({
    required this.destination,
    this.from,
    this.mode,
    List<LocationCoords>? waypoints,
    Map<String, String>? extra,
    Map<MapApp, Map<String, String>> providerExtras = const {},
  }) : waypoints = waypoints == null ? null : List.unmodifiable(waypoints),
       extra = extra == null ? null : Map.unmodifiable(extra),
       providerExtras = snapshotProviderExtras(providerExtras);

  /// The destination (coordinates or search query).
  final Location destination;

  /// Optional origin. Accepts coordinates or search text.
  /// If null, the map app may use the device's current location.
  final Location? from;

  /// Travel mode (driving, walking, transit, bicycling).
  final TravelMode? mode;

  /// Intermediate waypoints (coordinates only).
  /// Requires a coordinate destination and a map with waypoint support.
  final List<LocationCoords>? waypoints;

  /// Raw query parameters for explicit launches; not usable during discovery.
  final Map<String, String>? extra;

  /// Options applied only when their provider ID is selected.
  /// Essential routing requirements belong in the portable request fields.
  final Map<MapApp, Map<String, String>> providerExtras;

  /// Shows directions in a map app.
  ///
  /// If [map] is null, tries eligible [defaultMaps] in order. Explicit selection
  /// never switches providers. Retries require a confirmed failed handoff;
  /// blocked or unknown outcomes stop with [MapLaunchException].
  ///
  /// * [extra] Additional query parameters merged with constructor [extra];
  ///   values from this call take precedence on conflict.
  Future<void> show({MapApp? map, Map<String, String>? extra}) async {
    final mergedExtra = {...?this.extra, ...?extra};
    if (map == null) requireScopedExtras(mergedExtra);
    await showMapRequest(
      map: map,
      prepare: (candidate) => _prepare(candidate, mergedExtra),
    );
  }

  PreparedMapLaunch _prepare(
    MapApp map, [
    Map<String, String> extra = const {},
  ]) => prepareMapLaunch(
    map: map,
    url: getUrl(map: map),
    universalUrl: getUniversalUrl(map: map),
    extra: {...providerOptions(map, providerExtras), ...extra},
  );

  /// Returns the base URL for [map], without opening or appending extras.
  ///
  /// On mobile, prefers the native scheme URL. On web/desktop, always
  /// returns the universal HTTPS URL. Returns `null` if unsupported.
  /// [show] validates caller configuration and may select a universal URL
  /// when the extras require it.
  String? getUrl({required MapApp map}) {
    if (!_supportsRequest(map)) return null;
    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    String? url = map.bestDirectionsUrl(
      destination: destination,
      origin: coordsOrigin,
      waypoints: waypoints,
      travelMode: mode,
      platform: MapLauncherPlatform.instance.platform,
    );

    return _appendSearchOrigin(url, map);
  }

  /// Returns the universal (HTTPS) URL for [map], or `null` if unsupported.
  String? getUniversalUrl({required MapApp map}) {
    if (!_supportsRequest(map)) return null;
    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    String? url = switch (destination) {
      LocationCoords coords => map.directionsUrl(
        destination: coords,
        origin: coordsOrigin,
        waypoints: waypoints,
        travelMode: mode,
      ),
      LocationSearch search => map.directionsSearchUrl(
        search.query,
        origin: coordsOrigin,
        travelMode: mode,
      ),
    };

    return _appendSearchOrigin(url, map);
  }

  /// Returns the native scheme URL for [map], or `null` if none.
  ///
  /// Pass [platform] to override platform detection (useful for previewing
  /// URLs for other platforms). Returns `null` on web/desktop if no
  /// [platform] is specified.
  String? getSchemeUrl({required MapApp map, MapPlatform? platform}) {
    if (!_supportsRequest(map)) return null;
    final resolved = platform ?? MapLauncherPlatform.instance.platform;
    if (resolved == null) return null;

    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    final url = switch (destination) {
      LocationCoords coords => map.directionsSchemeUrl(
        destination: coords,
        origin: coordsOrigin,
        waypoints: waypoints,
        travelMode: mode,
        platform: resolved,
      ),
      LocationSearch search => map.directionsSchemeSearchUrl(
        search.query,
        origin: coordsOrigin,
        travelMode: mode,
        platform: resolved,
      ),
    };
    return _appendSearchOrigin(url, map);
  }

  /// Returns maps from [maps] that support this directions request on this device.
  ///
  /// Accounts for:
  /// - Destination type (coordinates vs search)
  /// - Travel mode support
  /// - Waypoint support (if waypoints are specified)
  /// - Installation status and universal link availability
  /// - Provider configuration and transport limits, including [providerExtras]
  ///
  /// Results capture prepared URLs. Configuration does not certify credentials
  /// or future OS acceptance. Raw [extra] must be replaced with [providerExtras].
  Future<List<SupportedMap>> getSupportedMaps(List<MapApp> maps) async {
    requireScopedExtras(extra);
    final installedIds = await MapLauncherPlatform.instance.getInstalledMaps(
      maps,
    );
    final results = <SupportedMap>[];

    for (final map in maps) {
      final PreparedMapLaunch prepared;
      try {
        prepared = _prepare(map);
      } on MapConfigurationError {
        continue;
      }

      final isInstalled = installedIds.contains(map.id);

      // Universal support can differ by operation, even for the same map.
      if (isInstalled ||
          (map.hasUniversalLink && prepared.hasUniversalAttempt)) {
        results.add(
          SupportedMap.launchable(
            map: map,
            isInstalled: isInstalled,
            launcher: prepared.show,
          ),
        );
      }
    }

    return results;
  }

  bool _supportsRequest(MapApp map) {
    final supportsDestination = switch (destination) {
      LocationCoords() => map.supportsDirectionsCoords,
      LocationSearch() => map.supportsDirectionsSearch,
    };
    if (!supportsDestination) return false;
    if (mode != null && !map.supportsTravelMode(mode!)) return false;
    if (from is LocationCoords && !map.supportsDirectionsOrigin) return false;
    if (from is LocationSearch && !map.supportsDirectionsSearch) return false;
    // Search builders do not accept waypoints. Never silently drop stops.
    if (waypoints != null && waypoints!.isNotEmpty) {
      if (destination is LocationSearch || !map.supportsWaypoints) return false;
    }
    return true;
  }

  /// Appends the search-based origin to [url] if the map supports it.
  ///
  /// Only maps that support search-based directions (e.g. Google, Apple) are
  /// likely to understand an `origin=<query>` or `saddr=<query>` param.
  /// Requests with search origins are rejected for maps without search support.
  String? _appendSearchOrigin(String? url, MapApp map) {
    if (url == null || from is! LocationSearch) return url;
    if (!map.supportsDirectionsSearch) return url;
    final originKey = map.directionsSearchOriginKey(url);
    return appendQueryParams(url, {originKey: (from as LocationSearch).query});
  }
}
