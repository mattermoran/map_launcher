import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';
import 'package:map_launcher_windows/map_launcher_windows.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapLauncherWindows', () {
    const kPlatformName = 'Windows';
    late MapLauncherWindows mapLauncher;
    late List<MethodCall> log;

    setUp(() async {
      mapLauncher = MapLauncherWindows();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mapLauncher.methodChannel, (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      MapLauncherWindows.registerWith();
      expect(MapLauncherPlatform.instance, isA<MapLauncherWindows>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await mapLauncher.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
