import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/location.dart';
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
  /// * [extra] Additional query parameters appended to the generated URL.
  ///
  /// Collections are copied into unmodifiable snapshots.
  DirectionsRequest({
    required this.destination,
    this.from,
    this.mode,
    List<LocationCoords>? waypoints,
    Map<String, String>? extra,
  }) : waypoints = waypoints == null ? null : List.unmodifiable(waypoints),
       extra = extra == null ? null : Map.unmodifiable(extra);

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

  /// Extra query parameters appended to the URL.
  final Map<String, String>? extra;

  /// Shows directions in a map app.
  ///
  /// If [map] is null, uses the best available app from [defaultMaps]
  /// (Apple Maps on iOS, Google Maps elsewhere, with fallback).
  ///
  /// * [extra] Additional query parameters merged with constructor [extra];
  ///   values from this call take precedence on conflict.
  Future<void> show({MapApp? map, Map<String, String>? extra}) async {
    final mergedExtra = {...?this.extra, ...?extra};
    final targetMap =
        map ?? await resolveBestMap(() => getSupportedMaps(defaultMaps));
    if (targetMap == null) {
      throw UnsupportedError(
        'No map app available for this directions request.',
      );
    }

    final url = getUrl(map: targetMap);
    if (url == null) {
      throw UnsupportedError(
        '${targetMap.name} does not support this directions type.',
      );
    }

    await launchMapUrl(
      map: targetMap,
      url: url,
      universalUrl: getUniversalUrl(map: targetMap),
      extra: mergedExtra,
    );
  }

  /// Returns the URL that would be opened for [map], without opening.
  ///
  /// On mobile, prefers the native scheme URL. On web/desktop, always
  /// returns the universal HTTPS URL. Returns `null` if unsupported.
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
  Future<List<SupportedMap>> getSupportedMaps(List<MapApp> maps) async {
    final installedIds = await MapLauncherPlatform.instance.getInstalledMaps(
      maps,
    );
    final results = <SupportedMap>[];

    for (final map in maps) {
      if (getUrl(map: map) == null) continue;

      final isInstalled = installedIds.contains(map.id);

      // Universal support can differ by operation, even for the same map.
      if (isInstalled ||
          (map.hasUniversalLink && getUniversalUrl(map: map) != null)) {
        results.add(
          SupportedMap.launchable(
            map: map,
            isInstalled: isInstalled,
            launcher: ({Map<String, String>? extra}) =>
                show(map: map, extra: extra),
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
    final originKey = map.id == 'apple' || url.startsWith('comgooglemaps:')
        ? 'saddr'
        : 'origin';
    return appendQueryParams(url, {originKey: (from as LocationSearch).query});
  }
}
