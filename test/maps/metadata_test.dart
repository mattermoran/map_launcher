import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';

/// Expected metadata for every map, pinned to the `MapApp` objects
/// (name, store ids), the iOS `mapSchemes` dict (iosScheme), and the
/// Android `mapPackages` dict (playStoreId).
///
/// A null `iosScheme` means the map is not detectable on iOS
/// (Android-only apps, plus Apple Maps which needs no probe).
typedef _Expected = ({
  MapApp app,
  String id,
  String name,
  String? playStoreId,
  String? appStoreId,
  String? iosScheme,
  bool hasUniversalLink,
});

const _expected = <_Expected>[
  // Tier 1: universal link maps
  (
    app: MapApp.apple,
    id: 'apple',
    name: 'Apple Maps',
    playStoreId: null,
    appStoreId: '915056765',
    iosScheme: null,
    hasUniversalLink: true,
  ),
  (
    app: MapApp.google,
    id: 'google',
    name: 'Google Maps',
    playStoreId: 'com.google.android.apps.maps',
    appStoreId: '585027354',
    iosScheme: 'comgooglemaps://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.waze,
    id: 'waze',
    name: 'Waze',
    playStoreId: 'com.waze',
    appStoreId: '323229106',
    iosScheme: 'waze://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.yandexMaps,
    id: 'yandexMaps',
    name: 'Yandex Maps',
    playStoreId: 'ru.yandex.yandexmaps',
    appStoreId: '313877526',
    iosScheme: 'yandexmaps://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.doubleGis,
    id: 'doubleGis',
    name: '2GIS',
    playStoreId: 'ru.dublgis.dgismobile',
    appStoreId: '481627348',
    iosScheme: 'dgis://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.here,
    id: 'here',
    name: 'HERE WeGo',
    playStoreId: 'com.here.app.maps',
    appStoreId: '955837609',
    iosScheme: 'here-location://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.mapyCz,
    id: 'mapyCz',
    name: 'Mapy.cz',
    playStoreId: 'cz.seznam.mapy',
    appStoreId: '411411020',
    iosScheme: 'szn-mapy://',
    hasUniversalLink: true,
  ),
  (
    app: MapApp.mappls,
    id: 'mappls',
    name: 'Mappls',
    playStoreId: 'com.mmi.maps',
    appStoreId: '370210646',
    iosScheme: 'mappls://',
    hasUniversalLink: true,
  ),
  // Tier 2: mobile-only maps
  (
    app: MapApp.googleGo,
    id: 'googleGo',
    name: 'Google Maps Go',
    playStoreId: 'com.google.android.apps.mapslite',
    appStoreId: null,
    iosScheme: null,
    hasUniversalLink: false,
  ),
  (
    app: MapApp.amap,
    id: 'amap',
    name: 'Amap',
    playStoreId: 'com.autonavi.minimap',
    appStoreId: '461703208',
    iosScheme: 'iosamap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.baidu,
    id: 'baidu',
    name: 'Baidu Maps',
    playStoreId: 'com.baidu.BaiduMap',
    appStoreId: '452186370',
    iosScheme: 'baidumap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.yandexNavi,
    id: 'yandexNavi',
    name: 'Yandex Navigator',
    playStoreId: 'ru.yandex.yandexnavi',
    appStoreId: '474500851',
    iosScheme: 'yandexnavi://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.citymapper,
    id: 'citymapper',
    name: 'Citymapper',
    playStoreId: 'com.citymapper.app.release',
    appStoreId: '469463298',
    iosScheme: 'citymapper://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.mapswithme,
    id: 'mapswithme',
    name: 'MAPS.ME',
    playStoreId: 'com.mapswithme.maps.pro',
    appStoreId: '510623322',
    iosScheme: 'mapswithme://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.osmand,
    id: 'osmand',
    name: 'OsmAnd',
    playStoreId: 'net.osmand',
    appStoreId: '934850257',
    iosScheme: 'osmandmaps://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.osmandplus,
    id: 'osmandplus',
    name: 'OsmAnd+',
    playStoreId: 'net.osmand.plus',
    appStoreId: null,
    iosScheme: null,
    hasUniversalLink: false,
  ),
  (
    app: MapApp.tencent,
    id: 'tencent',
    name: 'Tencent (QQ Maps)',
    playStoreId: 'com.tencent.map',
    appStoreId: '481623196',
    iosScheme: 'qqmap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.petal,
    id: 'petal',
    name: 'Petal Maps',
    playStoreId: 'com.huawei.maps.app',
    appStoreId: null,
    iosScheme: null,
    hasUniversalLink: false,
  ),
  (
    app: MapApp.tomtomgo,
    id: 'tomtomgo',
    name: 'TomTom Go',
    playStoreId: 'com.tomtom.gplay.navapp',
    appStoreId: '884963367',
    iosScheme: 'tomtomgo://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.tomtomgofleet,
    id: 'tomtomgofleet',
    name: 'TomTom Go Fleet',
    playStoreId: 'com.tomtom.gplay.navapp.gofleet',
    appStoreId: null,
    iosScheme: null,
    hasUniversalLink: false,
  ),
  (
    app: MapApp.copilot,
    id: 'copilot',
    name: 'CoPilot',
    playStoreId: 'com.alk.copilot.mapviewer',
    appStoreId: '378870891',
    iosScheme: 'copilot://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.sygicTruck,
    id: 'sygicTruck',
    name: 'Sygic Truck',
    playStoreId: 'com.sygic.truck',
    appStoreId: '1005447813',
    iosScheme: 'com.sygic.aura://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.flitsmeister,
    id: 'flitsmeister',
    name: 'Flitsmeister',
    playStoreId: 'nl.flitsmeister',
    appStoreId: null,
    iosScheme: null,
    hasUniversalLink: false,
  ),
  (
    app: MapApp.naver,
    id: 'naver',
    name: 'Naver Map',
    playStoreId: 'com.nhn.android.nmap',
    appStoreId: '311867728',
    iosScheme: 'nmap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.kakao,
    id: 'kakao',
    name: 'Kakao Maps',
    playStoreId: 'net.daum.android.map',
    appStoreId: '304608425',
    iosScheme: 'kakaomap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.tmap,
    id: 'tmap',
    name: 'TMap',
    playStoreId: 'com.skt.tmap.ku',
    appStoreId: '431589174',
    iosScheme: 'tmap://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.moovit,
    id: 'moovit',
    name: 'Moovit',
    playStoreId: 'com.tranzmate',
    appStoreId: '498477945',
    iosScheme: 'moovit://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.neshan,
    id: 'neshan',
    name: 'Neshan',
    playStoreId: 'org.rajman.neshan.traffic.tehran.navigator',
    appStoreId: '1596368814',
    iosScheme: 'neshan://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.airnavPro,
    id: 'airnavPro',
    name: 'Air Navigation Pro',
    playStoreId: 'com.xample.airnavigation',
    appStoreId: '304684223',
    iosScheme: 'airnavpro://',
    hasUniversalLink: false,
  ),
  (
    app: MapApp.magicEarth,
    id: 'magicEarth',
    name: 'Magic Earth',
    playStoreId: 'com.generalmagic.magicearth',
    appStoreId: '476085748',
    iosScheme: 'magicearth://',
    hasUniversalLink: false,
  ),
];

