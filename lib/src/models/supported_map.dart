import 'dart:typed_data';

import 'package:map_launcher/src/maps/map_app.dart';

/// Runtime information about a map app's availability on the current device.
///
/// Returned by MapLauncher.getAvailableMaps. This is metadata only;
/// use request discovery to obtain a launchable [SupportedMap].
class AvailableMap {
  /// Creates availability metadata, without a launchable request.
  ///
  /// * [map] The [MapApp] this entry describes.
  /// * [isInstalled] Whether the native app is installed on the current device.
  const AvailableMap({required this.map, required this.isInstalled});

  /// The map application.
  final MapApp map;

  /// Whether the native app is installed on this device.
  ///
  /// Always `false` on desktop and web platforms.
  final bool isInstalled;

  /// Human-readable display name.
  String get name => map.name;

  /// App icon as PNG bytes (256×256), for use with `Image.memory`.
  Uint8List get iconBytes => map.iconBytes;

  /// Whether this map has universal link support (works in browser).
  bool get hasUniversalLink => map.hasUniversalLink;

  /// Detection hint only: the OS may still choose a browser or reject launch.
  @Deprecated('Use isInstalled; detection does not guarantee native opening.')
  bool get opensNatively => isInstalled;

  /// Availability hint only, not a prediction of the eventual OS handler.
  @Deprecated('Use hasUniversalLink; the OS chooses how HTTPS links open.')
  bool get opensInBrowser => !isInstalled && hasUniversalLink;

  /// App Store URL for installing this app (iOS), or `null`.
  String? get appStoreUrl => map.appStoreUrl;

  /// Play Store URL for installing this app (Android), or `null`.
  String? get playStoreUrl => map.playStoreUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableMap &&
          other.runtimeType == runtimeType &&
          map.id == other.map.id &&
          isInstalled == other.isInstalled;

  @override
  int get hashCode => Object.hash(map.id, isInstalled);

  @override
  String toString() => 'AvailableMap(${map.name}, installed: $isInstalled)';
}

/// A prepared request bound to one provider. Launch may still fail at runtime.
final class SupportedMap extends AvailableMap {
  /// Binds availability metadata to an already prepared request.
  SupportedMap.launchable({
    required super.map,
    required super.isInstalled,
    required Future<void> Function() launcher,
  }) : _launcher = launcher;

  final Future<void> Function() _launcher;

  /// Opens the captured request. Never switches to another provider.
  /// Configure provider extras on the request before discovery.
  Future<void> show() => _launcher();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);

  @override
  String toString() => 'SupportedMap(${map.name}, installed: $isInstalled)';
}
