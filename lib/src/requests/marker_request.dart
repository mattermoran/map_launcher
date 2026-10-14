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
  /// * [extra] Raw query options for explicit `show(map: ...)` only.
  /// * [providerExtras] Conditional options bound to each provider ID.
  ///   Both are copied into unmodifiable snapshots.
  MarkerRequest({
    required this.location,
    this.zoom,
    Map<String, String>? extra,
    Map<MapApp, Map<String, String>> providerExtras = const {},
  }) : extra = extra == null ? null : Map.unmodifiable(extra),
       providerExtras = snapshotProviderExtras(providerExtras);

  /// The location to show (coordinates or search query).
  final Location location;

  /// Optional zoom level for the map.
  final int? zoom;

  /// Raw query parameters for explicit launches; not usable during discovery.
  final Map<String, String>? extra;

  /// Options applied only when their provider ID is selected.
  /// These are optional provider-specific preferences, not portable requirements.
  final Map<MapApp, Map<String, String>> providerExtras;

  /// Shows the marker in a map app.
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
    if (!_supportsRequest(map)) return null;
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
    if (!_supportsRequest(map)) return null;
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

  bool _supportsRequest(MapApp map) => switch (location) {
    LocationCoords() => map.supportsMarkerCoords,
    LocationSearch() => map.supportsMarkerSearch,
  };
}
