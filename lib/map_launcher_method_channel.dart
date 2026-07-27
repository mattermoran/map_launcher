import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_platform.dart';

import 'map_launcher_platform_interface.dart';

/// Method channel implementation for Android and iOS.
///
/// Handles URL launching via native intents and app detection
/// via package manager / canOpenURL.
class MethodChannelMapLauncher extends MapLauncherPlatform {
  /// The method channel used for platform communication.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher');

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    await methodChannel.invokeMethod('launch', {
      'url': url,
      'packageName': ?androidPackageName,
    });
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    // Build probe payload: id → scheme (iOS) or id → package (Android).
    final probes = <String, String>{
      for (final m in maps)
        if (platform == MapPlatform.ios && m.iosScheme != null)
          m.id: m.iosScheme!
        else if (platform == MapPlatform.android && m.playStoreId != null)
          m.id: m.playStoreId!,
    };

    final result = await methodChannel.invokeMethod('getInstalledMaps', probes);
    final installed = <String>{};
    if (result is Map) {
      final installedIds = result['installed'];
      if (installedIds is List) {
        installed.addAll(installedIds.cast<String>());
      }
      final undeclaredIds = result['undeclared'];
      if (undeclaredIds is List) {
        _warnUndeclaredSchemes(undeclaredIds.cast<String>(), maps);
      }
    }

    // Add maps that need no probe (e.g. Apple Maps on iOS).
    if (platform != null) {
      for (final m in maps) {
        if (m.isAlwaysAvailable(platform!)) installed.add(m.id);
      }
    }

    return installed;
  }

  /// Map ids already warned about, to avoid repeating the message every time
  /// detection runs (e.g. on each picker open).
  @visibleForTesting
  static final warnedUndeclaredIds = <String>{};

  /// Warns (debug builds only) about maps whose iOS URL scheme is missing
  /// from the host app's `LSApplicationQueriesSchemes`. For those,
  /// `canOpenURL` always returns false, so the map silently never shows up
  /// as installed. This makes the misconfiguration visible.
  void _warnUndeclaredSchemes(List<String> ids, List<MapApp> maps) {
    if (!kDebugMode) return;
    // One message per call covering every newly-seen map, so passing a large
    // list (e.g. MapApp.all) doesn't print a wall of separate warnings.
    final newIds = <String>[];
    for (final id in ids) {
      if (warnedUndeclaredIds.add(id)) newIds.add(id);
    }
    if (newIds.isEmpty) return;
    final lines = newIds
        .map((id) {
          final map = maps.where((m) => m.id == id).firstOrNull;
          final scheme = map?.iosScheme?.split(':').first ?? id;
          return "  MapApp.$id → add '$scheme'";
        })
        .join('\n');
    debugPrint(
      'map_launcher: ${newIds.length} map(s) can never be detected on iOS. '
      'URL scheme missing from LSApplicationQueriesSchemes in your '
      'Info.plist:\n$lines\n'
      'See https://github.com/mattermoran/map_launcher#setup',
    );
  }

  @override
  MapPlatform? get platform => switch (defaultTargetPlatform) {
    TargetPlatform.iOS => .ios,
    TargetPlatform.android => .android,
    _ => null,
  };
}
