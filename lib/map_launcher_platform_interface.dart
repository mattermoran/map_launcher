import 'package:map_launcher/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'map_launcher_method_channel.dart';

/// The platform interface for the [MapLauncher] plugin.
///
/// This class defines the contract for platform-specific implementations.
/// It should be extended by any platform package (e.g. Android, iOS) that
/// provides actual map launching functionality. Application code should
/// not use this class directly, but instead use the public [MapLauncher]
/// API.
abstract class MapLauncherPlatform extends PlatformInterface {
  /// Constructs a [MapLauncherPlatform].
  ///
  /// Only subclasses that pass the private [_token] to [PlatformInterface]
  /// are considered valid implementations.
  MapLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static MapLauncherPlatform _instance = MethodChannelMapLauncher();

  /// The default instance of [MapLauncherPlatform], which uses
  /// [MethodChannelMapLauncher].
  static MapLauncherPlatform get instance => _instance;

  static set instance(MapLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns a list of [AvailableMap] objects representing the map apps
  /// currently installed on the device.
  Future<List<AvailableMap>> get installedMaps async {
    throw UnimplementedError('installedMaps has not been implemented.');
  }

  /// Opens the map application specified by [mapType] and displays a marker at [coords].
  ///
  /// - [mapType]: The map application to launch.
  /// - [coords]: Coordinates where the marker should be placed.
  /// - [title]: Title for the marker.
  /// - [description]: Optional description for the marker.
  /// - [zoom]: Optional zoom level (default is 16).
  /// - [extraParams]: Extra map-specific query parameters.
  Future<dynamic> showMarker({
    required MapType mapType,
    required Coords coords,
    required String title,
    String? description,
    int zoom = 16,
    Map<String, String>? extraParams,
  }) async {
    throw UnimplementedError('showMarker() has not been implemented.');
  }

  /// Opens the map application specified by [mapType] and shows directions to [destination].
  ///
  /// - [mapType]: The map application to launch.
  /// - [destination]: Coordinates of the destination.
  /// - [destinationTitle]: Optional label for the destination.
  /// - [origin]: Optional starting point. If omitted, the map app may use the current location.
  /// - [originTitle]: Optional label for the origin.
  /// - [waypoints]: Optional list of intermediate waypoints along the route.
  /// - [directionsMode]: Mode of transport (default is [DirectionsMode.driving]).
  /// - [extraParams]: Extra map-specific query parameters.
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

  /// Returns `true` if the map app of type [mapType] is installed on the device,
  /// `false` otherwise.
  Future<bool> isMapAvailable(MapType mapType) async {
    throw UnimplementedError('isMapAvailable() has not been implemented.');
  }
}
