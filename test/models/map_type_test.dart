import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  group('MapType', () {
    test('has all expected values', () {
      expect(MapType.values.length, greaterThanOrEqualTo(30));
    });

    test('hasUniversalLink returns true for universal link maps', () {
      expect(MapType.google.hasUniversalLink, isTrue);
      expect(MapType.apple.hasUniversalLink, isTrue);
      expect(MapType.waze.hasUniversalLink, isTrue);
      expect(MapType.yandexMaps.hasUniversalLink, isTrue);
      expect(MapType.doubleGis.hasUniversalLink, isTrue);
      expect(MapType.here.hasUniversalLink, isTrue);
      expect(MapType.mapyCz.hasUniversalLink, isTrue);
      expect(MapType.mappls.hasUniversalLink, isTrue);
    });

    test('hasUniversalLink returns false for scheme-only maps', () {
      expect(MapType.baidu.hasUniversalLink, isFalse);
      expect(MapType.amap.hasUniversalLink, isFalse);
      expect(MapType.naver.hasUniversalLink, isFalse);
      expect(MapType.kakao.hasUniversalLink, isFalse);
      expect(MapType.tmap.hasUniversalLink, isFalse);
      expect(MapType.tomtomgo.hasUniversalLink, isFalse);
      expect(MapType.citymapper.hasUniversalLink, isFalse);
      expect(MapType.flitsmeister.hasUniversalLink, isFalse);
      expect(MapType.truckmeister.hasUniversalLink, isFalse);
      expect(MapType.airnavPro.hasUniversalLink, isFalse);
    });

    test('has display name for all values', () {
      for (final app in MapType.values) {
        expect(app.displayName, isNotEmpty);
      }
    });

    test('icon asset path contains enum name', () {
      for (final app in MapType.values) {
        expect(app.icon, contains(app.name));
      }
    });

    test('Google has store IDs', () {
      expect(MapType.google.playStoreId, 'com.google.android.apps.maps');
      expect(MapType.google.appStoreId, '585027354');
      expect(MapType.google.playStoreUrl, contains('play.google.com'));
      expect(MapType.google.appStoreUrl, contains('apps.apple.com'));
    });

    test('Apple has no store IDs (built-in)', () {
      expect(MapType.apple.playStoreId, isNull);
      expect(MapType.apple.appStoreId, isNull);
      expect(MapType.apple.playStoreUrl, isNull);
      expect(MapType.apple.appStoreUrl, isNull);
    });

    test('Android-only apps have no appStoreId', () {
      expect(MapType.googleGo.appStoreId, isNull);
      expect(MapType.petal.appStoreId, isNull);
      expect(MapType.osmandplus.appStoreId, isNull);
      expect(MapType.flitsmeister.appStoreId, isNull);
      expect(MapType.truckmeister.appStoreId, isNull);
    });
  });
}
