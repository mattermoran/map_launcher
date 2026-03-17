import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_registry.dart';
import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/map_type.dart';
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
  const DirectionsRequest({
    required this.destination,
    this.from,
    this.mode,
    this.waypoints,
    this.extra,
  });

  /// The destination (coordinates or search query).
  final Location destination;

  /// Optional origin. Accepts coordinates or search text.
  /// If null, the map app may use the device's current location.
  final Location? from;

  /// Travel mode (driving, walking, transit, bicycling).
  final TravelMode? mode;

  /// Intermediate waypoints (coordinates only).
  final List<LocationCoords>? waypoints;

  /// Extra query parameters appended to the URL.
  final Map<String, String>? extra;

  /// Shows directions in a map app.
  ///
  /// If [map] is null, uses the best available app
  /// (Apple Maps on iOS, Google Maps elsewhere, with fallback).
  ///
  /// * [extra] Additional query parameters merged with constructor [extra];
  ///   values from this call take precedence on conflict.
  Future<void> show({MapType? map, Map<String, String>? extra}) async {
    final targetMap = map ?? await resolveBestMap(getSupportedMaps);
    if (targetMap == null) {
      throw UnsupportedError(
        'No map app available for this directions request.',
      );
    }

    final url = getUrl(map: targetMap);
    if (url == null) {
      throw UnsupportedError(
        '${targetMap.displayName} does not support this directions type.',
      );
    }

    // Merge constructor extra with show() extra; show() wins on conflict.
    final mergedExtra = {...?this.extra, ...?extra};
    final finalUrl = appendQueryParams(
      url,
      mergedExtra.isEmpty ? null : mergedExtra,
    );
    try {
      await MapLauncherPlatform.instance.launch(finalUrl, mapType: targetMap);
    } on Exception {
      // Scheme URL may fail if app is not installed — fall back to universal.
      final universalUrl = getUniversalUrl(map: targetMap);
      if (universalUrl != null && universalUrl != finalUrl) {
        final fallbackUrl = appendQueryParams(
          universalUrl,
          mergedExtra.isEmpty ? null : mergedExtra,
        );
        try {
          await MapLauncherPlatform.instance.launch(fallbackUrl, mapType: targetMap);
          return;
        } on Exception catch (e) {
          throw MapLaunchException(
            'Failed to launch ${targetMap.displayName}',
            url: fallbackUrl,
            cause: e,
          );
        }
      }
      rethrow;
    }
  }

  /// Returns the URL that would be opened for [map], without opening.
  ///
  /// On mobile, prefers the native scheme URL. On web/desktop, always
  /// returns the universal HTTPS URL. Returns `null` if unsupported.
  String? getUrl({required MapType map}) {
    final builder = MapRegistry.getBuilder(map);
    if (builder == null) return null;

    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    String? url = builder.bestDirectionsUrl(
      destination: destination,
      origin: coordsOrigin,
      waypoints: waypoints,
      travelMode: mode,
      platform: MapLauncherPlatform.instance.platform,
    );

    return _appendSearchOrigin(url, builder);
  }

  /// Returns the universal (HTTPS) URL for [map], or `null` if unsupported.
  String? getUniversalUrl({required MapType map}) {
    final builder = MapRegistry.getBuilder(map);
    if (builder == null) return null;

    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    String? url = switch (destination) {
      LocationCoords coords => builder.directionsUrl(
        destination: coords,
        origin: coordsOrigin,
        waypoints: waypoints,
        travelMode: mode,
      ),
      LocationSearch search => builder.directionsSearchUrl(
        search.query,
        origin: coordsOrigin,
        travelMode: mode,
      ),
    };

    return _appendSearchOrigin(url, builder);
  }

  /// Returns the native scheme URL for [map], or `null` if none.
  ///
  /// Pass [platform] to override platform detection (useful for previewing
  /// URLs for other platforms). Returns `null` on web/desktop if no
  /// [platform] is specified.
  String? getSchemeUrl({required MapType map, MapPlatform? platform}) {
    final resolved = platform ?? MapLauncherPlatform.instance.platform;
    if (resolved == null) return null;

    final builder = MapRegistry.getBuilder(map);
    if (builder == null) return null;

    final coordsOrigin = from is LocationCoords ? from as LocationCoords : null;

    return switch (destination) {
      LocationCoords coords => builder.directionsSchemeUrl(
        destination: coords,
        origin: coordsOrigin,
        waypoints: waypoints,
        travelMode: mode,
        platform: resolved,
      ),
      LocationSearch search => builder.directionsSchemeSearchUrl(
        search.query,
        origin: coordsOrigin,
        travelMode: mode,
        platform: resolved,
      ),
    };
  }

  /// Returns maps that support this directions request on this device.
  ///
  /// Accounts for:
  /// - Destination type (coordinates vs search)
  /// - Travel mode support
  /// - Waypoint support (if waypoints are specified)
  /// - Installation status and universal link availability
  Future<List<SupportedMap>> getSupportedMaps() async {
    final installedMaps = await MapLauncherPlatform.instance.getInstalledMaps();
    final results = <SupportedMap>[];

    for (final mapType in MapRegistry.supportedMaps) {
      final builder = MapRegistry.getBuilder(mapType)!;

      // Check destination type support
      final isSupported = switch (destination) {
        LocationCoords() => builder.supportsDirectionsCoords,
        LocationSearch() => builder.supportsDirectionsSearch,
      };
      if (!isSupported) continue;

      // Check waypoint support if waypoints are specified
      if (waypoints != null &&
          waypoints!.isNotEmpty &&
          !builder.supportsWaypoints) {
        continue;
      }

      final isInstalled = installedMaps.contains(mapType);

      // Include if installed natively OR has universal link
      if (isInstalled || mapType.hasUniversalLink) {
        results.add(SupportedMap(mapType: mapType, isInstalled: isInstalled));
      }
    }

    return results;
  }

  /// Appends the search-based origin to [url] if the map supports it.
  ///
  /// Only maps that support search-based directions (e.g. Google, Apple) are
  /// likely to understand an `origin=<query>` or `saddr=<query>` param.
  /// For other maps, appending it would produce a garbage URL, so we skip it
  /// — losing the origin is better than a broken link.
  String? _appendSearchOrigin(String? url, MapUrlBuilder builder) {
    if (url == null || from is! LocationSearch) return url;
    if (!builder.supportsDirectionsSearch) return url;
    final originKey = builder.mapType == .apple ? 'saddr' : 'origin';
    return appendQueryParams(url, {originKey: (from as LocationSearch).query});
  }
}
