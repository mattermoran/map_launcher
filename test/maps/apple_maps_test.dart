import 'package:map_launcher/src/maps/apple_maps.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:test/test.dart';

void main() {
  const apple = AppleMaps();

  group('AppleMaps', () {
    test('type is apple', () {
      expect(apple.id, equals('apple'));
    });

    group('markerUrl', () {
      test('generates maps.apple.com URL', () {
        final url = apple.markerUrl(LocationCoords(37.759, -122.510));
        expect(url, contains('maps.apple.com'));
        expect(url, contains('ll='));
      });

      test('includes label as q param', () {
        final url = apple.markerUrl(
          LocationCoords(37.759, -122.510, title: 'Beach'),
        );
        expect(url, contains('q=Beach'));
      });

      test('includes zoom as z param', () {
        final url = apple.markerUrl(LocationCoords(37.759, -122.510), zoom: 15);
        expect(url, contains('z=15'));
      });
    });

    group('markerSearchUrl', () {
      test('generates search URL from query', () {
        final url = apple.markerSearchUrl('Coffee shops');
        expect(url, contains('maps.apple.com'));
        expect(url, contains('q=Coffee'));
      });
    });

    group('directionsUrl', () {
      test('generates directions URL with daddr', () {
        final url = apple.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, contains('maps.apple.com'));
        expect(url, contains('daddr='));
      });

      test('includes origin as saddr', () {
        final url = apple.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
          origin: LocationCoords(37.785, -122.409),
        );
        expect(url, contains('saddr='));
      });

      test('includes travel mode as dirflg', () {
        final url = apple.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
          travelMode: .walking,
        );
        expect(url, contains('dirflg=w'));
      });

      test('all travel modes map correctly', () {
        for (final mode in TravelMode.values) {
          final url = apple.directionsUrl(
            destination: LocationCoords(37.0, -122.0),
            travelMode: mode,
          );
          expect(url, contains('dirflg='));
        }
      });
    });

    group('directionsSearchUrl', () {
      test('generates URL with search destination', () {
        final url = apple.directionsSearchUrl('Eiffel Tower');
        expect(url, isNotNull);
        expect(url, contains('maps.apple.com'));
        expect(url, contains('daddr=Eiffel'));
      });

      test('includes origin when provided', () {
        final url = apple.directionsSearchUrl(
          'Eiffel Tower',
          origin: LocationCoords(48.86, 2.34),
        );
        expect(url, contains('saddr='));
      });

      test('includes travel mode', () {
        final url = apple.directionsSearchUrl(
          'Eiffel Tower',
          travelMode: .walking,
        );
        expect(url, contains('dirflg=w'));
      });
    });

    group('bestDirectionsUrl', () {
      test('returns URL for coords destination', () {
        final url = apple.bestDirectionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, isNotNull);
        expect(url, contains('maps.apple.com'));
      });

      test('returns URL for search destination', () {
        final url = apple.bestDirectionsUrl(
          destination: LocationSearch('Coffee shops'),
        );
        expect(url, isNotNull);
        expect(url, contains('maps.apple.com'));
        expect(url, contains('daddr=Coffee'));
      });
    });
  });
}
