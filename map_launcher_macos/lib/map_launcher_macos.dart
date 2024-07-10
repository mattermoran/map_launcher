import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

/// The MacOS implementation of [MapLauncherPlatform].
class MapLauncherMacOS extends MethodChannelMapLauncher {
  /// The method channel used to interact with the native platform.
  @override
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher_macos');

  /// Registers this class as the default instance of [MapLauncherPlatform]
  static void registerWith() {
    MapLauncherPlatform.instance = MapLauncherMacOS();
  }
}
