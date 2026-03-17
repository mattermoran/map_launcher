import 'dart:io';

import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/map_type.dart';

/// Desktop (macOS, Windows, Linux) implementation.
///
/// Uses system commands to open URLs in the default browser.
/// Registered via `dartPluginClass` in pubspec.yaml.
class MapLauncherDesktop extends MapLauncherPlatform {
  /// Registers this class as the platform implementation.
  static void registerWith() {
    MapLauncherPlatform.instance = MapLauncherDesktop();
  }

  @override
  Future<void> launch(String url, {MapType? mapType}) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      throw ArgumentError.value(url, 'url', 'Invalid URL: must have a scheme');
    }
    final ProcessResult result;
    if (Platform.isMacOS) {
      result = await Process.run('open', [url]);
    } else if (Platform.isWindows) {
      result = await Process.run('cmd', ['/c', 'start', '', url]);
    } else if (Platform.isLinux) {
      result = await Process.run('xdg-open', [url]);
    } else {
      throw UnsupportedError(
        'MapLauncherDesktop does not support ${Platform.operatingSystem}',
      );
    }
    if (result.exitCode != 0) {
      throw Exception('Failed to launch URL: ${result.stderr}');
    }
  }

  @override
  Future<List<MapType>> getInstalledMaps() async {
    // Desktop doesn't have "installed" map apps — universal links only
    return [];
  }

  // platform defaults to null (desktop) from base class — no override needed
}
