import 'package:map_launcher/src/maps/here.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:test/test.dart';

void main() {
  const here = HereWeGoBuilder();

  group('HereWeGo', () {
    test('type is MapType.here', () {
      expect(here.mapType, equals(MapType.here));
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
