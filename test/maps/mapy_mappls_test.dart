import 'package:map_launcher/src/maps/mapy_cz.dart';
import 'package:map_launcher/src/maps/mappls.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/requests/directions_request.dart';
import 'package:test/test.dart';

void main() {
  group('MapyCz', () {
    const mapy = MapyCz();

    test('type is mapyCz', () {
      expect(mapy.id, equals('mapyCz'));
    });

    test('markerUrl generates mapy.cz URL with lnglat', () {
      final url = mapy.markerUrl(LocationCoords(50.075, 14.437));
      expect(url, contains('mapy.cz'));
      expect(url, contains('source=coor'));
    });

    test('markerUrl includes zoom', () {
      final url = mapy.markerUrl(LocationCoords(50.075, 14.437), zoom: 12);
      expect(url, contains('z=12'));
    });

    test('directionsUrl generates directions URL', () {
      final url = mapy.directionsUrl(
        destination: LocationCoords(50.075, 14.437),
      );
      expect(url, startsWith('https://mapy.com/fnc/v1/route?'));
      expect(Uri.parse(url!).queryParameters, {'end': '14.437,50.075'});
    });

    test('v1 routes serialize origin and selectable modes; reject transit', () {
      final destination = LocationCoords(-33.856784, 151.215297);
      final origin = LocationCoords(50.075, 14.437);
      for (final mode in TravelMode.values) {
        final url = DirectionsRequest(
          destination: destination,
          from: origin,
          mode: mode,
        ).getUniversalUrl(map: mapy);
        if (mode == TravelMode.transit) {
          expect(url, isNull);
        } else {
          expect(Uri.parse(url!).queryParameters, {
            'end': '151.215297,-33.856784',
            'start': '14.437,50.075',
            'routeType': {
              TravelMode.driving: 'car_fast',
              TravelMode.walking: 'foot_fast',
              TravelMode.bicycling: 'bike_road',
            }[mode],
          });
        }
      }
      expect(
        mapy.directionsUrl(destination: destination, travelMode: .transit),
        isNull,
      );
      expect(
        mapy.directionsUrl(destination: destination, waypoints: [origin]),
        isNull,
      );
    });
  });

  group('Mappls', () {
    const mappls = Mappls();

    test('type is mappls', () {
      expect(mappls.id, equals('mappls'));
    });

    test('markerUrl generates mappls.com URL', () {
      final url = mappls.markerUrl(
        LocationCoords(28.613, 77.209, title: 'New Delhi'),
      );
      expect(url, 'https://mappls.com/@28.613,77.209');
    });

    test('does not advertise ignored origin or undocumented transit', () {
      expect(mappls.supportsDirectionsOrigin, isFalse);
      expect(mappls.supportsTravelMode(.transit), isFalse);
      expect(mappls.supportsTravelMode(.driving), isTrue);
      expect(mappls.supportsTravelMode(.walking), isTrue);
      final destination = LocationCoords(28.613, 77.209);
      expect(
        mappls.directionsUrl(destination: destination, travelMode: .transit),
        isNull,
      );
      expect(
        mappls.directionsUrl(
          destination: destination,
          origin: LocationCoords(28.5, 77.1),
        ),
        isNull,
      );
    });

    test('directionsUrl includes travel mode', () {
      final url = mappls.directionsUrl(
        destination: LocationCoords(28.613, 77.209),
        travelMode: .walking,
      );
      expect(url, contains('mappls.com/navigation'));
      expect(url, contains('mode=walking'));
    });

    test('destination label round-trips while preserving places format', () {
      const label = 'Café & Tea/入口? #1';
      final url = mappls.directionsUrl(
        destination: LocationCoords(28.613, 77.209, title: label),
      );
      expect(Uri.parse(url!).queryParameters['places'], '28.613,77.209,$label');
    });
  });
}
