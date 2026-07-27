import 'package:map_launcher/src/maps/yandex_maps.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  const yandex = YandexMaps();

  group('YandexMaps', () {
    test('type is yandexMaps', () {
      expect(yandex.id, equals('yandexMaps'));
    });

    group('markerUrl', () {
      test('generates yandex.com HTTPS URL', () {
        final url = yandex.markerUrl(LocationCoords(55.751, 37.618));
        expect(url, contains('yandex.com/maps'));
        expect(url, contains('pt='));
        expect(url, contains('l=map'));
      });

      test('uses lnglat format for pt param', () {
        final url = yandex.markerUrl(LocationCoords(55.751, 37.618));
        expect(url, contains('37.618'));
        expect(url, contains('55.751'));
      });

      test('includes zoom when provided', () {
        final url = yandex.markerUrl(LocationCoords(55.751, 37.618), zoom: 15);
        expect(url, contains('z=15'));
      });
    });

    group('directionsUrl', () {
      test('generates directions URL with rtext', () {
        final url = yandex.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
        );
        expect(url, contains('yandex.com/maps'));
        expect(url, contains('rtext='));
      });

      test('includes origin in rtext', () {
        final url = yandex.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
          origin: LocationCoords(55.733, 37.587),
        );
        expect(url, contains('rtext='));
        expect(url, contains('55.733'));
      });

      test('includes waypoints in rtext', () {
        final url = yandex.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
          waypoints: [LocationCoords(55.74, 37.60)],
        );
        expect(url, contains('rtext='));
      });

      test('includes travel mode as rtt', () {
        final url = yandex.directionsUrl(
          destination: LocationCoords(55.751, 37.618),
          travelMode: .transit,
        );
        expect(url, contains('rtt=mt'));
      });
    });

    group('markerSchemeUrl', () {
      test('returns yandexmaps:// URL', () {
        final url = yandex.markerSchemeUrl(
          LocationCoords(55.751, 37.618),
          platform: .android,
        );
        expect(url, startsWith('yandexmaps://'));
        expect(url, contains('l=map'));
      });
    });

    group('directionsSchemeUrl', () {
      test('returns yandexmaps:// URL with rtext', () {
        final url = yandex.directionsSchemeUrl(
          destination: LocationCoords(55.751, 37.618),
          platform: .android,
        );
        expect(url, startsWith('yandexmaps://'));
        expect(url, contains('rtext='));
      });
    });
  });
}
