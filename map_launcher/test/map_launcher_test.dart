import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMapLauncherPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements MapLauncherPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapLauncher', () {
    late MapLauncherPlatform mapLauncherPlatform;

    setUp(() {
      mapLauncherPlatform = MockMapLauncherPlatform();
      MapLauncherPlatform.instance = mapLauncherPlatform;
    });

    group('getPlatformName', () {
      // test('returns correct name when platform implementation exists',
      //     () async {
      //   const platformName = '__test_platform__';
      //   when(
      //     () => mapLauncherPlatform.getPlatformName(),
      //   ).thenAnswer((_) async => platformName);

      //   final actualPlatformName = await getPlatformName();
      //   expect(actualPlatformName, equals(platformName));
      // });

      // test('throws exception when platform implementation is missing',
      //     () async {
      //   when(
      //     () => mapLauncherPlatform.getPlatformName(),
      //   ).thenAnswer((_) async => null);

      //   expect(getPlatformName, throwsException);
      // });
    });
  });
}
