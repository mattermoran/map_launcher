import 'package:map_launcher/src/maps/citymapper.dart';
import 'package:map_launcher/src/maps/tomtom.dart';
import 'package:map_launcher/src/maps/airnav_pro.dart';
import 'package:map_launcher/src/maps/flitsmeister.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/requests/directions_request.dart';

import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:test/test.dart';

/// Tests for all navigation-only maps that do NOT have marker in
/// their public API. Verifies:
/// - markerUrl returns null (no universal link for markers)
/// - directionsSchemeUrl returns a valid URL
/// - markerSchemeUrl returns something useful (best-effort fallback)
void main() {
  final coords = LocationCoords(51.507, -0.128, title: 'London');

  for (final map in [
    MapApp.tomtomgo,
    MapApp.tomtomgofleet,
    MapApp.copilot,
    MapApp.flitsmeister,
    MapApp.tmap,
    MapApp.citymapper,
    MapApp.moovit,
    MapApp.yandexNavi,
    MapApp.waze,
    MapApp.sygicTruck,
  ]) {
    test(
      '${map.id}: explicit modes are honored or rejected, default allowed',
      () {
        for (final platform in MapPlatform.values) {
          final defaultUrl = DirectionsRequest(
            destination: coords,
          ).getSchemeUrl(map: map, platform: platform);
          if (map == MapApp.tomtomgofleet && platform == MapPlatform.ios) {
            expect(defaultUrl, isNull);
            continue;
          }
          expect(defaultUrl, isNotNull);
          for (final mode in TravelMode.values) {
            final supported =
                [
                  MapApp.yandexNavi,
                  MapApp.waze,
                  MapApp.sygicTruck,
                ].contains(map) &&
                mode == TravelMode.driving;
            expect(map.supportsTravelMode(mode), supported);
            expect(
              DirectionsRequest(
                destination: coords,
                mode: mode,
              ).getSchemeUrl(map: map, platform: platform),
              supported ? isNotNull : isNull,
            );
            expect(
              map.directionsSchemeUrl(
                destination: coords,
                travelMode: mode,
                platform: platform,
              ),
              supported ? isNotNull : isNull,
            );
          }
          final origin = LocationCoords(-33.856784, 151.215297);
          final originSupported = [
            MapApp.tmap,
            MapApp.citymapper,
            MapApp.moovit,
            MapApp.yandexNavi,
          ].contains(map);
          expect(
            DirectionsRequest(
              destination: coords,
              from: origin,
            ).getSchemeUrl(map: map, platform: platform),
            originSupported ? isNotNull : isNull,
          );
          expect(
            map.directionsSchemeUrl(
              destination: coords,
              origin: origin,
              platform: platform,
            ),
            originSupported ? isNotNull : isNull,
          );
          if (originSupported) {
            final params = Uri.parse(
              DirectionsRequest(
                destination: coords,
                from: origin,
              ).getSchemeUrl(map: map, platform: platform)!,
            ).queryParameters;
            final expected = switch (map.id) {
              'tmap' => {'startx': '151.215297', 'starty': '-33.856784'},
              'citymapper' => {'startcoord': '-33.856784,151.215297'},
              'moovit' => {'orig_lat': '-33.856784', 'orig_lon': '151.215297'},
              'yandexNavi' => {
                'lat_from': '-33.856784',
                'lon_from': '151.215297',
              },
              _ => <String, String>{},
            };
            for (final entry in expected.entries) {
              expect(params[entry.key], entry.value);
            }
          }
          if (map == MapApp.waze) {
            expect(
              DirectionsRequest(
                destination: coords,
                from: origin,
              ).getUniversalUrl(map: map),
              isNull,
            );
            expect(
              DirectionsRequest(
                destination: coords,
                mode: .walking,
              ).getUniversalUrl(map: map),
              isNull,
            );
          }
        }
      },
    );
  }

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

    test('iOS markers cannot invoke navigation', () {
      final url = tt.markerSchemeUrl(coords, platform: .ios);
      expect(url, isNull);
    });

    test('Android marker label round-trips through query encoding once', () {
      const label = 'Café & Tea/入口? #1';
      final url = tt.markerSchemeUrl(
        LocationCoords(51.507, -0.128, title: label),
        platform: .android,
      );
      expect(Uri.parse(url!).queryParameters['q'], '51.507,-0.128($label)');
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

  group('AirNavPro (no safe display contract)', () {
    const air = AirNavPro();

    test('type is airnavPro', () {
      expect(air.id, equals('airnavPro'));
    });

    test('markerUrl returns null', () {
      expect(air.markerUrl(coords), isNull);
    });

    test('markers and directions never start aviation guidance', () {
      expect(air.supportsMarkerCoords, isFalse);
      expect(air.supportsDirectionsCoords, isFalse);
      expect(air.directionsUrl(destination: coords), isNull);
      for (final platform in MapPlatform.values) {
        expect(air.markerSchemeUrl(coords, platform: platform), isNull);
        expect(
          air.directionsSchemeUrl(destination: coords, platform: platform),
          isNull,
        );
        expect(air.bestMarkerUrl(coords, platform: platform), isNull);
      }
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
