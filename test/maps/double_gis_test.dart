import 'package:map_launcher/src/maps/double_gis.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  const gis = DoubleGis();

  group('DoubleGis', () {
    test('type is doubleGis', () {
      expect(gis.id, equals('doubleGis'));
    });

    group('markerUrl', () {
      test('generates 2gis.ru URL with lnglat', () {
        final url = gis.markerUrl(LocationCoords(55.751, 37.618));
        expect(url, contains('2gis.ru/geo'));
        expect(url, contains('37.618'));
      });
    });

    group('directionsUrl', () {
      test('generates route URL with mode', () {
        final url = gis.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
          travelMode: .walking,
        );
        expect(url, contains('2gis.ru/routeSearch'));
        expect(url, contains('pedestrian'));
      });

      test('includes origin when provided', () {
        final url = gis.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
          origin: LocationCoords(55.733, 37.587),
        );
        expect(url, contains('from'));
      });
    });

    group('scheme URLs', () {
      test('marker scheme uses dgis:// on iOS', () {
        final url = gis.markerSchemeUrl(
          LocationCoords(55.751, 37.618),
          platform: .ios,
        );
        expect(url, startsWith('dgis://'));
        expect(url, contains('geo'));
      });

      test('marker scheme uses dgis:// geo URL on Android', () {
        final url = gis.markerSchemeUrl(
          LocationCoords(55.751, 37.618),
          platform: .android,
        );
        expect(url, startsWith('dgis://'));
        expect(url, contains('geo/'));
      });
    });
  });
}
