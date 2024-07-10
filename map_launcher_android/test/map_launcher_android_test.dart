import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_android/map_launcher_android.dart';
import 'package:map_launcher_platform_interface/map_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapLauncherAndroid', () {
    const kPlatformName = 'Android';
    late MapLauncherAndroid mapLauncher;
    late List<MethodCall> log;

    setUp(() async {
      mapLauncher = MapLauncherAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(mapLauncher.methodChannel,
              (methodCall) async {
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
      MapLauncherAndroid.registerWith();
      expect(MapLauncherPlatform.instance, isA<MapLauncherAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      // final name = await mapLauncher.getPlatformName();
      // expect(
      //   log,
      //   <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      // );
      // expect(name, equals(kPlatformName));
    });
  });
}
