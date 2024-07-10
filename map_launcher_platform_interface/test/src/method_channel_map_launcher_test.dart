import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher_platform_interface/src/method_channel_map_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelMapLauncher', () {
    late MethodChannelMapLauncher methodChannelMapLauncher;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelMapLauncher = MethodChannelMapLauncher();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelMapLauncher.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      // final platformName = await methodChannelMapLauncher.getPlatformName();
      // expect(
      //   log,
      //   <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      // );
      // expect(platformName, equals(kPlatformName));
    });
  });
}
