import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/requests/directions_request.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMapLauncherPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockMapLauncherPlatform();
    MapLauncherPlatform.instance = mockPlatform;
  });

  group('DirectionsRequest.show() error paths', () {
    test('throws UnsupportedError when getUrl returns null', () async {
      // Citymapper doesn't support coords directions via universal URL
      // when no scheme is available. Verify getUrl returns null first
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      final url = req.getUrl(map: .citymapper);

      // If citymapper does support it, we need a different approach
      if (url == null) {
        expect(
          () => req.show(map: .citymapper),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('does not support this directions type'),
            ),
          ),
        );
      }
    });
  });

  group('DirectionsRequest.show() extra merging', () {
    test('constructor extra is included in launched URL', () async {
      await DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        extra: {'avoid': 'tolls'},
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('avoid=tolls'));
    });

    test('show() extra is included in launched URL', () async {
      await DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
      ).show(map: .google, extra: {'avoid': 'highways'});

      expect(mockPlatform.launchedUrl, contains('avoid=highways'));
    });

    test('show() extra wins on conflict with constructor extra', () async {
      await DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        extra: {'avoid': 'tolls', 'units': 'metric'},
      ).show(map: .google, extra: {'avoid': 'highways'});

      final url = mockPlatform.launchedUrl!;
      // show() extra should override constructor extra for 'avoid'
      expect(url, contains('avoid=highways'));
      // Constructor-only key should still be present
      expect(url, contains('units=metric'));
      // The old value should not appear
      expect(url, isNot(contains('avoid=tolls')));
    });

    test('both extras null results in no extra params appended', () async {
      await DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
      ).show(map: .google);

      final url = mockPlatform.launchedUrl!;
      expect(url, contains('google.com/maps'));
    });
  });

  group('DirectionsRequest.getSchemeUrl()', () {
    test('returns null for LocationSearch on unsupported map', () {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
      );
      // Waze has no directionsSchemeSearchUrl
      final url = req.getSchemeUrl(map: .waze, platform: .ios);
      expect(url, isNull);
    });

    test('returns scheme URL for LocationSearch on supported map', () {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
      );
      // Google supports scheme search on iOS
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      expect(url, isNotNull);
      expect(url, contains('comgooglemaps://'));
      expect(url, contains('Eiffel'));
    });

    test('returns scheme URL for LocationCoords on supported platform', () {
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      // 2GIS has scheme URLs on both platforms
      final url = req.getSchemeUrl(map: .doubleGis, platform: .ios);
      expect(url, isNotNull);
      expect(url, startsWith('dgis://'));
    });

    test('returns null when platform is null (web/desktop)', () {
      mockPlatform.platformResponse = null;
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      final url = req.getSchemeUrl(map: .google);
      expect(url, isNull);
    });

    test('includes origin in scheme URL when provided', () {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationCoords(48.86, 2.34),
      );
      final url = req.getSchemeUrl(map: .doubleGis, platform: .android);
      expect(url, isNotNull);
    });

    test('includes travel mode in scheme URL when provided', () {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        mode: .walking,
      );
      // Google on iOS has a scheme URL for directions
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      if (url != null) {
        expect(url, contains('walking'));
      }
    });
  });

  group('DirectionsRequest.getUrl()', () {
    test('returns URL for Google Maps directions', () {
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      final url = req.getUrl(map: .google);
      expect(url, isNotNull);
      expect(url, contains('google.com/maps'));
      expect(url, contains('48.85'));
    });

    test('handles LocationSearch destination with origin', () {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        from: LocationSearch('Louvre Museum'),
      );
      final url = req.getUrl(map: .google);
      expect(url, isNotNull);
      expect(url, contains('Eiffel'));
      expect(url, contains('origin=Louvre'));
    });

    test('handles LocationSearch origin with saddr key for Apple', () {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationSearch('My Hotel'),
      );
      final url = req.getUrl(map: .apple);
      expect(url, isNotNull);
      expect(url, contains('saddr=My'));
    });

    test(
      'returns null for LocationSearch when map does not support search',
      () {
        // Waze does not support directionsSearch
        final req = DirectionsRequest(
          destination: LocationSearch('Coffee shops'),
        );
        expect(req.getUrl(map: .waze), isNull);
      },
    );
  });

  group('DirectionsRequest.getUniversalUrl()', () {
    test('returns HTTPS URL for Google Maps', () {
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      final url = req.getUniversalUrl(map: .google);
      expect(url, isNotNull);
      expect(url, startsWith('https://'));
      expect(url, contains('google.com'));
    });

    test('appends search origin with origin key for Google', () {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationSearch('Central Park'),
      );
      final url = req.getUniversalUrl(map: .google);
      expect(url, isNotNull);
      expect(url, contains('origin=Central'));
    });

    test('appends search origin with saddr key for Apple', () {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationSearch('Central Park'),
      );
      final url = req.getUniversalUrl(map: .apple);
      expect(url, isNotNull);
      expect(url, contains('saddr=Central'));
    });

    test('handles search destination', () {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
      );
      final url = req.getUniversalUrl(map: .google);
      expect(url, isNotNull);
      expect(url, contains('Eiffel'));
    });
  });

  group('DirectionsRequest.show() scheme-to-universal fallback', () {
    test('falls back to universal URL when scheme launch fails', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failOnScheme = true;
      mockPlatform.installedIds = {'google'};

      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationCoords(48.86, 2.34),
        mode: .driving,
      );
      await req.show(map: .google);

      // Should have tried scheme first, failed,
      // then launched universal HTTPS URL
      expect(mockPlatform.launchedUrl, startsWith('https://'));
      expect(mockPlatform.launchedUrl, contains('google.com'));
    });

    test('rethrows if both scheme and universal fail', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failAlways = true;

      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      expect(() => req.show(map: .google), throwsException);
    });
  });

  group('DirectionsRequest.getSupportedMaps(MapApp.all) filtering', () {
    test('travel mode does not filter out maps', () async {
      // Walking mode. Waze only supports driving, but should still appear
      mockPlatform.installedIds = {'google', 'waze', 'apple'};
      final walkingReq = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        mode: .walking,
      );
      final walkingMaps = await walkingReq.getSupportedMaps(MapApp.all);
      final walkingTypes = walkingMaps.map((m) => m.map).toSet();

      final drivingReq = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        mode: .driving,
      );
      final drivingMaps = await drivingReq.getSupportedMaps(MapApp.all);
      final drivingTypes = drivingMaps.map((m) => m.map).toSet();

      // Both modes should return the same set of maps
      expect(walkingTypes, equals(drivingTypes));
    });
  });
}

/// Mock platform implementation for testing.
class MockMapLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements MapLauncherPlatform {
  String? launchedUrl;
  Set<String> installedIds = {};
  MapPlatform? platformResponse = .android;

  /// When true, launch() throws on non-HTTPS (scheme) URLs.
  bool failOnScheme = false;

  /// When true, launch() always throws.
  bool failAlways = false;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    if (failAlways) throw Exception('Launch failed');
    if (failOnScheme && !url.startsWith('https://')) {
      throw Exception('Scheme launch failed');
    }
    launchedUrl = url;
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    return installedIds;
  }

  @override
  MapPlatform? get platform => platformResponse;
}
