import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

/// The Linux implementation of [MapLauncherPlatform].
class MapLauncherLinux extends MapLauncherPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('map_launcher_linux');

  /// Registers this class as the default instance of [MapLauncherPlatform]
  static void registerWith() {
    MapLauncherPlatform.instance = MapLauncherLinux();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<List<AvailableMap>> getAvailableMaps() {
    // TODO: implement getAvailableMaps
    throw UnimplementedError();
  }

  @override
  Future<void> showDirections(
      {required Location destination,
      MapType? mapType,
      Location? origin,
      List<Location>? waypoints,
      DirectionsMode directionsMode = DirectionsMode.driving,
      Map<String, String>? extraParams}) {
    // TODO: implement showDirections
    throw UnimplementedError();
  }

  @override
  Future<void> showMarker(
      {required Location location,
      MapType? mapType,
      int? zoom,
      Map<String, String>? extraParams}) {
    // TODO: implement showMarker
    throw UnimplementedError();
  }
}
