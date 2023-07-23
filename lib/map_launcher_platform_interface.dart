import 'package:map_launcher/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'map_launcher_method_channel.dart';

abstract class MapLauncherPlatform extends PlatformInterface {
  /// Constructs a MapLauncherPlatform.
  MapLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static MapLauncherPlatform _instance = MethodChannelMapLauncher();

  /// The default instance of [MapLauncherPlatform] to use.
  ///
  /// Defaults to [MethodChannelMapLauncher].
  static MapLauncherPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MapLauncherPlatform] when
  /// they register themselves.
  static set instance(MapLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<AvailableMap>> getInstalledMaps() {
    throw UnimplementedError('getInstalledMaps() has not been implemented.');
  }

  Future<void> showMarker(MapMarkerParams params) {
    throw UnimplementedError('showMarker() has not been implemented.');
  }

  Future<void> showDirections(MapDirectionsParams params) {
    throw UnimplementedError('showDirections() has not been implemented.');
  }

  Future<bool> isMapAvailable(MapType mapType) {
    throw UnimplementedError('isMapAvailable() has not been implemented.');
  }
}
