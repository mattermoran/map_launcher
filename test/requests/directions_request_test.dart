import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
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
      mockPlatform.platformResponse = null;
      final req = DirectionsRequest(destination: LocationCoords(48.85, 2.29));
      final url = req.getUrl(map: .citymapper);
      expect(url, isNull);
      await expectLater(
        req.show(map: .citymapper),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('does not support this directions type'),
          ),
        ),
      );
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
      mockPlatform.platformResponse = .ios;
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        mode: .walking,
      );
      // Google on iOS has a scheme URL for directions
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      expect(url, isNotNull);
      expect(url, contains('walking'));
    });

    test('iOS Google text destination and origin use saddr', () {
      mockPlatform.platformResponse = .ios;
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        from: LocationSearch('Louvre Museum'),
      );
      for (final url in [
        req.getUrl(map: .google),
        req.getSchemeUrl(map: .google, platform: .ios),
      ]) {
        expect(url, startsWith('comgooglemaps://'));
        expect(url, contains('saddr=Louvre'));
        expect(url, isNot(contains('origin=Louvre')));
      }
      expect(req.getUniversalUrl(map: .google), contains('origin=Louvre'));
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
        destination: LocationSearch('Eiffel Tower'),
        from: LocationSearch('Louvre Museum'),
        mode: .driving,
      );
      await req.show(map: .google);

      // Should have tried scheme first, failed,
      // then launched universal HTTPS URL
      expect(mockPlatform.launchedUrl, startsWith('https://'));
      expect(mockPlatform.launchedUrl, contains('google.com'));
      expect(mockPlatform.attempts, hasLength(2));
      expect(mockPlatform.attempts.last.package, isNull);
    });

    test(
      'Android HTTPS package failure retries same URL without package',
      () async {
        mockPlatform.platformResponse = .android;
        mockPlatform.failWhenPackaged = true;
        await DirectionsRequest(
          destination: LocationCoords(48.85, 2.29),
        ).show(map: .google);
        expect(mockPlatform.attempts, hasLength(2));
        expect(mockPlatform.attempts[0].url, mockPlatform.attempts[1].url);
        expect(mockPlatform.attempts[0].package, MapApp.google.playStoreId);
        expect(mockPlatform.attempts[1].package, isNull);
      },
    );

    test('fallback extras occur once and show values win', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failOnScheme = true;
      await DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        extra: {'keep': 'yes', 'winner': 'old'},
      ).show(map: .google, extra: {'winner': 'show'});
      final url = mockPlatform.attempts.last.url;
      expect(RegExp('keep=yes').allMatches(url), hasLength(1));
      expect(RegExp('winner=show').allMatches(url), hasLength(1));
      expect(url, isNot(contains('winner=old')));
      expect(mockPlatform.attempts.last.package, isNull);
    });

    test('web failure is not retried even with extras', () async {
      mockPlatform.platformResponse = null;
      mockPlatform.failAlways = true;
      final cause = Exception('web');
      mockPlatform.failure = cause;
      await expectLater(
        DirectionsRequest(
          destination: LocationCoords(1, 2),
          extra: {'x': 'y'},
        ).show(map: .google),
        throwsA(
          isA<MapLaunchException>().having((e) => e.cause, 'cause', cause),
        ),
      );
      expect(mockPlatform.attempts, hasLength(1));
    });

    test('fallback error preserves fallback URL and cause', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failAlways = true;
      final cause = Exception('fallback');
      mockPlatform.failure = cause;
      await expectLater(
        DirectionsRequest(
          destination: LocationSearch('Eiffel Tower'),
        ).show(map: .google),
        throwsA(
          isA<MapLaunchException>()
              .having((e) => e.url, 'url', startsWith('https://'))
              .having((e) => e.cause, 'cause', cause),
        ),
      );
      expect(mockPlatform.attempts, hasLength(2));
    });

    test(
      'native-only error preserves attempted URL and original cause',
      () async {
        mockPlatform.platformResponse = .ios;
        mockPlatform.failAlways = true;
        final cause = Exception('native');
        mockPlatform.failure = cause;
        await expectLater(
          DirectionsRequest(
            destination: LocationCoords(1, 2),
          ).show(map: .citymapper),
          throwsA(
            isA<MapLaunchException>()
                .having((e) => e.url, 'url', startsWith('citymapper://'))
                .having((e) => e.cause, 'cause', cause),
          ),
        );
        expect(mockPlatform.attempts, hasLength(1));
      },
    );
  });

  group('DirectionsRequest.getSupportedMaps(MapApp.all) filtering', () {
    test('walking mode explicitly filters out Waze', () async {
      mockPlatform.installedIds = {'google', 'waze', 'apple'};
      final walkingReq = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        mode: .walking,
      );
      final walkingMaps = await walkingReq.getSupportedMaps(MapApp.all);
      final walkingTypes = walkingMaps.map((m) => m.map).toSet();

      expect(walkingTypes, contains(MapApp.google));
      expect(walkingTypes, isNot(contains(MapApp.waze)));
      expect(walkingReq.getUrl(map: .waze), isNull);
      await expectLater(
        walkingReq.show(map: .waze),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('DirectionsRequest unsupported request guards', () {
    test('search destination with nonempty waypoints is unsupported', () async {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        waypoints: [LocationCoords(48.86, 2.34)],
      );
      expect(req.getUrl(map: .google), isNull);
      expect(req.getSchemeUrl(map: .google, platform: .ios), isNull);
      expect(req.getUniversalUrl(map: .google), isNull);
      await expectLater(
        req.show(map: .google),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('search destination with empty waypoints is allowed', () {
      final req = DirectionsRequest(
        destination: LocationSearch('Eiffel Tower'),
        waypoints: const [],
      );
      expect(req.getUrl(map: .google), isNotNull);
    });

    test('unsupported search origins are rejected', () async {
      final req = DirectionsRequest(
        destination: LocationCoords(48.85, 2.29),
        from: LocationSearch('Hotel'),
      );
      expect(req.getUrl(map: .waze), isNull);
      expect(req.getUniversalUrl(map: .waze), isNull);
      expect(req.getSchemeUrl(map: .waze, platform: .ios), isNull);
      await expectLater(req.show(map: .waze), throwsA(isA<UnsupportedError>()));
    });
  });
}

/// Mock platform implementation for testing.
class MockMapLauncherPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements MapLauncherPlatform {
  String? launchedUrl;
  final List<LaunchAttempt> attempts = [];
  Set<String> installedIds = {};
  MapPlatform? platformResponse = .android;

  /// When true, launch() throws on non-HTTPS (scheme) URLs.
  bool failOnScheme = false;

  /// When true, launch() always throws.
  bool failAlways = false;
  bool failWhenPackaged = false;
  Exception failure = Exception('Launch failed');

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    attempts.add(LaunchAttempt(url, androidPackageName));
    if (failAlways || (failWhenPackaged && androidPackageName != null)) {
      throw failure;
    }
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

class LaunchAttempt {
  const LaunchAttempt(this.url, this.package);
  final String url;
  final String? package;
}
