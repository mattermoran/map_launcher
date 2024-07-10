import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

class MapLauncherMock extends MapLauncherPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MapLauncherPlatformInterface', () {
    late MapLauncherPlatform mapLauncherPlatform;

    setUp(() {
      mapLauncherPlatform = MapLauncherMock();
      MapLauncherPlatform.instance = mapLauncherPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        // expect(
        //   await MapLauncherPlatform.instance.getPlatformName(),
        //   equals(MapLauncherMock.mockPlatformName),
        // );
      });
    });
  });
}
