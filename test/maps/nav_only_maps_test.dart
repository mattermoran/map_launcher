import 'package:map_launcher/src/maps/citymapper.dart';
import 'package:map_launcher/src/maps/tomtom.dart';
import 'package:map_launcher/src/maps/airnav_pro.dart';
import 'package:map_launcher/src/maps/flitsmeister.dart';

import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

/// Tests for all navigation-only maps that do NOT have marker in
/// their public API. Verifies:
/// - markerUrl returns null (no universal link for markers)
/// - directionsSchemeUrl returns a valid URL
/// - markerSchemeUrl returns something useful (best-effort fallback)
void main() {
  final coords = LocationCoords(51.507, -0.128, title: 'London');

  group('Citymapper (nav-only)', () {
    const cm = Citymapper();

    test('type is citymapper', () {
      expect(cm.id, equals('citymapper'));
    });

    test('markerUrl returns null', () {
      expect(cm.markerUrl(coords), isNull);
    });

    test('directionsUrl returns null (scheme only)', () {
      expect(cm.directionsUrl(destination: coords), isNull);
    });

    test('markerSchemeUrl returns directions as best-effort', () {
      final url = cm.markerSchemeUrl(coords, platform: .android);
      expect(url, isNotNull);
      expect(url, contains('citymapper://'));
    });

    test('directionsSchemeUrl generates citymapper:// URL', () {
      final url = cm.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('citymapper://'));
      expect(url, contains('endcoord='));
    });

    test('directionsSchemeUrl includes origin when provided', () {
      final url = cm.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(51.50, -0.10),
        platform: .android,
      );
      expect(url, contains('startcoord='));
    });
  });

  group('TomTomGo (nav-only)', () {
    const tt = TomTomGo();

    test('type is tomtomgo', () {
      expect(tt.id, equals('tomtomgo'));
    });

    test('markerUrl returns null', () {
      expect(tt.markerUrl(coords), isNull);
    });

    test('directionsUrl returns null', () {
      expect(tt.directionsUrl(destination: coords), isNull);
    });

    test('markerSchemeUrl returns nav URL (best-effort)', () {
      final url = tt.markerSchemeUrl(coords, platform: .ios);
      expect(url, isNotNull);
      expect(url, contains('tomtomgo://'));
    });

    test('directionsSchemeUrl iOS uses tomtomgo://', () {
      final url = tt.directionsSchemeUrl(destination: coords, platform: .ios);
      expect(url, contains('tomtomgo://'));
      expect(url, contains('destination='));
    });

    test('directionsSchemeUrl Android uses google.navigation:', () {
      final url = tt.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('google.navigation:'));
    });
  });

  group('TomTomGoFleet (nav-only)', () {
    const ttf = TomTomGoFleet();

    test('type is tomtomgofleet', () {
      expect(ttf.id, equals('tomtomgofleet'));
    });

    test('markerUrl returns null', () {
      expect(ttf.markerUrl(coords), isNull);
    });

    test('directionsSchemeUrl uses google.navigation:', () {
      final url = ttf.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('google.navigation:'));
    });
  });

  group('AirNavPro (nav-only)', () {
    const air = AirNavPro();

    test('type is airnavPro', () {
      expect(air.id, equals('airnavPro'));
    });

    test('markerUrl returns null', () {
      expect(air.markerUrl(coords), isNull);
    });

    test('directionsSchemeUrl iOS uses airnavpro://', () {
      final url = air.directionsSchemeUrl(destination: coords, platform: .ios);
      expect(url, contains('airnavpro://'));
    });

    test('directionsSchemeUrl Android uses HTTPS', () {
      final url = air.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('airnavigation.aero'));
    });
  });

  group('Flitsmeister (nav-only)', () {
    const fm = Flitsmeister();

    test('type is flitsmeister', () {
      expect(fm.id, equals('flitsmeister'));
    });

    test('markerUrl returns null', () {
      expect(fm.markerUrl(coords), isNull);
    });

    test('directionsSchemeUrl iOS uses flitsmeister://', () {
      final url = fm.directionsSchemeUrl(destination: coords, platform: .ios);
      expect(url, contains('flitsmeister://'));
    });

    test('directionsSchemeUrl Android uses geo:', () {
      final url = fm.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, startsWith('geo:'));
    });
  });
}