void main() {
  group('MapApp metadata', () {
    test('covers every map in MapApp.all exactly once', () {
      expect(_expected.map((e) => e.app).toSet(), MapApp.all.toSet());
      expect(_expected, hasLength(MapApp.all.length));
    });

    for (final e in _expected) {
      test(e.id, () {
        expect(e.app.id, e.id);
        expect(e.app.name, e.name);
        expect(e.app.playStoreId, e.playStoreId);
        expect(e.app.appStoreId, e.appStoreId);
        expect(e.app.iosScheme, e.iosScheme);
        expect(e.app.hasUniversalLink, e.hasUniversalLink);
      });
    }

    test('ids are unique', () {
      final ids = MapApp.all.map((m) => m.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('only Apple Maps is always available, and only on iOS', () {
      for (final map in MapApp.all) {
        expect(
          map.isAlwaysAvailable(MapPlatform.ios),
          map == MapApp.apple,
          reason: map.id,
        );
        expect(
          map.isAlwaysAvailable(MapPlatform.android),
          isFalse,
          reason: map.id,
        );
      }
    });

    test('every map is detectable or always available on some platform', () {
      for (final map in MapApp.all) {
        final detectable =
            map.iosScheme != null ||
            map.playStoreId != null ||
            map.isAlwaysAvailable(MapPlatform.ios);
        expect(detectable, isTrue, reason: map.id);
      }
    });
  });
}
