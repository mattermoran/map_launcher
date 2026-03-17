import 'package:test/test.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/supported_map.dart';

void main() {
  group('SupportedMap', () {
    const googleApp = MapType.google;
    const flitsmeisterApp = MapType.flitsmeister;

    test('displayName delegates to app.displayName', () {
      const supportedMap = SupportedMap(mapType: googleApp, isInstalled: true);
      expect(supportedMap.displayName, googleApp.displayName);
    });

    test('icon delegates to app.icon', () {
      const supportedMap = SupportedMap(mapType: googleApp, isInstalled: true);
      expect(supportedMap.icon, googleApp.icon);
    });

    test('hasUniversalLink delegates to app.hasUniversalLink', () {
      const supportedMap1 = SupportedMap(mapType: googleApp, isInstalled: true);
      expect(supportedMap1.hasUniversalLink, googleApp.hasUniversalLink);

      const supportedMap2 = SupportedMap(
        mapType: flitsmeisterApp,
        isInstalled: true,
      );
      expect(supportedMap2.hasUniversalLink, flitsmeisterApp.hasUniversalLink);
    });

    group('opensNatively', () {
      test('returns true when isInstalled is true', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: true,
        );
        expect(supportedMap.opensNatively, isTrue);
      });

      test('returns false when isInstalled is false', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: false,
        );
        expect(supportedMap.opensNatively, isFalse);
      });
    });

    group('opensInBrowser', () {
      test('returns true when not installed AND has universal link', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: false,
        );
        expect(supportedMap.opensInBrowser, isTrue);
      });

      test('returns false when installed (even with universal link)', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: true,
        );
        expect(supportedMap.opensInBrowser, isFalse);
      });

      test('returns false when not installed AND no universal link', () {
        const supportedMap = SupportedMap(
          mapType: flitsmeisterApp,
          isInstalled: false,
        );
        expect(supportedMap.opensInBrowser, isFalse);
      });
    });

    group('appStoreUrl', () {
      test('returns URL when app has appStoreId', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: false,
        );
        expect(supportedMap.appStoreUrl, isNotNull);
        expect(supportedMap.appStoreUrl, contains(googleApp.appStoreId!));
      });

      test('returns null when app has no appStoreId', () {
        const supportedMap = SupportedMap(
          mapType: flitsmeisterApp,
          isInstalled: false,
        );
        expect(supportedMap.appStoreUrl, isNull);
      });
    });

    group('playStoreUrl', () {
      test('returns URL when app has playStoreId', () {
        const supportedMap = SupportedMap(
          mapType: googleApp,
          isInstalled: false,
        );
        expect(supportedMap.playStoreUrl, isNotNull);
        expect(supportedMap.playStoreUrl, contains(googleApp.playStoreId!));
      });

      test('returns null when app has no playStoreId', () {
        const appleApp = MapType.apple;
        const supportedMap = SupportedMap(
          mapType: appleApp,
          isInstalled: false,
        );
        expect(supportedMap.playStoreUrl, isNull);
      });
    });

    group('Equality', () {
      test('same app + same isInstalled = equal', () {
        const map1 = SupportedMap(mapType: googleApp, isInstalled: true);
        const map2 = SupportedMap(mapType: googleApp, isInstalled: true);
        expect(map1, equals(map2));
        expect(map1.hashCode, equals(map2.hashCode));
      });

      test('same app + different isInstalled = not equal', () {
        const map1 = SupportedMap(mapType: googleApp, isInstalled: true);
        const map2 = SupportedMap(mapType: googleApp, isInstalled: false);
        expect(map1, isNot(equals(map2)));
      });

      test('different app + same isInstalled = not equal', () {
        const map1 = SupportedMap(mapType: googleApp, isInstalled: true);
        const map2 = SupportedMap(mapType: flitsmeisterApp, isInstalled: true);
        expect(map1, isNot(equals(map2)));
      });
    });

    test('toString includes display name and installed status', () {
      const supportedMap = SupportedMap(mapType: googleApp, isInstalled: true);
      expect(
        supportedMap.toString(),
        'SupportedMap(Google Maps, installed: true)',
      );
    });
  });
}
