import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';

typedef _Attempt = ({String url, String? package});

class _Platform extends MapLauncherPlatform {
  _Platform(this.platform);
  @override
  final MapPlatform? platform;
  final attempts = <_Attempt>[];
  Object? Function(_Attempt)? failure;
  bool allowDiscovery = false;
  bool installed = true;

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    final attempt = (url: url, package: androidPackageName);
    attempts.add(attempt);
    final error = failure?.call(attempt);
    if (error != null) throw error;
  }

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    if (!allowDiscovery) throw StateError('Automatic launch must not probe.');
    return installed ? maps.map((m) => m.id).toSet() : {};
  }
}

class _BrokenMap extends AppleMaps {
  @override
  String markerUrl(LocationCoords coords, {int? zoom}) =>
      throw ArgumentError('custom builder bug');
}

class _MutableMap extends AppleMaps {
  bool broken = false;
  @override
  String markerUrl(LocationCoords coords, {int? zoom}) {
    if (broken) throw StateError('Must not rebuild a prepared entry');
    return super.markerUrl(coords, zoom: zoom);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Platform platform;
  setUp(() {
    final original = MapLauncherPlatform.instance;
    addTearDown(() => MapLauncherPlatform.instance = original);
    platform = _Platform(.android);
    MapLauncherPlatform.instance = platform;
  });

  final noEligible = throwsA(
    isA<MapLaunchException>().having(
      (e) => e.reason,
      'reason',
      MapLaunchFailure.noEligibleMap,
    ),
  );

  test(
    'automatic route retries transports then providers without changing route',
    () async {
      platform.failure = (a) => a.url.contains('google.com')
          ? const MapHandoffException('not handled')
          : null;
      await MapLauncher.directions(
        LocationCoords(48.85, 2.29),
        from: LocationCoords(51.5, -0.12),
        mode: .walking,
        providerExtras: {
          .google: {'avoid': 'tolls'},
        },
      ).show();
      expect(platform.attempts.map((a) => a.package), [
        'com.google.android.apps.maps',
        null,
        null,
      ]);
      for (final attempt in platform.attempts.take(2)) {
        expect(Uri.parse(attempt.url).queryParameters, {
          'api': '1',
          'destination': '48.85,2.29',
          'origin': '51.5,-0.12',
          'travelmode': 'walking',
          'avoid': 'tolls',
        });
      }
      final fallback = Uri.parse(platform.attempts.last.url);
      expect(fallback.host, 'maps.apple.com');
      expect(fallback.queryParameters, {
        'daddr': '48.85,2.29',
        'saddr': '51.5,-0.12',
        'dirflg': 'w',
      });
    },
  );

  test(
    'successful handoff terminates without discovery or a second provider',
    () async {
      await MapLauncher.marker(LocationSearch('Café & ferry')).show();
      expect(platform.attempts, hasLength(1));
      expect(
        Uri.parse(platform.attempts.single.url).queryParameters['query'],
        'Café & ferry',
      );
    },
  );

  test(
    'iOS skips undocumented Apple cycling rather than changing mode',
    () async {
      platform = _Platform(.ios);
      MapLauncherPlatform.instance = platform;
      await MapLauncher.directions(
        LocationCoords(48.85, 2.29),
        mode: .bicycling,
      ).show();
      final url = Uri.parse(platform.attempts.single.url);
      expect(url.host, 'www.google.com');
      expect(url.queryParameters['travelmode'], 'bicycling');
    },
  );

  test(
    'automatic selection skips invalid provider options, never forwards them',
    () async {
      await MapLauncher.marker(
        LocationCoords(48.85, 2.29),
        providerExtras: {
          .google: GoogleExtra(originPlaceId: 'requires-an-origin'),
        },
      ).show();
      final url = Uri.parse(platform.attempts.single.url);
      expect(url.host, 'maps.apple.com');
      expect(url.queryParameters.keys, isNot(contains('origin_place_id')));
    },
  );

  for (final picker in [false, true]) {
    test(
      'explicit selection never switches providers (picker: $picker)',
      () async {
        platform.allowDiscovery = true;
        platform.failure = (_) => const MapHandoffException('not handled');
        final request = MapLauncher.marker(LocationCoords(48.85, 2.29));
        final launch = picker
            ? (await request.getSupportedMaps([.google])).single.show
            : () => request.show(map: .google);
        await expectLater(
          launch(),
          throwsA(
            isA<MapLaunchException>().having(
              (e) => e.reason,
              'reason',
              MapLaunchFailure.exhausted,
            ),
          ),
        );
        expect(platform.attempts, hasLength(2));
        expect(
          platform.attempts.every((a) => a.url.contains('google.com')),
          isTrue,
        );
      },
    );
  }

  for (final blocked in [false, true]) {
    test(
      'unknown or blocked handoff is terminal (blocked: $blocked)',
      () async {
        platform.failure = (_) => blocked
            ? const MapHandoffException('blocked', blocked: true)
            : Exception('reply lost after launch');
        await expectLater(
          MapLauncher.marker(LocationCoords(48.85, 2.29)).show(),
          throwsA(
            isA<MapLaunchException>().having(
              (e) => e.reason,
              'reason',
              blocked ? MapLaunchFailure.blocked : MapLaunchFailure.unknown,
            ),
          ),
        );
        expect(platform.attempts, hasLength(1));
      },
    );
  }

  test(
    'caller options are optional for discovery and handoff but forwarded when supplied',
    () async {
      for (final target in [MapPlatform.android, MapPlatform.ios]) {
        platform = _Platform(target)..allowDiscovery = true;
        MapLauncherPlatform.instance = platform;
        final marker = MapLauncher.marker(LocationCoords(37.5, 127.0));
        final directions = MapLauncher.directions(
          LocationCoords(37.5, 127.0),
          from: LocationCoords(37.6, 127.1),
        );
        final requests = [
          (discover: marker.getSupportedMaps, show: marker.show),
          (discover: directions.getSupportedMaps, show: directions.show),
        ];
        for (final request in requests) {
          final entries = await request.discover([.naver, .baidu, .tencent]);
          expect(entries.map((e) => e.map.id), ['naver', 'baidu', 'tencent']);
          for (final entry in entries) {
            await entry.show();
            await request.show(map: entry.map);
          }
        }
        expect(platform.attempts, hasLength(12));
        for (final attempt in platform.attempts) {
          final query = Uri.parse(attempt.url).queryParameters;
          expect(query.keys, isNot(contains('appname')));
          expect(query.keys, isNot(contains('src')));
          expect(query.keys, isNot(contains('referer')));
        }
      }
      platform = _Platform(.android);
      MapLauncherPlatform.instance = platform;
      platform.allowDiscovery = true;
      final configured = MapLauncher.marker(
        LocationCoords(37.5, 127.0),
        providerExtras: {
          .naver: NaverExtra(appName: 'org.example.app'),
          .baidu: BaiduExtra(src: 'andr.example.app'),
          .tencent: TencentExtra(referer: 'developer-key'),
        },
      );
      final entries = await configured.getSupportedMaps([
        .naver,
        .baidu,
        .tencent,
      ]);
      expect(entries.map((e) => e.map.id), ['naver', 'baidu', 'tencent']);
      for (final entry in entries) {
        await entry.show();
      }
      expect(platform.attempts, hasLength(3));
      expect(
        Uri.parse(platform.attempts[0].url).queryParameters['appname'],
        'org.example.app',
      );
      expect(
        Uri.parse(platform.attempts[1].url).queryParameters['src'],
        'andr.example.app',
      );
      expect(
        Uri.parse(platform.attempts[2].url).queryParameters['referer'],
        'developer-key',
      );
    },
  );

  test(
    'unscoped extras cannot enter automatic selection or discovery',
    () async {
      final request = MapLauncher.marker(
        LocationCoords(1, 2),
        extra: {'token': 'private'},
      );
      await expectLater(request.show(), throwsArgumentError);
      await expectLater(
        request.getSupportedMaps([.apple, .google]),
        throwsArgumentError,
      );
      expect(platform.attempts, isEmpty);
    },
  );

  test(
    'custom builder bugs are not swallowed by discovery or launching',
    () async {
      platform.allowDiscovery = true;
      final request = MapLauncher.marker(LocationCoords(1, 2));
      await expectLater(request.show(map: _BrokenMap()), throwsArgumentError);
      await expectLater(
        request.getSupportedMaps([_BrokenMap()]),
        throwsArgumentError,
      );
      expect(platform.attempts, isEmpty);
    },
  );

  for (final count in [3, 4, 9, 10]) {
    test(
      'Google preserves all $count stops and excludes incompatible transports',
      () async {
        platform.failure = (_) => const MapHandoffException('not handled');
        final stops = List.generate(
          count,
          (i) => LocationCoords(10.0 + i, -20.0 - i),
        );
        final request = MapLauncher.directions(
          LocationCoords(48.85, 2.29),
          from: LocationCoords(51.5, -0.12),
          mode: .walking,
          waypoints: stops,
        );
        await expectLater(
          request.show(),
          throwsA(
            isA<MapLaunchException>().having(
              (e) => e.reason,
              'reason',
              count > 9
                  ? MapLaunchFailure.noEligibleMap
                  : MapLaunchFailure.exhausted,
            ),
          ),
        );
        expect(
          platform.attempts,
          hasLength(
            count > 9
                ? 0
                : count > 3
                ? 1
                : 2,
          ),
        );
        for (final attempt in platform.attempts) {
          final params = Uri.parse(attempt.url).queryParameters;
          expect(
            params['waypoints'],
            List.generate(count, (i) => '${10.0 + i},${-20.0 - i}').join('|'),
          );
          expect(params['origin'], '51.5,-0.12');
          expect(params['destination'], '48.85,2.29');
          expect(params['travelmode'], 'walking');
        }
      },
    );
  }

  test(
    'mobile unpinned links reject four stops; desktop accepts up to nine',
    () async {
      final request = MapLauncher.directions(
        LocationCoords(48.85, 2.29),
        waypoints: List.generate(4, (i) => LocationCoords(10.0 + i, -20)),
      );
      platform = _Platform(.ios);
      MapLauncherPlatform.instance = platform;
      await expectLater(request.show(map: .google), noEligible);
      expect(platform.attempts, isEmpty);
      platform = _Platform(null);
      MapLauncherPlatform.instance = platform;
      await request.show(map: .google);
      expect(platform.attempts, hasLength(1));
    },
  );

  test('Google validates final encoded URL length at 2048/2049', () async {
    const prefix = 'https://www.google.com/maps/search/?api=1&query=';
    final text = 'x' * (2048 - prefix.length);
    await MapLauncher.marker(LocationSearch(text)).show(map: .google);
    expect(platform.attempts.single.url, '$prefix$text');
    await expectLater(
      MapLauncher.marker(LocationSearch('${text}x')).show(map: .google),
      noEligible,
    );
    expect(platform.attempts, hasLength(1));
  });

  test(
    'oversized HTTPS fallback does not invalidate a shorter iOS native link',
    () async {
      platform = _Platform(.ios)..allowDiscovery = true;
      MapLauncherPlatform.instance = platform;
      const prefix = 'https://www.google.com/maps/search/?api=1&query=';
      final text = 'x' * (2049 - prefix.length);
      final request = MapLauncher.marker(LocationSearch(text));
      await request.show(map: .google);
      expect(platform.attempts.single.url, 'comgooglemaps://?q=$text');
      expect(await request.getSupportedMaps([.google]), hasLength(1));
      platform.installed = false;
      expect(await request.getSupportedMaps([.google]), isEmpty);
      platform.attempts.clear();
      platform.failure = (_) => const MapHandoffException('not handled');
      await expectLater(
        request.show(map: .google),
        throwsA(
          isA<MapLaunchException>().having(
            (e) => e.reason,
            'reason',
            MapLaunchFailure.exhausted,
          ),
        ),
      );
      expect(platform.attempts.single.url, 'comgooglemaps://?q=$text');
    },
  );

  for (final blocked in [false, true]) {
    test(
      'terminal second attempt stops cross-provider retry (blocked: $blocked)',
      () async {
        platform.failure = (a) => a.package != null
            ? const MapHandoffException('not installed')
            : blocked
            ? const MapHandoffException('blocked', blocked: true)
            : Exception('reply lost');
        await expectLater(
          MapLauncher.marker(LocationCoords(1, 2)).show(),
          throwsA(
            isA<MapLaunchException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  blocked ? MapLaunchFailure.blocked : MapLaunchFailure.unknown,
                )
                .having((e) => e.issues.map((i) => i.mapId), 'issues', [
                  'google',
                  'google',
                ]),
          ),
        );
        expect(platform.attempts, hasLength(2));
      },
    );
  }

