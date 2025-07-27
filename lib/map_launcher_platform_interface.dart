import 'package:map_launcher/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'map_launcher_method_channel.dart';

abstract class MapLauncherPlatform extends PlatformInterface {
  MapLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static MapLauncherPlatform _instance = MethodChannelMapLauncher();

  static MapLauncherPlatform get instance => _instance;

  static set instance(MapLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns list of installed map apps on the device.
  Future<List<AvailableMap>> get installedMaps async {
    throw UnimplementedError('installedMaps has not been implemented.');
  }

  /// Opens map app specified in [mapType]
  /// and shows marker at [coords]
  Future<dynamic> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int? zoom,
    Map<String, String>? extraParams,
  }) async {
    throw UnimplementedError('showMarker() has not been implemented.');
  }

  /// Opens map app specified in [mapType]
  /// and shows directions to [destination]
  Future<dynamic> showDirections({
    required MapType mapType,
    required Coords destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Waypoint>? waypoints,
    DirectionsMode? directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) async {
    throw UnimplementedError('showDirections() has not been implemented.');
  }

  /// Returns boolean indicating if map app is installed
  Future<bool?> isMapAvailable(MapType mapType) async {
    throw UnimplementedError('isMapAvailable() has not been implemented.');
  }
}
