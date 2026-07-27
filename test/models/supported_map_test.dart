import 'package:test/test.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/supported_map.dart';

void main() {
  group('SupportedMap', () {
    const googleApp = MapApp.google;
    const flitsmeisterApp = MapApp.flitsmeister;

    test('displayName delegates to app.name', () {
      const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
      expect(supportedMap.name, googleApp.name);
    });

    test('icon delegates to app.iconBytes', () {
      const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
      expect(supportedMap.iconBytes, googleApp.iconBytes);
    });

    test('hasUniversalLink delegates to app.hasUniversalLink', () {
      const supportedMap1 = SupportedMap(map: googleApp, isInstalled: true);
      expect(supportedMap1.hasUniversalLink, googleApp.hasUniversalLink);

      const supportedMap2 = SupportedMap(
        map: flitsmeisterApp,
        isInstalled: true,
      );
      expect(supportedMap2.hasUniversalLink, flitsmeisterApp.hasUniversalLink);
    });

    group('opensNatively', () {
      test('returns true when isInstalled is true', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
        expect(supportedMap.opensNatively, isTrue);
      });

      test('returns false when isInstalled is false', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: false);
        expect(supportedMap.opensNatively, isFalse);
      });
    });

    group('opensInBrowser', () {
      test('returns true when not installed AND has universal link', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: false);
        expect(supportedMap.opensInBrowser, isTrue);
      });

      test('returns false when installed (even with universal link)', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
        expect(supportedMap.opensInBrowser, isFalse);
      });

      test('returns false when not installed AND no universal link', () {
        const supportedMap = SupportedMap(
          map: flitsmeisterApp,
          isInstalled: false,
        );
        expect(supportedMap.opensInBrowser, isFalse);
      });
    });

    group('appStoreUrl', () {
      test('returns URL when app has appStoreId', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: false);
        expect(supportedMap.appStoreUrl, isNotNull);
        expect(supportedMap.appStoreUrl, contains(googleApp.appStoreId!));
      });

      test('returns null when app has no appStoreId', () {
        const supportedMap = SupportedMap(
          map: flitsmeisterApp,
          isInstalled: false,
        );
        expect(supportedMap.appStoreUrl, isNull);
      });
    });

    group('playStoreUrl', () {
      test('returns URL when app has playStoreId', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: false);
        expect(supportedMap.playStoreUrl, isNotNull);
        expect(supportedMap.playStoreUrl, contains(googleApp.playStoreId!));
      });

      test('returns null when app has no playStoreId', () {
        const appleApp = MapApp.apple;
        const supportedMap = SupportedMap(map: appleApp, isInstalled: false);
        expect(supportedMap.playStoreUrl, isNull);
      });
    });

    group('Equality', () {
      test('same app + same isInstalled = equal', () {
        const map1 = SupportedMap(map: googleApp, isInstalled: true);
        const map2 = SupportedMap(map: googleApp, isInstalled: true);
        expect(map1, equals(map2));
        expect(map1.hashCode, equals(map2.hashCode));
      });

      test('same app + different isInstalled = not equal', () {
        const map1 = SupportedMap(map: googleApp, isInstalled: true);
        const map2 = SupportedMap(map: googleApp, isInstalled: false);
        expect(map1, isNot(equals(map2)));
      });

      test('different app + same isInstalled = not equal', () {
        const map1 = SupportedMap(map: googleApp, isInstalled: true);
        const map2 = SupportedMap(map: flitsmeisterApp, isInstalled: true);
        expect(map1, isNot(equals(map2)));
      });
    });

    test('toString includes display name and installed status', () {
      const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
      expect(
        supportedMap.toString(),
        'SupportedMap(Google Maps, installed: true)',
      );
    });

    group('show()', () {
      test('throws StateError when created via public constructor', () {
        const supportedMap = SupportedMap(map: googleApp, isInstalled: true);
        expect(() => supportedMap.show(), throwsStateError);
      });

      test('calls launcher when created via launchable constructor', () async {
        var called = false;
        final supportedMap = SupportedMap.launchable(
          map: googleApp,
          isInstalled: true,
          launcher: ({Map<String, String>? extra}) async { called = true; },
        );
        await supportedMap.show();
        expect(called, isTrue);
      });

      test('forwards extra to launcher', () async {
        Map<String, String>? receivedExtra;
        final supportedMap = SupportedMap.launchable(
          map: googleApp,
          isInstalled: true,
          launcher: ({Map<String, String>? extra}) async {
            receivedExtra = extra;
          },
        );
        await supportedMap.show(extra: {'key': 'val'});
        expect(receivedExtra, {'key': 'val'});
      });
    });
  });
}
