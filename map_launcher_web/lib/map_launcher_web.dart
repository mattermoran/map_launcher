import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

/// The Web implementation of [MapLauncherPlatform].
class MapLauncherWeb extends MethodChannelMapLauncher {
  /// Registers this class as the default instance of [MapLauncherPlatform]
  static void registerWith([Object? registrar]) {
    MapLauncherPlatform.instance = MapLauncherWeb();
  }
}
