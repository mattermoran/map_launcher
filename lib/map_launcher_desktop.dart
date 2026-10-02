import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/maps/map_app.dart';

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
  Future<void> launch(String url, {String? androidPackageName}) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty ||
        url.contains('\u0000')) {
      throw ArgumentError.value(
        url,
        'url',
        'Desktop maps require an HTTP(S) URL',
      );
    }
    final ProcessResult result;
    if (Platform.isMacOS) {
      result = await Process.run('open', [url]);
    } else if (Platform.isWindows) {
      result = await Process.run('powershell.exe', windowsLaunchArguments(url));
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

  /// Builds a PowerShell invocation with the URL encoded as data, never code.
  ///
  /// `cmd /c start` is unsafe here: even ordinary query separators (`&`) are
  /// shell syntax, and percent-encoded URLs can trigger variable expansion.
  @visibleForTesting
  static List<String> windowsLaunchArguments(String url) {
    final data = base64Encode(utf8.encode(url));
    final script =
        "\$ErrorActionPreference = 'Stop'; "
        "Start-Process -FilePath ([Text.Encoding]::UTF8.GetString("
        "[Convert]::FromBase64String('$data')))";
    // powershell.exe requires UTF-16LE for -EncodedCommand.
    final encoded = base64Encode([
      for (final unit in script.codeUnits) ...[unit & 0xff, unit >> 8],
    ]);
    return ['-NoProfile', '-NonInteractive', '-EncodedCommand', encoded];
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    // Desktop doesn't have "installed" map apps. Universal links only.
    return {};
  }

  // platform defaults to null (desktop) from base class, no override needed
}
