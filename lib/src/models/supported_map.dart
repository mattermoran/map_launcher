import 'package:map_launcher/src/models/map_type.dart';

/// Runtime information about a map app's availability on the current device.
///
/// Returned by [MarkerRequest.getSupportedMaps] and
/// [DirectionsRequest.getSupportedMaps]. Combines static metadata
/// from [MapType] with runtime installation status.
final class SupportedMap {
  /// Creates a [SupportedMap].
  ///
  /// * [mapType] The [MapType] this entry describes.
  /// * [isInstalled] Whether the native app is installed on the current device.
  const SupportedMap({required this.mapType, required this.isInstalled});

  /// The map type.
  final MapType mapType;

  /// Whether the native app is installed on this device.
  ///
  /// Always `false` on desktop and web platforms.
  final bool isInstalled;

  /// Human-readable display name.
  String get displayName => mapType.displayName;

  /// SVG icon asset path.
  String get icon => mapType.icon;

  /// Whether this map has universal link support (works in browser).
  bool get hasUniversalLink => mapType.hasUniversalLink;

  /// Whether opening this map will launch the native app directly.
  bool get opensNatively => isInstalled;

  /// Whether opening this map will fall back to a browser.
  bool get opensInBrowser => !isInstalled && hasUniversalLink;

  /// App Store URL for installing this app (iOS), or `null`.
  String? get appStoreUrl => mapType.appStoreUrl;

  /// Play Store URL for installing this app (Android), or `null`.
  String? get playStoreUrl => mapType.playStoreUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedMap &&
          mapType == other.mapType &&
          isInstalled == other.isInstalled;

  @override
  int get hashCode => Object.hash(mapType, isInstalled);

  @override
  String toString() =>
      'SupportedMap(${mapType.displayName}, installed: $isInstalled)';
}
