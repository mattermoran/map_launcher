import 'package:map_launcher/src/maps/waze.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  const waze = Waze();

  group('Waze', () {
    test('type is waze', () {
      expect(waze.id, equals('waze'));
    });

    test('supportsMarkerCoords is false (navigation only)', () {
      expect(waze.supportsMarkerCoords, isFalse);
    });

    group('markerUrl (universal)', () {
      test('returns null (Waze is navigation only)', () {
        final url = waze.markerUrl(LocationCoords(37.759, -122.510));
        expect(url, isNull);
      });
    });

    group('directionsUrl (universal)', () {
      test('generates waze.com universal link with navigate', () {
        final url = waze.directionsUrl(
          destination: LocationCoords(37.759, -122.510),
        );
        expect(url, contains('waze.com/ul'));
        expect(url, contains('ll='));
        expect(url, contains('navigate=yes'));
      });
    });

    group('markerSchemeUrl', () {
      test('returns null (Waze is navigation only)', () {
        final url = waze.markerSchemeUrl(
          LocationCoords(37.759, -122.510),
          platform: .ios,
        );
        expect(url, isNull);
      });
    });

    group('directionsSchemeUrl', () {
      test('returns waze:// scheme URL with navigate', () {
        final url = waze.directionsSchemeUrl(
          destination: LocationCoords(37.759, -122.510),
          platform: .ios,
        );
        expect(url, startsWith('waze://'));
        expect(url, contains('navigate=yes'));
      });
    });
  });
}
