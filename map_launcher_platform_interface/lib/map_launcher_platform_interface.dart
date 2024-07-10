import 'package:map_launcher_platform_interface/src/method_channel_map_launcher.dart';
import 'package:map_launcher_platform_interface/src/models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'src/method_channel_map_launcher.dart';
export 'src/models.dart';

/// The interface that implementations of map_launcher must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `MapLauncher`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [MapLauncherPlatform] methods.
abstract class MapLauncherPlatform extends PlatformInterface {
  /// Constructs a MapLauncherPlatform.
  MapLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static MapLauncherPlatform _instance = MethodChannelMapLauncher();

  /// The default instance of [MapLauncherPlatform] to use.
  ///
  /// Defaults to [MethodChannelMapLauncher].
  static MapLauncherPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MapLauncherPlatform] when they register themselves.
  static set instance(MapLauncherPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Gets a list of available maps on the device.
  Future<List<AvailableMap>> getAvailableMaps();

  /// Shows the map with the given location.
  Future<void> showMarker({
    required Location location,
    MapType? mapType,
    int? zoom,
    Map<String, String>? extraParams,
  });

  /// Shows the directions from the origin to the destination.
  Future<void> showDirections({
    required Location destination,
    MapType? mapType,
    Location? origin,
    List<Location>? waypoints,
    DirectionsMode directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  });
}
