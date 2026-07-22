import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_method_channel.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('map_launcher');
  final log = <MethodCall>[];

  final launcher = MethodChannelMapLauncher();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'launch':
              return null;
            case 'getInstalledMaps':
              return [
                {'mapType': 'google'},
                {'mapType': 'waze'},
              ];
            default:
              return null;
          }
        });
  });

  tearDown(() {
    log.clear();
  });

  group('MethodChannelMapLauncher', () {
    group('launch', () {
      test('sends correct method call with url argument', () async {
        await launcher.launch('https://maps.google.com/?q=Coffee');

        expect(log, hasLength(1));
        expect(log.first.method, 'launch');
        expect(log.first.arguments, {
          'url': 'https://maps.google.com/?q=Coffee',
        });
      });

      test('sends scheme URLs correctly', () async {
        await launcher.launch('comgooglemaps://?q=Coffee');

        expect(log, hasLength(1));
        expect(log.first.method, 'launch');
        expect(log.first.arguments, {'url': 'comgooglemaps://?q=Coffee'});
      });

      test('handles special characters in URL', () async {
        await launcher.launch('https://maps.google.com/?q=Caf%C3%A9+Shop');

        expect(log, hasLength(1));
        expect(log.first.arguments, {
          'url': 'https://maps.google.com/?q=Caf%C3%A9+Shop',
        });
      });
    });

    group('getInstalledMaps', () {
      test('returns parsed MapType list from platform response', () async {
        final result = await launcher.getInstalledMaps();

        expect(log, hasLength(1));
        expect(log.first.method, 'getInstalledMaps');
        expect(result, [MapType.google, MapType.waze]);
      });

      test('handles null response gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            });

        final result = await launcher.getInstalledMaps();
        expect(result, isEmpty);
      });

      test('skips unknown map types from native', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return [
                {'mapType': 'google'},
                {'mapType': 'unknownFutureMap'},
                {'mapType': 'waze'},
              ];
            });

        final result = await launcher.getInstalledMaps();
        expect(result, [MapType.google, MapType.waze]);
      });
    });

    group('platform', () {
      test('returns a value', () {
        // In test environment, this will be false (not running on iOS)
        expect(launcher.platform, anyOf(isNull, isA<MapPlatform>()));
      });
    });
  });
}
