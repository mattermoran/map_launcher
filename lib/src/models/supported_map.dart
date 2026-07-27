import 'dart:typed_data';

import 'package:map_launcher/src/maps/map_app.dart';

/// Runtime information about a map app's availability on the current device.
///
/// Returned by [MarkerRequest.getSupportedMaps] and
/// [DirectionsRequest.getSupportedMaps]. Combines static metadata
/// from [MapApp] with runtime installation status.
///
/// Entries created by a request are directly launchable:
/// ```dart
/// final maps = await request.getSupportedMaps([.apple, .google, .waze]);
/// await maps.first.show();  // opens the original request with this map
/// ```
final class SupportedMap {
  /// Creates a [SupportedMap].
  ///
  /// * [map] The [MapApp] this entry describes.
  /// * [isInstalled] Whether the native app is installed on the current device.
  const SupportedMap({required this.map, required this.isInstalled})
    : _launcher = null;

  /// Creates a [SupportedMap] that is directly launchable via [show].
  ///
  /// Used internally by request classes to attach a back-reference.
  SupportedMap.launchable({
    required this.map,
    required this.isInstalled,
    required Future<void> Function({Map<String, String>? extra}) launcher,
  }) : _launcher = launcher;

  /// The map application.
  final MapApp map;

  /// Whether the native app is installed on this device.
  ///
  /// Always `false` on desktop and web platforms.
  final bool isInstalled;

  /// Back-reference to the originating request's launch function.
  final Future<void> Function({Map<String, String>? extra})? _launcher;

  /// Launches the originating request with this map.
  ///
  /// Only works on entries returned by [MarkerRequest.getSupportedMaps] or
  /// [DirectionsRequest.getSupportedMaps]. Throws [StateError] on entries
  /// created via the public constructor (e.g. from [MapLauncher.getAvailableMaps]).
  ///
  /// * [extra] Additional query parameters merged with the request's extras.
  Future<void> show({Map<String, String>? extra}) {
    final launcher = _launcher;
    if (launcher == null) {
      throw StateError(
        'This SupportedMap was not created from a request. '
        'Use request.show(map: map) instead.',
      );
    }
    return launcher(extra: extra);
  }

  /// Human-readable display name.
  String get name => map.name;

  /// App icon as PNG bytes (256×256), for use with `Image.memory`.
  Uint8List get iconBytes => map.iconBytes;

  /// Whether this map has universal link support (works in browser).
  bool get hasUniversalLink => map.hasUniversalLink;

  /// Whether opening this map will launch the native app directly.
  bool get opensNatively => isInstalled;

  /// Whether opening this map will fall back to a browser.
  bool get opensInBrowser => !isInstalled && hasUniversalLink;

  /// App Store URL for installing this app (iOS), or `null`.
  String? get appStoreUrl => map.appStoreUrl;

  /// Play Store URL for installing this app (Android), or `null`.
  String? get playStoreUrl => map.playStoreUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedMap &&
          map.id == other.map.id &&
          isInstalled == other.isInstalled;

  @override
  int get hashCode => Object.hash(map.id, isInstalled);

  @override
  String toString() => 'SupportedMap(${map.name}, installed: $isInstalled)';
}
