import 'package:map_launcher/src/maps/here.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:test/test.dart';

void main() {
  const here = HereWeGo();

  group('HereWeGo', () {
    test('type is here', () {
      expect(here.id, equals('here'));
    });

    group('markerUrl', () {
      test('generates share.here.com URL', () {
        final url = here.markerUrl(LocationCoords(52.520, 13.405));
        expect(url, contains('share.here.com'));
        expect(url, contains('52.52'));
      });

      test('includes zoom when provided', () {
        final url = here.markerUrl(LocationCoords(52.520, 13.405), zoom: 15);
        expect(url, contains('z=15'));
      });
    });

    group('directionsUrl', () {
      for (final entry in <TravelMode?, String>{
        null: '',
        TravelMode.driving: '?m=d',
        TravelMode.walking: '?m=w',
        TravelMode.transit: '?m=pt',
        TravelMode.bicycling: '?m=b',
      }.entries) {
        test('exact route with mode ${entry.key}', () {
          expect(
            here.directionsUrl(
              destination: LocationCoords(52.52, 13.405),
              travelMode: entry.key,
            ),
            'https://share.here.com/r/mylocation/52.52,13.405${entry.value}',
          );
          expect(
            here.directionsUrl(
              destination: LocationCoords(52.52, 13.405),
              origin: LocationCoords(53.1, 8.8, title: 'A/B, C'),
              travelMode: entry.key,
            ),
            'https://share.here.com/r/53.1,8.8,A%2FB%2C%20C/52.52,13.405${entry.value}',
          );
        });
      }

      test('generates share.here.com directions URL', () {
        final url = here.directionsUrl(
          destination: LocationCoords(52.520, 13.405),
        );
        expect(url, contains('share.here.com/r'));
      });

      test('includes travel mode', () {
        final url = here.directionsUrl(
          destination: LocationCoords(52.520, 13.405),
          travelMode: .transit,
        );
        expect(url, contains('m=pt'));
      });
    });
  });
}
