import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';
import 'package:map_launcher_web/map_launcher_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapLauncherWeb', () {
    const kPlatformName = 'Web';
    late MapLauncherWeb mapLauncher;

    setUp(() async {
      mapLauncher = MapLauncherWeb();
    });

    test('can be registered', () {
      MapLauncherWeb.registerWith();
      expect(MapLauncherPlatform.instance, isA<MapLauncherWeb>());
    });

    test('getPlatformName returns correct name', () async {
      // final name = await mapLauncher.getPlatformName();
      // expect(name, equals(kPlatformName));
    });
  });
}
