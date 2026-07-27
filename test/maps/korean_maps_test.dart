import 'package:map_launcher/src/maps/naver.dart';
import 'package:map_launcher/src/maps/kakao.dart';
import 'package:map_launcher/src/maps/tmap.dart';
import 'package:map_launcher/src/models/location.dart';
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

    test('markerSchemeUrl includes zoom', () {
      final url = naver.markerSchemeUrl(coords, zoom: 15, platform: .android);
      expect(url, contains('zoom=15'));
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
