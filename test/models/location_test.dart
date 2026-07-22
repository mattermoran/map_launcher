import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('LocationCoords', () {
    test('latlng returns "lat,lng" format', () {
      final loc = LocationCoords(37.759, -122.510);
      expect(loc.latlng, equals('37.759,-122.51'));
    });

    test('lnglat returns "lng,lat" format', () {
      final loc = LocationCoords(37.759, -122.510);
      expect(loc.lnglat, equals('-122.51,37.759'));
    });

    test('stores title', () {
      final loc = LocationCoords(37.759, -122.510, title: 'Ocean Beach');
      expect(loc.title, equals('Ocean Beach'));
    });

    test('title is null by default', () {
      final loc = LocationCoords(37.759, -122.510);
      expect(loc.title, isNull);
    });

    test('toString includes title when present', () {
      final loc = LocationCoords(37.759, -122.510, title: 'Beach');
      expect(loc.toString(), contains('Beach'));
    });

    test('toString omits title when null', () {
      final loc = LocationCoords(37.759, -122.510);
      expect(loc.toString(), isNot(contains('title')));
    });

    test('throws on invalid latitude', () {
      expect(() => LocationCoords(91, 0), throwsArgumentError);
      expect(() => LocationCoords(-91, 0), throwsArgumentError);
    });

    test('throws on invalid longitude', () {
      expect(() => LocationCoords(0, 181), throwsArgumentError);
      expect(() => LocationCoords(0, -181), throwsArgumentError);
    });

    test('equality works', () {
      final a = LocationCoords(37.759, -122.510, title: 'Beach');
      final b = LocationCoords(37.759, -122.510, title: 'Beach');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality works with different title', () {
      final a = LocationCoords(37.759, -122.510, title: 'A');
      final b = LocationCoords(37.759, -122.510, title: 'B');
      expect(a, isNot(equals(b)));
    });

    group('boundary values', () {
      test('accepts exact max boundaries (90, 180)', () {
        final loc = LocationCoords(90, 180);
        expect(loc.lat, equals(90));
        expect(loc.lng, equals(180));
      });

      test('accepts exact min boundaries (-90, -180)', () {
        final loc = LocationCoords(-90, -180);
        expect(loc.lat, equals(-90));
        expect(loc.lng, equals(-180));
      });

      test('accepts zero coordinates (0, 0)', () {
        final loc = LocationCoords(0, 0);
        expect(loc.lat, equals(0));
        expect(loc.lng, equals(0));
      });

      test('rejects lat just over max boundary', () {
        expect(() => LocationCoords(90.001, 0), throwsArgumentError);
      });

      test('rejects lat just under min boundary', () {
        expect(() => LocationCoords(-90.001, 0), throwsArgumentError);
      });

      test('rejects lng just over max boundary', () {
        expect(() => LocationCoords(0, 180.001), throwsArgumentError);
      });

      test('rejects lng just under min boundary', () {
        expect(() => LocationCoords(0, -180.001), throwsArgumentError);
      });
    });
  });

  group('LocationSearch', () {
    test('stores query string', () {
      final loc = LocationSearch('Coffee shops near me');
      expect(loc.query, equals('Coffee shops near me'));
    });

    test('throws on empty query', () {
      expect(() => LocationSearch(''), throwsArgumentError);
    });

    test('toString includes query', () {
      final loc = LocationSearch('Coffee shops');
      expect(loc.toString(), contains('Coffee shops'));
    });

    test('equality works', () {
      final a = LocationSearch('Coffee');
      final b = LocationSearch('Coffee');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('Location sealed class', () {
    test('coords creates LocationCoords', () {
      final loc = LocationCoords(37.0, -122.0);
      expect(loc, isA<LocationCoords>());
      expect(loc, isA<Location>());
    });

    test('search creates LocationSearch', () {
      final loc = LocationSearch('test');
      expect(loc, isA<LocationSearch>());
      expect(loc, isA<Location>());
    });

    test('pattern matching works with sealed class', () {
      final Location loc = LocationCoords(37.0, -122.0);
      final result = switch (loc) {
        LocationCoords c => c.latlng,
        LocationSearch q => q.query,
      };
      expect(result, equals('37.0,-122.0'));
    });
  });
}
