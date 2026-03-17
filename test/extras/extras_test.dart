import 'package:map_launcher/src/extras/apple_extra.dart';
import 'package:map_launcher/src/extras/google_extra.dart';
import 'package:map_launcher/src/extras/tencent_extra.dart';
import 'package:map_launcher/src/extras/waze_extra.dart';
import 'package:map_launcher/src/extras/yandex_navi_extra.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:test/test.dart';

void main() {
  group('GoogleExtra', () {
    test('with no parameters produces empty map', () {
      final extra = GoogleExtra();
      expect(extra, isEmpty);
      expect(extra.length, 0);
    });

    test('is a valid Map<String, String>', () {
      final extra = GoogleExtra(queryPlaceId: 'ChIJLU7j');
      expect(extra, isA<Map<String, String>>());
    });

    test('queryPlaceId adds query_place_id entry', () {
      final extra = GoogleExtra(queryPlaceId: 'ChIJLU7jZQu5j4AR1');
      expect(extra['query_place_id'], 'ChIJLU7jZQu5j4AR1');
      expect(extra.length, 1);
    });

    test('navigate true adds dir_action=navigate', () {
      final extra = GoogleExtra(navigate: true);
      expect(extra['dir_action'], 'navigate');
      expect(extra.length, 1);
    });

    test('navigate false (default) omits dir_action', () {
      final extra = GoogleExtra();
      expect(extra.containsKey('dir_action'), isFalse);
    });

    test('navigate false explicitly omits dir_action', () {
      final extra = GoogleExtra(navigate: false);
      expect(extra.containsKey('dir_action'), isFalse);
    });

    test('destinationPlaceId adds destination_place_id entry', () {
      final extra = GoogleExtra(destinationPlaceId: 'ChIJ_dest');
      expect(extra['destination_place_id'], 'ChIJ_dest');
      expect(extra.length, 1);
    });

    test('originPlaceId adds origin_place_id entry', () {
      final extra = GoogleExtra(originPlaceId: 'ChIJ_origin');
      expect(extra['origin_place_id'], 'ChIJ_origin');
      expect(extra.length, 1);
    });

    test('all parameters set produces correct map', () {
      final extra = GoogleExtra(
        queryPlaceId: 'ChIJLU7j',
        navigate: true,
        destinationPlaceId: 'ChIJ_dest',
        originPlaceId: 'ChIJ_origin',
      );
      expect(extra.length, 4);
      expect(extra['query_place_id'], 'ChIJLU7j');
      expect(extra['dir_action'], 'navigate');
      expect(extra['destination_place_id'], 'ChIJ_dest');
      expect(extra['origin_place_id'], 'ChIJ_origin');
    });

    test('null optional parameters are omitted', () {
      final extra = GoogleExtra(
        queryPlaceId: null,
        navigate: false,
        destinationPlaceId: null,
        originPlaceId: null,
      );
      expect(extra, isEmpty);
    });

    test('supports standard Map operations', () {
      final extra = GoogleExtra(queryPlaceId: 'abc');
      expect(extra.keys, contains('query_place_id'));
      expect(extra.values, contains('abc'));
      expect(extra.entries.length, 1);
    });
  });

  group('AppleExtra', () {
    test('with no parameters produces empty map', () {
      final extra = AppleExtra();
      expect(extra, isEmpty);
    });

    test('is a valid Map<String, String>', () {
      final extra = AppleExtra(display: .standard);
      expect(extra, isA<Map<String, String>>());
    });

    test('display standard maps to t=m', () {
      final extra = AppleExtra(display: .standard);
      expect(extra['t'], 'm');
      expect(extra.length, 1);
    });

    test('display satellite maps to t=k', () {
      final extra = AppleExtra(display: .satellite);
      expect(extra['t'], 'k');
      expect(extra.length, 1);
    });

    test('display hybrid maps to t=h', () {
      final extra = AppleExtra(display: .hybrid);
      expect(extra['t'], 'h');
      expect(extra.length, 1);
    });

    test('display transit maps to t=r', () {
      final extra = AppleExtra(display: .transit);
      expect(extra['t'], 'r');
      expect(extra.length, 1);
    });

    test('null display omits t key', () {
      final extra = AppleExtra(display: null);
      expect(extra.containsKey('t'), isFalse);
    });

    test('near parameter adds near=lat,lng entry', () {
      final coords = LocationCoords(48.85, 2.29);
      final extra = AppleExtra(near: coords);
      expect(extra['near'], '48.85,2.29');
      expect(extra.length, 1);
    });

    test('null near omits near key', () {
      final extra = AppleExtra(near: null);
      expect(extra.containsKey('near'), isFalse);
    });

    test('both display and near produces two entries', () {
      final coords = LocationCoords(40.7128, -74.006);
      final extra = AppleExtra(display: .hybrid, near: coords);
      expect(extra.length, 2);
      expect(extra['t'], 'h');
      expect(extra['near'], '40.7128,-74.006');
    });

    test('all AppleMapDisplay enum values are handled', () {
      // Ensure every enum value produces a valid non-null mapping
      for (final display in AppleMapDisplay.values) {
        final extra = AppleExtra(display: display);
        expect(
          extra.containsKey('t'),
          isTrue,
          reason: '$display should produce a t key',
        );
        expect(
          extra['t'],
          isNotEmpty,
          reason: '$display should produce a non-empty t value',
        );
      }
    });

    test('near with negative coordinates', () {
      final coords = LocationCoords(-33.8688, 151.2093);
      final extra = AppleExtra(near: coords);
      expect(extra['near'], '-33.8688,151.2093');
    });
  });

  group('WazeExtra', () {
    test('with default navigate=false produces empty map', () {
      final extra = WazeExtra();
      expect(extra, isEmpty);
    });

    test('is a valid Map<String, String>', () {
      final extra = WazeExtra(navigate: true);
      expect(extra, isA<Map<String, String>>());
    });

    test('navigate true adds navigate=yes', () {
      final extra = WazeExtra(navigate: true);
      expect(extra['navigate'], 'yes');
      expect(extra.length, 1);
    });

    test('navigate false (default) omits navigate key', () {
      final extra = WazeExtra();
      expect(extra.containsKey('navigate'), isFalse);
    });

    test('navigate false explicitly omits navigate key', () {
      final extra = WazeExtra(navigate: false);
      expect(extra.containsKey('navigate'), isFalse);
      expect(extra, isEmpty);
    });
  });

  group('TencentExtra', () {
    test('produces referer entry', () {
      final extra = TencentExtra(referer: 'my-app-key');
      expect(extra['referer'], 'my-app-key');
      expect(extra.length, 1);
    });

    test('is a valid Map<String, String>', () {
      final extra = TencentExtra(referer: 'key');
      expect(extra, isA<Map<String, String>>());
    });

    test('always contains exactly one entry', () {
      final extra = TencentExtra(referer: 'abc123');
      expect(extra.length, 1);
      expect(extra.keys.single, 'referer');
    });

    test('preserves referer value exactly', () {
      const key = 'OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77';
      final extra = TencentExtra(referer: key);
      expect(extra['referer'], key);
    });

    test('supports empty string referer', () {
      final extra = TencentExtra(referer: '');
      expect(extra['referer'], '');
      expect(extra.length, 1);
    });
  });

  group('YandexNaviExtra', () {
    test('with no parameters produces empty map', () {
      final extra = YandexNaviExtra();
      expect(extra, isEmpty);
    });

    test('is a valid Map<String, String>', () {
      final extra = YandexNaviExtra(client: 'test');
      expect(extra, isA<Map<String, String>>());
    });

    test('client adds client entry', () {
      final extra = YandexNaviExtra(client: 'my-client-id');
      expect(extra['client'], 'my-client-id');
      expect(extra.length, 1);
    });

    test('signature adds signature entry', () {
      final extra = YandexNaviExtra(signature: 'abc123sig');
      expect(extra['signature'], 'abc123sig');
      expect(extra.length, 1);
    });

    test('both client and signature produces two entries', () {
      final extra = YandexNaviExtra(client: 'my-client', signature: 'my-sig');
      expect(extra.length, 2);
      expect(extra['client'], 'my-client');
      expect(extra['signature'], 'my-sig');
    });

    test('null client omits client key', () {
      final extra = YandexNaviExtra(client: null, signature: 'sig');
      expect(extra.containsKey('client'), isFalse);
      expect(extra.length, 1);
    });

    test('null signature omits signature key', () {
      final extra = YandexNaviExtra(client: 'cli', signature: null);
      expect(extra.containsKey('signature'), isFalse);
      expect(extra.length, 1);
    });

    test('both null produces empty map', () {
      final extra = YandexNaviExtra(client: null, signature: null);
      expect(extra, isEmpty);
    });
  });

  group('Extras cross-cutting', () {
    test('all extras implement Map<String, String>', () {
      final extras = <Map<String, String>>[
        GoogleExtra(queryPlaceId: 'test'),
        AppleExtra(display: .satellite),
        WazeExtra(navigate: true),
        TencentExtra(referer: 'key'),
        YandexNaviExtra(client: 'c'),
      ];

      for (final extra in extras) {
        expect(extra, isA<Map<String, String>>());
        expect(extra.isNotEmpty, isTrue);
      }
    });

    test('extras with no optional params produce empty maps', () {
      final extras = <Map<String, String>>[
        GoogleExtra(),
        AppleExtra(),
        WazeExtra(),
        YandexNaviExtra(),
      ];

      for (final extra in extras) {
        expect(extra, isEmpty);
      }
    });

    test('extras are iterable via forEach', () {
      final extra = GoogleExtra(queryPlaceId: 'place', navigate: true);
      final collected = <String, String>{};
      extra.forEach((key, value) => collected[key] = value);
      expect(collected, {'query_place_id': 'place', 'dir_action': 'navigate'});
    });

    test('extras can be spread into another map', () {
      final extra = WazeExtra(navigate: true);
      final merged = {'existing_key': 'value', ...extra};
      expect(merged['existing_key'], 'value');
      expect(merged['navigate'], 'yes');
    });
  });
}
