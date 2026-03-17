import 'package:map_launcher/src/maps/map_registry.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  group('MapRegistry', () {
    test('has a builder for every MapType', () {
      for (final type in MapType.values) {
        expect(
          MapRegistry.getBuilder(type),
          isNotNull,
          reason: '${type.displayName} should have a registered builder',
        );
      }
    });

    test('each builder returns matching type', () {
      for (final type in MapType.values) {
        final builder = MapRegistry.getBuilder(type);
        if (builder != null) {
          expect(
            builder.mapType,
            equals(type),
            reason:
                'Builder for ${type.displayName} should have type == ${type.displayName}',
          );
        }
      }
    });

    test('supportedMaps returns all registered types', () {
      final supported = MapRegistry.supportedMaps;
      // At least 30 maps registered
      expect(supported.length, greaterThanOrEqualTo(30));
    });

    test('universalLinkMaps returns only maps with universal links', () {
      final universal = MapRegistry.universalLinkMaps;
      for (final type in universal) {
        expect(
          type.hasUniversalLink,
          isTrue,
          reason: '${type.displayName} should have hasUniversalLink == true',
        );
      }
    });

    test('universalLinkMaps includes the known 8 maps', () {
      final universal = MapRegistry.universalLinkMaps;
      expect(universal, contains(MapType.google));
      expect(universal, contains(MapType.apple));
      expect(universal, contains(MapType.waze));
      expect(universal, contains(MapType.yandexMaps));
      expect(universal, contains(MapType.doubleGis));
      expect(universal, contains(MapType.here));
      expect(universal, contains(MapType.mapyCz));
      expect(universal, contains(MapType.mappls));
    });

    test('universalLinkMaps does not include scheme-only maps', () {
      final universal = MapRegistry.universalLinkMaps;
      expect(universal, isNot(contains(MapType.baidu)));
      expect(universal, isNot(contains(MapType.amap)));
      expect(universal, isNot(contains(MapType.naver)));
      expect(universal, isNot(contains(MapType.kakao)));
    });
  });
}
