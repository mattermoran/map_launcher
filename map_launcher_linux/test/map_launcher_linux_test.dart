import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_linux/map_launcher_linux.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapLauncherLinux', () {
    const kPlatformName = 'Linux';
    late MapLauncherLinux mapLauncher;
    late List<MethodCall> log;

    setUp(() async {
      mapLauncher = MapLauncherLinux();

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
      MapLauncherLinux.registerWith();
      expect(MapLauncherPlatform.instance, isA<MapLauncherLinux>());
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
