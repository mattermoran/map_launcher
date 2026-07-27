import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/map_platform.dart';
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
/// final maps = await marker.getSupportedMaps([.apple, .google, .waze]);
/// await maps.first.show();
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
  /// If [map] is null, uses the best available app from [defaultMaps]
  /// (Apple Maps on iOS, Google Maps elsewhere, with fallback).
  ///
  /// * [extra] Additional query parameters merged with constructor [extra];
  ///   values from this call take precedence on conflict.
  Future<void> show({MapApp? map, Map<String, String>? extra}) async {
    final targetMap =
        map ?? await resolveBestMap(() => getSupportedMaps(defaultMaps));
    if (targetMap == null) {
      throw UnsupportedError('No map app available for this marker request.');
    }

    final url = getUrl(map: targetMap);
    if (url == null) {
      throw UnsupportedError(
        '${targetMap.name} does not support this marker type.',
      );
    }

    // Merge constructor extra with show() extra; show() wins on conflict.
    final mergedExtra = {...?this.extra, ...?extra};
    final finalUrl = appendQueryParams(
      url,
      mergedExtra.isEmpty ? null : mergedExtra,
    );
    try {
      await MapLauncherPlatform.instance.launch(
        finalUrl,
        androidPackageName: targetMap.playStoreId,
      );
    } on Exception {
      // Scheme URL may fail if app is not installed. Fall back to universal.
      final universalUrl = getUniversalUrl(map: targetMap);
      if (universalUrl != null && universalUrl != finalUrl) {
        final fallbackUrl = appendQueryParams(
          universalUrl,
          mergedExtra.isEmpty ? null : mergedExtra,
        );
        try {
          await MapLauncherPlatform.instance.launch(
            fallbackUrl,
            androidPackageName: targetMap.playStoreId,
          );
          return;
        } on Exception catch (e) {
          throw MapLaunchException(
            'Failed to launch ${targetMap.name}',
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
  String? getUrl({required MapApp map}) {
    return map.bestMarkerUrl(
      location,
      zoom: zoom,
      platform: MapLauncherPlatform.instance.platform,
    );
  }

  /// Returns the universal (HTTPS) URL for [map], or `null` if unsupported.
  ///
  /// Unlike [getUrl], this always returns the web-openable URL, never
  /// a custom scheme.
  String? getUniversalUrl({required MapApp map}) {
    return switch (location) {
      LocationCoords coords => map.markerUrl(coords, zoom: zoom),
      LocationSearch search => map.markerSearchUrl(search.query),
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
  String? getSchemeUrl({required MapApp map, MapPlatform? platform}) {
    final resolved = platform ?? MapLauncherPlatform.instance.platform;
    if (resolved == null) return null;

    return switch (location) {
      LocationCoords coords => map.markerSchemeUrl(
        coords,
        zoom: zoom,
        platform: resolved,
      ),
      LocationSearch search => map.markerSchemeSearchUrl(
        search.query,
        platform: resolved,
      ),
    };
  }

  /// Returns maps from [maps] that support this marker request on this device.
  ///
  /// Accounts for:
  /// - Location type (coordinates vs search; fewer apps support search)
  /// - Installation status (native app detected)
  /// - Universal link availability (works via browser)
  Future<List<SupportedMap>> getSupportedMaps(List<MapApp> maps) async {
    final installedIds = await MapLauncherPlatform.instance.getInstalledMaps(
      maps,
    );
    final results = <SupportedMap>[];

    for (final map in maps) {
      // Check if this map supports the location type
      final isSupported = switch (location) {
        LocationCoords() => map.supportsMarkerCoords,
        LocationSearch() => map.supportsMarkerSearch,
      };
      if (!isSupported) continue;

      final isInstalled = installedIds.contains(map.id);

      // Include if installed natively OR has universal link (browser fallback)
      if (isInstalled || map.hasUniversalLink) {
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
}
