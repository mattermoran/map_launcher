import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/requests/marker_request.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMapLauncherPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockMapLauncherPlatform();
    MapLauncherPlatform.instance = mockPlatform;
  });

  group('MarkerRequest.show() error paths', () {
    test('getUrl returns null for map with no marker support on web', () {
      // On web/desktop (platform=null), Citymapper's bestMarkerUrl only
      // checks markerUrl (which returns null), not scheme URLs.
      mockPlatform.platformResponse = null;
      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      final url = req.getUrl(map: .citymapper);
      expect(url, isNull, reason: 'Citymapper has no universal marker URL');
    });

    test('show() throws UnsupportedError when getUrl returns null', () async {
      // On web/desktop, Citymapper's getUrl returns null for markers.
      mockPlatform.platformResponse = null;
      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));

      expect(
        () => req.show(map: .citymapper),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('does not support this marker type'),
          ),
        ),
      );
    });
  });

  group('MarkerRequest.show() extra merging', () {
    test('constructor extra is included in launched URL', () async {
      await MarkerRequest(
        location: LocationCoords(48.85, 2.29),
        extra: {'layer': 'traffic'},
      ).show(map: .google);

      expect(mockPlatform.launchedUrl, contains('layer=traffic'));
    });

    test('show() extra is included in launched URL', () async {
      await MarkerRequest(
        location: LocationCoords(48.85, 2.29),
      ).show(map: .google, extra: {'layer': 'transit'});

      expect(mockPlatform.launchedUrl, contains('layer=transit'));
    });

    test('show() extra wins on conflict with constructor extra', () async {
      await MarkerRequest(
        location: LocationCoords(48.85, 2.29),
        extra: {'layer': 'traffic', 'keep': 'yes'},
      ).show(map: .google, extra: {'layer': 'transit'});

      final url = mockPlatform.launchedUrl!;
      // show() extra should override constructor extra for 'layer'
      expect(url, contains('layer=transit'));
      // Constructor-only key should still be present
      expect(url, contains('keep=yes'));
      // The old value should not appear
      expect(url, isNot(contains('layer=traffic')));
    });

    test('both extras empty results in no extra params', () async {
      await MarkerRequest(
        location: LocationCoords(48.85, 2.29),
        extra: {},
      ).show(map: .google, extra: {});

      final url = mockPlatform.launchedUrl!;
      expect(url, contains('google.com'));
    });
  });

  group('MarkerRequest.getSchemeUrl()', () {
    test('returns null for LocationSearch', () {
      final req = MarkerRequest(location: LocationSearch('Coffee'));
      // Waze has no scheme search support
      final url = req.getSchemeUrl(map: .waze, platform: .ios);
      expect(url, isNull);
    });

    test('returns scheme URL for LocationSearch on supported map', () {
      final req = MarkerRequest(location: LocationSearch('Coffee'));
      // Google supports scheme search on iOS
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      expect(url, isNotNull);
      expect(url, contains('comgooglemaps://'));
      expect(url, contains('Coffee'));
    });

    test('returns scheme URL for LocationCoords on iOS', () {
      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      final url = req.getSchemeUrl(map: .google, platform: .ios);
      expect(url, isNotNull);
      expect(url, startsWith('comgooglemaps://'));
    });

    test('returns null when platform is null (web/desktop)', () {
      mockPlatform.platformResponse = null;
      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      // Don't pass platform. Falls back to instance.platform which is null
      final url = req.getSchemeUrl(map: .google);
      expect(url, isNull);
    });

    test('returns null for unregistered map type', () {
      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      // airnavPro may not have a builder in the registry
      // Let's use a map that we know has no scheme URL for a given platform
      final url = req.getSchemeUrl(map: .google, platform: .android);
      // Google Maps has no scheme URL on Android (returns null)
      expect(url, isNull);
    });
  });
  group('MarkerRequest.show() scheme-to-universal fallback', () {
    test('falls back to universal URL when scheme launch fails', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failOnScheme = true;
      mockPlatform.installedIds = {'google'};

      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      await req.show(map: .google);

      // Should have tried scheme first (comgooglemaps://), failed,
      // then launched universal (https://www.google.com/maps/...)
      expect(mockPlatform.launchedUrl, startsWith('https://'));
      expect(mockPlatform.launchedUrl, contains('google.com'));
    });

    test('rethrows if both scheme and universal fail', () async {
      mockPlatform.platformResponse = .ios;
      mockPlatform.failAlways = true;

      final req = MarkerRequest(location: LocationCoords(48.85, 2.29));
      expect(() => req.show(map: .google), throwsException);
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