  test('prepared picker captures URL and adapter without rebuilding', () async {
    platform.allowDiscovery = true;
    final map = _MutableMap();
    final request = MapLauncher.marker(LocationCoords(48.85, 2.29));
    final entry = (await request.getSupportedMaps([map])).single;
    map.broken = true;
    final replacement = _Platform(.ios);
    MapLauncherPlatform.instance = replacement;
    await entry.show();
    expect(
      platform.attempts.single.url,
      'https://maps.apple.com/?ll=48.85%2C2.29',
    );
    expect(replacement.attempts, isEmpty);
  });

  test(
    'provider extras match IDs and reject ambiguous duplicate IDs',
    () async {
      final instance = GoogleMaps();
      await MapLauncher.marker(
        LocationCoords(1, 2),
        providerExtras: {instance: GoogleExtra(queryPlaceId: 'place-id')},
      ).show(map: .google);
      expect(
        Uri.parse(
          platform.attempts.single.url,
        ).queryParameters['query_place_id'],
        'place-id',
      );
      expect(
        () => MapLauncher.marker(
          LocationCoords(1, 2),
          providerExtras: {
            instance: {'a': 'one'},
            GoogleMaps(): {'a': 'two'},
          },
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'exhaustion reports ordered attempts without exposing URLs in toString',
    () async {
      platform.failure = (_) => const MapHandoffException('not handled');
      try {
        await MapLauncher.marker(LocationCoords(48.85, 2.29)).show();
        fail('Expected exhaustion');
      } on MapLaunchException catch (error) {
        expect(error.reason, MapLaunchFailure.exhausted);
        expect(error.issues.map((e) => e.mapId), ['google', 'google', 'apple']);
        expect(
          error.issues.every((e) => e.url != null && e.stackTrace != null),
          isTrue,
        );
        expect(() => error.issues.clear(), throwsUnsupportedError);
        expect(error.toString(), isNot(contains('48.85')));
      }
    },
  );
}
