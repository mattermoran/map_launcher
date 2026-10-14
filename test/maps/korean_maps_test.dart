import 'package:map_launcher/src/maps/naver.dart';
import 'package:map_launcher/src/maps/kakao.dart';
import 'package:map_launcher/src/maps/tmap.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:test/test.dart';

void main() {
  final coords = LocationCoords(37.566, 126.978, title: 'Seoul');

  group('NaverMap', () {
    const naver = NaverMap();

    test('type is naver', () {
      expect(naver.id, equals('naver'));
    });

    test('markerSchemeUrl uses nmap://place', () {
      final url = naver.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('nmap://place'));
      expect(url, contains('lat='));
      expect(url, contains('lng='));
    });

    test('markerSchemeUrl includes name when label present', () {
      final url = naver.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('name=Seoul'));
    });

    test('markerSchemeUrl does not send undocumented place zoom', () {
      final url = naver.markerSchemeUrl(coords, zoom: 15, platform: .android);
      expect(url, 'nmap://place?lat=37.566&lng=126.978&name=Seoul');
    });

    test('unnamed places use coordinates as the required name', () {
      for (final title in [null, '', '   ']) {
        expect(
          Uri.parse(
            naver.markerSchemeUrl(
              LocationCoords(37.566, 126.978, title: title),
              platform: .android,
            )!,
          ).queryParameters['name'],
          '37.566,126.978',
        );
      }
    });

    for (final platform in MapPlatform.values) {
      test('exact configured caller URLs on $platform', () {
        final app = NaverMap(appName: 'com.example.${platform.name}');
        expect(
          app.markerSchemeUrl(coords, zoom: 15, platform: platform),
          'nmap://place?lat=37.566&lng=126.978&name=Seoul&appname=com.example.${platform.name}',
        );
        for (final withOrigin in [false, true]) {
          expect(
            app.directionsSchemeUrl(
              destination: coords,
              origin: withOrigin
                  ? LocationCoords(37.55, 126.97, title: 'A & B')
                  : null,
              travelMode: .driving,
              platform: platform,
            ),
            'nmap://route/car?${withOrigin ? 'slat=37.55&slng=126.97&sname=A+%26+B&' : ''}dlat=37.566&dlng=126.978&dname=Seoul&appname=com.example.${platform.name}',
          );
        }
      });
    }

    test('caller URL and place name are encoded once', () {
      const app = NaverMap(appName: 'https://example.com/?a=1&b=2');
      expect(
        app.markerSchemeUrl(
          LocationCoords(37.566, 126.978, title: '서울 & /?#'),
          platform: .ios,
        ),
        'nmap://place?lat=37.566&lng=126.978&name=%EC%84%9C%EC%9A%B8+%26+%2F%3F%23&appname=https%3A%2F%2Fexample.com%2F%3Fa%3D1%26b%3D2',
      );
    });

    test('directionsSchemeUrl uses nmap://route/car', () {
      final url = naver.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('nmap://route/car'));
      expect(url, contains('dlat='));
      expect(url, contains('dlng='));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = naver.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(37.55, 126.97),
        platform: .android,
      );
      expect(url, contains('slat='));
      expect(url, contains('slng='));
    });
  });

  group('KakaoMap', () {
    const kakao = KakaoMap();

    for (final platform in MapPlatform.values) {
      for (final entry in <TravelMode?, String>{
        null: '',
        TravelMode.driving: '&by=car',
        TravelMode.transit: '&by=publictransit',
        TravelMode.walking: '&by=foot',
        TravelMode.bicycling: '&by=bicycle',
      }.entries) {
        test('exact route on $platform with ${entry.key}', () {
          for (final withOrigin in [false, true]) {
            expect(
              kakao.directionsSchemeUrl(
                destination: coords,
                origin: withOrigin ? LocationCoords(37.55, 126.97) : null,
                travelMode: entry.key,
                platform: platform,
              ),
              'kakaomap://route?${withOrigin ? 'sp=37.55%2C126.97&' : ''}ep=37.566%2C126.978${entry.value}',
            );
          }
        });
      }
    }

    test('type is kakao', () {
      expect(kakao.id, equals('kakao'));
    });

    test('markerSchemeUrl uses kakaomap://look', () {
      final url = kakao.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('kakaomap://look'));
      expect(url, contains('p='));
    });

    test('directionsSchemeUrl uses kakaomap://route', () {
      final url = kakao.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('kakaomap://route'));
      expect(url, contains('ep='));
    });

    test('directionsSchemeUrl includes origin as sp', () {
      final url = kakao.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(37.55, 126.97),
        platform: .android,
      );
      expect(url, contains('sp='));
    });
  });

  group('TMap', () {
    const tmap = TMap();

    test('type is tmap', () {
      expect(tmap.id, equals('tmap'));
    });

    test('markerSchemeUrl uses tmap://viewmap', () {
      final url = tmap.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('tmap://viewmap'));
      expect(url, contains('x='));
      expect(url, contains('y='));
    });

    test('markerSchemeUrl includes name when label present', () {
      final url = tmap.markerSchemeUrl(coords, platform: .android);
      expect(url, contains('name=Seoul'));
    });

    test('directionsSchemeUrl uses tmap://route', () {
      final url = tmap.directionsSchemeUrl(
        destination: coords,
        platform: .android,
      );
      expect(url, contains('tmap://route'));
      expect(url, contains('goalx='));
      expect(url, contains('goaly='));
      expect(url, contains('carType=1'));
    });

    test('directionsSchemeUrl includes origin', () {
      final url = tmap.directionsSchemeUrl(
        destination: coords,
        origin: LocationCoords(37.55, 126.97, title: 'Start'),
        platform: .android,
      );
      expect(url, contains('startx='));
      expect(url, contains('starty='));
    });
  });
}
