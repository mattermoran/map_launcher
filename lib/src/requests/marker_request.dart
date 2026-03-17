import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_registry.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/supported_map.dart';
import 'package:map_launcher/src/utils/launch_helper.dart';

/// An immutable request to show a marker on a map.
///
/// Created via [MapLauncher.marker]. Call [show] to open,
/// [getSupportedMaps] to discover available maps, or [getUrl]
/// to get the raw URL.
///
/// ```dart
/// // One-liner
/// await MapLauncher.marker(.coords(48.85, 2.29, title: 'Eiffel Tower')).show();
///
/// // Specific app
/// await MapLauncher.marker(.coords(48.85, 2.29)).show(map: .google);
///
/// // With discovery
/// final marker = MapLauncher.marker(.coords(48.85, 2.29));
/// final maps = await marker.getSupportedMaps();
/// await marker.show(map: maps.first.mapType);
/// ```
class MarkerRequest {
  /// Creates a [MarkerRequest]. Prefer [MapLauncher.marker].
  ///
  /// * [location] The location to show (coordinates or search query).
  /// * [zoom] Optional map zoom level. Not supported by all maps.
  /// * [extra] Additional query parameters appended to the generated URL.
  const MarkerRequest({required this.location, this.zoom, this.extra});

  /// The location to show (coordinates or search query).
  final Location location;

  /// Optional zoom level for the map.
  final int? zoom;

  /// Extra query parameters appended to the URL.
  final Map<String, String>? extra;

  /// Shows the marker in a map app.
  ///
  /// If [map] is null, uses the best available app
  /// (Apple Maps on iOS, Google Maps elsewhere, with fallback).
  ///
  /// * [extra] Additional query parameters merged with constructor [extra];
  ///   values from this call take precedence on conflict.
  Future<void> show({MapType? map, Map<String, String>? extra}) async {
    final targetMap = map ?? await resolveBestMap(getSupportedMaps);
    if (targetMap == null) {
      throw UnsupportedError('No map app available for this marker request.');
    }

    final url = getUrl(map: targetMap);
    if (url == null) {
      throw UnsupportedError(
        '${targetMap.displayName} does not support this marker type.',
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

    return builder.bestMarkerUrl(
      location,
      zoom: zoom,
      platform: MapLauncherPlatform.instance.platform,
    );
  }

  /// Returns the universal (HTTPS) URL for [map], or `null` if unsupported.
  ///
  /// Unlike [getUrl], this always returns the web-openable URL, never
  /// a custom scheme.
  String? getUniversalUrl({required MapType map}) {
    final builder = MapRegistry.getBuilder(map);
    if (builder == null) return null;

    return switch (location) {
      LocationCoords coords => builder.markerUrl(coords, zoom: zoom),
      LocationSearch search => builder.markerSearchUrl(search.query),
    };
  }

  /// Returns the native scheme URL for [map], or `null` if none.
  ///
  /// Returns URLs like `comgooglemaps://`, `dgis://`, etc.
  /// These only work when the app is installed.
  ///
  /// Pass [platform] to override platform detection (useful for previewing
  /// URLs for other platforms). Returns `null` on web/desktop if no
  /// [platform] is specified.
  String? getSchemeUrl({required MapType map, MapPlatform? platform}) {
    final resolved = platform ?? MapLauncherPlatform.instance.platform;
    if (resolved == null) return null;

    final builder = MapRegistry.getBuilder(map);
    if (builder == null) return null;

    return switch (location) {
      LocationCoords coords => builder.markerSchemeUrl(
        coords,
        zoom: zoom,
        platform: resolved,
      ),
      LocationSearch search => builder.markerSchemeSearchUrl(
        search.query,
        platform: resolved,
      ),
    };
  }

  /// Returns maps that support this marker request on this device.
  ///
  /// Accounts for:
  /// - Location type (coordinates vs search — fewer apps support search)
  /// - Installation status (native app detected)
  /// - Universal link availability (works via browser)
  Future<List<SupportedMap>> getSupportedMaps() async {
    final installedMaps = await MapLauncherPlatform.instance.getInstalledMaps();
    final results = <SupportedMap>[];

    for (final mapType in MapRegistry.supportedMaps) {
      final builder = MapRegistry.getBuilder(mapType)!;

      // Check if this builder supports the location type
      final isSupported = switch (location) {
        LocationCoords() => builder.supportsMarkerCoords,
        LocationSearch() => builder.supportsMarkerSearch,
      };
      if (!isSupported) continue;

      final isInstalled = installedMaps.contains(mapType);

      // Include if installed natively OR has universal link (browser fallback)
      if (isInstalled || mapType.hasUniversalLink) {
        results.add(SupportedMap(mapType: mapType, isInstalled: isInstalled));
      }
    }

    return results;
  }
}
