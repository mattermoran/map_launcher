import 'package:map_launcher/src/maps/google_maps.dart';
import 'package:map_launcher/src/maps/waze.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  const google = GoogleMaps();

  group('GoogleMaps', () {
    test('type is google', () {
      expect(google.id, equals('google'));
    });

    group('markerUrl', () {
      test('generates correct HTTPS URL', () {
        final url = google.markerUrl(
          LocationCoords(37.759, -122.510, title: 'Ocean Beach'),
        );
        expect(url, contains('google.com/maps/search'));
        expect(url, contains('api=1'));
        expect(url, contains('37.759'));
        expect(url, contains('-122.51'));
      });

      test('does not include label in universal URL', () {
        final url = google.markerUrl(
          LocationCoords(37.759, -122.510, title: 'Ocean Beach'),
        );
        expect(url, contains('37.759'));
        expect(url, isNot(contains('Ocean')));
      });

      test('works without label', () {
        final url = google.markerUrl(LocationCoords(37.759, -122.510));
        expect(url, contains('37.759'));
      });
    });

    group('markerSearchUrl', () {
      test('generates search URL from query string', () {
        final url = google.markerSearchUrl('Coffee shops near me');
        expect(url, contains('google.com/maps/search'));
        expect(url, contains('api=1'));
        expect(url, contains('Coffee'));
      });
    });

    group('directionsUrl', () {
      test('generates correct direction URL', () {
        final url = google.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, contains('google.com/maps/dir'));
        expect(url, contains('api=1'));
        expect(url, contains('destination='));
      });

      test('includes origin when provided', () {
        final url = google.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
          origin: LocationCoords(37.785, -122.409),
        );
        expect(url, contains('origin='));
        expect(url, contains('37.785'));
      });

      test('includes waypoints when provided', () {
        final url = google.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
          waypoints: [
            LocationCoords(37.77, -122.45),
            LocationCoords(37.78, -122.42),
          ],
        );
        expect(url, contains('waypoints='));
      });

      test('includes travel mode when provided', () {
        final url = google.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
          travelMode: .walking,
        );
        expect(url, contains('travelmode=walking'));
      });

      test('omits optional params when not provided', () {
        final url = google.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, isNot(contains('origin=')));
        expect(url, isNot(contains('waypoints=')));
        expect(url, isNot(contains('travelmode=')));
      });
    });

    group('markerSchemeUrl', () {
      test('returns iOS scheme URL for MapPlatform.ios', () {
        final url = google.markerSchemeUrl(
          LocationCoords(37.759, -122.510),
          platform: .ios,
        );
        expect(url, isNotNull);
        expect(url, startsWith('comgooglemaps://'));
      });

      test('returns null for MapPlatform.android', () {
        final url = google.markerSchemeUrl(
          LocationCoords(37.759, -122.510),
          platform: .android,
        );
        expect(url, isNull);
      });

      test('includes zoom in iOS scheme URL', () {
        final url = google.markerSchemeUrl(
          LocationCoords(37.759, -122.510),
          zoom: 15,
          platform: .ios,
        );
        expect(url, contains('zoom=15'));
      });
    });

    group('bestMarkerUrl', () {
      test('returns universal link for coords', () {
        final url = google.bestMarkerUrl(LocationCoords(37.759, -122.510));
        expect(url, isNotNull);
        expect(url, contains('google.com'));
      });

      test('returns query URL for LocationSearch', () {
        final url = google.bestMarkerUrl(LocationSearch('Coffee'));
        expect(url, isNotNull);
        expect(url, contains('Coffee'));
      });
    });

    group('bestDirectionsUrl', () {
      test('returns universal link for coords destination', () {
        final url = google.bestDirectionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, isNotNull);
        expect(url, contains('google.com/maps/dir'));
      });

      test('returns URL for search destination', () {
        final url = google.bestDirectionsUrl(
          destination: LocationSearch('Eiffel Tower'),
        );
        expect(url, isNotNull);
        expect(url, contains('google.com/maps/dir'));
        expect(url, contains('Eiffel'));
      });

      test('returns null for search destination on unsupported builder', () {
        // Waze doesn't support directions search
        const waze = Waze();
        final url = waze.bestDirectionsUrl(
          destination: LocationSearch('Coffee shop'),
        );
        expect(url, isNull);
      });
    });

    group('directionsSearchUrl', () {
      test('generates search-based directions URL', () {
        final url = google.directionsSearchUrl('Ocean Beach');
        expect(url, isNotNull);
        expect(url, contains('destination=Ocean'));
      });

      test('includes origin and travel mode', () {
        final url = google.directionsSearchUrl(
          'Golden Gate Bridge',
          origin: LocationCoords(37.759, -122.510),
          travelMode: .walking,
        );
        expect(url, isNotNull);
        expect(url, contains('destination=Golden'));
        expect(url, contains('origin='));
        expect(url, contains('travelmode=walking'));
      });
    });
  });
}
