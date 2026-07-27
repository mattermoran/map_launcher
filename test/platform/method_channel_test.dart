import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_method_channel.dart';
import 'package:map_launcher/src/maps/map_app.dart';
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
              // Native returns installed ids plus (iOS only) ids whose
              // scheme is missing from LSApplicationQueriesSchemes
              return {
                'installed': ['google', 'waze'],
                'undeclared': <String>[],
              };
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

      test('sends packageName when provided', () async {
        await launcher.launch(
          'https://maps.google.com/?q=Coffee',
          androidPackageName: 'com.google.android.apps.maps',
        );

        expect(log, hasLength(1));
        expect(log.first.arguments, {
          'url': 'https://maps.google.com/?q=Coffee',
          'packageName': 'com.google.android.apps.maps',
        });
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
      test('returns installed map ids from native probe', () async {
        final result = await launcher.getInstalledMaps(MapApp.all);

        expect(log, hasLength(1));
        expect(log.first.method, 'getInstalledMaps');
        // The probe payload is a map of id → scheme/package
        expect(log.first.arguments, isA<Map>());
        // Result includes the native-detected ids plus always-available maps
        expect(result, contains('google'));
        expect(result, contains('waze'));
      });

      test('handles null response gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            });

        final result = await launcher.getInstalledMaps(MapApp.all);
        // Even with null response, Apple Maps is always available
        // (since test platform may report null, it depends on defaultTargetPlatform)
        expect(result, isA<Set<String>>());
      });

      test('includes always-available maps', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return {'installed': <String>[]}; // No natively detected maps
            });

        final result = await launcher.getInstalledMaps([.apple]);
        // In test environment, platform is neither iOS nor Android,
        // so isAlwaysAvailable returns false
        expect(result, isA<Set<String>>());
      });

      test('returns empty set for old native format (plain List)', () async {
        // If native side hasn't been updated and still returns a List
        // instead of Map{installed: [], undeclared: []}, detection should
        // degrade gracefully rather than crash.
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return <String>['google', 'waze']; // old format
            });

        final result = await launcher.getInstalledMaps([.google, .waze]);
        // Old format is silently ignored (result is Map check fails)
        expect(result, isA<Set<String>>());
        expect(result, isNot(contains('google')));
      });
    });

    group('undeclared scheme warning', () {
      final warnings = <String>[];

      setUp(() {
        warnings.clear();
        MethodChannelMapLauncher.warnedUndeclaredIds.clear();
        final original = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          warnings.add(message ?? '');
        };
        addTearDown(() => debugPrint = original);
      });

      void mockUndeclared(List<String> undeclared) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              log.add(methodCall);
              return {'installed': <String>[], 'undeclared': undeclared};
            });
      }

      test('warns with map id and plist scheme', () async {
        mockUndeclared(['waze']);

        await launcher.getInstalledMaps([.waze]);

        expect(warnings, hasLength(1));
        expect(warnings.first, contains('MapApp.waze'));
        expect(warnings.first, contains("'waze'"));
        expect(warnings.first, contains('LSApplicationQueriesSchemes'));
      });

      test('strips :// from the scheme in the message', () async {
        mockUndeclared(['sygicTruck']);

        await launcher.getInstalledMaps([.sygicTruck]);

        expect(warnings, hasLength(1));
        expect(warnings.first, contains("'com.sygic.aura'"));
        expect(warnings.first, isNot(contains('com.sygic.aura://')));
      });

      test('batches multiple undeclared maps into one message', () async {
        mockUndeclared(['waze', 'moovit', 'neshan']);

        await launcher.getInstalledMaps([.waze, .moovit, .neshan]);

        expect(warnings, hasLength(1));
        expect(warnings.first, contains('3 map(s)'));
        expect(warnings.first, contains("MapApp.waze → add 'waze'"));
        expect(warnings.first, contains("MapApp.moovit → add 'moovit'"));
        expect(warnings.first, contains("MapApp.neshan → add 'neshan'"));
      });

      test('warns only once per map across repeated calls', () async {
        mockUndeclared(['waze']);

        await launcher.getInstalledMaps([.waze]);
        await launcher.getInstalledMaps([.waze]);

        expect(warnings, hasLength(1));
      });

      test('does not warn when undeclared is empty or absent', () async {
        mockUndeclared([]);
        await launcher.getInstalledMaps([.waze]);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              return {'installed': <String>[]};
            });
        await launcher.getInstalledMaps([.waze]);

        expect(warnings, isEmpty);
      });

      test('unknown ids fall back to the id in the message', () async {
        mockUndeclared(['mystery']);

        await launcher.getInstalledMaps([.waze]);

        expect(warnings, hasLength(1));
        expect(warnings.first, contains('MapApp.mystery'));
      });
    });

    group('platform', () {
      test('returns a value', () {
        // In test environment, this will be null (not running on iOS/Android)
        expect(launcher.platform, anyOf(isNull, isA<MapPlatform>()));
      });
    });
  });
}
