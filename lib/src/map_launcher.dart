import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/supported_map.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/requests/directions_request.dart';
import 'package:map_launcher/src/requests/marker_request.dart';

/// Entry point for launching map applications across all Flutter platforms.
///
/// Provides a builder-style API: create a request with [marker] or
/// [directions], then call [MarkerRequest.show] to open or
/// [MarkerRequest.getSupportedMaps] to discover available maps.
///
/// ```dart
/// import 'package:map_launcher/map_launcher.dart';
///
/// // Show a marker (uses Apple Maps on iOS, Google Maps elsewhere)
/// await MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan')).show();
///
/// // Show directions
/// await MapLauncher.directions(
///   .coords(59.33, 18.07, title: 'Gamla Stan'),
///   from: .coords(59.33, 18.10),
///   mode: TravelMode.walking,
/// ).show();
///
/// // Specific app with extras
/// await MapLauncher.marker(.coords(59.33, 18.07)).show(
///   map: .google,
///   extra: GoogleExtra(queryPlaceId: 'ChIJLU7j...'),
/// );
///
/// // Discover available maps
/// final maps = await MapLauncher.marker(.coords(59.33, 18.07))
///     .getSupportedMaps([.apple, .google, .waze]);
/// ```
abstract final class MapLauncher {
  /// Creates a marker request for [location].
  ///
  /// Use with Dart 3.10+ shorthand:
  /// ```dart
  /// MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan'))
  /// MapLauncher.marker(.search('Fika near Södermalm'))
  /// ```
  ///
  /// * [zoom] Optional map zoom level (integer). Not supported by all maps.
  /// * [extra] Raw query options for explicit `show(map: ...)` only.
  /// * [providerExtras] Provider-specific conditional options, including for
  ///   automatic selection and discovery. Copied into immutable snapshots.
  static MarkerRequest marker(
    Location location, {
    int? zoom,
    Map<String, String>? extra,
    Map<MapApp, Map<String, String>> providerExtras = const {},
  }) {
    return MarkerRequest(
      location: location,
      zoom: zoom,
      extra: extra,
      providerExtras: providerExtras,
    );
  }

  /// Creates a directions request to [destination].
  ///
  /// [from] accepts both coordinates and search text:
  /// ```dart
  /// MapLauncher.directions(
  ///   .coords(59.33, 18.07),
  ///   from: .search('Stockholm Central'),
  ///   mode: .walking,
  /// )
  /// ```
  ///
  /// * [mode] Travel mode (driving, walking, transit, bicycling). Defaults to
  ///   the map app's default when null.
  /// * [waypoints] Intermediate stops (coordinates only). Requires a coordinate
  ///   destination and a map with waypoint support.
  /// * [extra] Raw query options for explicit `show(map: ...)` only.
  /// * [providerExtras] Provider-specific conditional options, including for
  ///   automatic selection and discovery. Copied into immutable snapshots.
  static DirectionsRequest directions(
    Location destination, {
    Location? from,
    TravelMode? mode,
    List<LocationCoords>? waypoints,
    Map<String, String>? extra,
    Map<MapApp, Map<String, String>> providerExtras = const {},
  }) {
    return DirectionsRequest(
      destination: destination,
      from: from,
      mode: mode,
      waypoints: waypoints,
      extra: extra,
      providerExtras: providerExtras,
    );
  }

  /// Returns all maps from [maps] available on this platform.
  ///
  /// Returns maps that are either natively installed or have
  /// universal link support (can open in browser).
  ///
  /// For request-specific filtering, use [MarkerRequest.getSupportedMaps] or
  /// [DirectionsRequest.getSupportedMaps] instead.
  static Future<List<AvailableMap>> getAvailableMaps(List<MapApp> maps) async {
    final installedIds = await MapLauncherPlatform.instance.getInstalledMaps(
      maps,
    );
    final results = <AvailableMap>[];

    for (final map in maps) {
      final isInstalled = installedIds.contains(map.id);
      if (isInstalled || map.hasUniversalLink) {
        results.add(AvailableMap(map: map, isInstalled: isInstalled));
      }
    }

    return results;
  }
}
