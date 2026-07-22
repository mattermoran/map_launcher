/// Defines the map applications supported by this plugin.
///
/// Maps are categorized into two tiers:
/// - **Tier 1**: Universal link support (HTTPS URLs) — works on all platforms.
/// - **Tier 2**: Mobile-only (custom URL schemes) — requires native app.
///
/// Each entry carries static metadata (display name, store IDs, etc.)
/// that is always available without any platform calls.
enum MapType {
  // -- Tier 1: Universal link maps (all platforms) --

  /// Apple Maps.
  apple(
    displayName: 'Apple Maps',
    hasUniversalLink: true,
    playStoreId: null,
    appStoreId: null, // built-in on iOS
  ),

  /// Google Maps.
  google(
    displayName: 'Google Maps',
    hasUniversalLink: true,
    playStoreId: 'com.google.android.apps.maps',
    appStoreId: '585027354',
  ),

  /// Waze.
  waze(
    displayName: 'Waze',
    hasUniversalLink: true,
    playStoreId: 'com.waze',
    appStoreId: '323229106',
  ),

  /// Yandex Maps.
  yandexMaps(
    displayName: 'Yandex Maps',
    hasUniversalLink: true,
    playStoreId: 'ru.yandex.yandexmaps',
    appStoreId: '313877526',
  ),

  /// 2GIS.
  doubleGis(
    displayName: '2GIS',
    hasUniversalLink: true,
    playStoreId: 'ru.dublgis.dgismobile',
    appStoreId: '481627348',
  ),

  /// HERE WeGo.
  here(
    displayName: 'HERE WeGo',
    hasUniversalLink: true,
    playStoreId: 'com.here.app.maps',
    appStoreId: '955837609',
  ),

  /// Mapy.cz.
  mapyCz(
    displayName: 'Mapy.cz',
    hasUniversalLink: true,
    playStoreId: 'cz.seznam.mapy',
    appStoreId: '411411020',
  ),

  /// Mappls (MapmyIndia).
  mappls(
    displayName: 'Mappls',
    hasUniversalLink: true,
    playStoreId: 'com.mmi.maps',
    appStoreId: '370210646',
  ),

  // -- Tier 2: Mobile-only maps (URL schemes) --

  /// Google Maps Go (Android only).
  googleGo(
    displayName: 'Google Maps Go',
    playStoreId: 'com.google.android.apps.mapslite',
  ),

  /// Amap / Gaode Maps.
  amap(
    displayName: 'Amap',
    playStoreId: 'com.autonavi.minimap',
    appStoreId: '461703208',
  ),

  /// Baidu Maps.
  baidu(
    displayName: 'Baidu Maps',
    playStoreId: 'com.baidu.BaiduMap',
    appStoreId: '452186370',
  ),

  /// Yandex Navigator.
  yandexNavi(
    displayName: 'Yandex Navigator',
    playStoreId: 'ru.yandex.yandexnavi',
    appStoreId: '474500851',
  ),

  /// Citymapper.
  citymapper(
    displayName: 'Citymapper',
    playStoreId: 'com.citymapper.app.release',
    appStoreId: '469463298',
  ),

  /// Maps.me.
  mapswithme(
    displayName: 'MAPS.ME',
    playStoreId: 'com.mapswithme.maps.pro',
    appStoreId: '510623322',
  ),

  /// OsmAnd.
  osmand(
    displayName: 'OsmAnd',
    playStoreId: 'net.osmand',
    appStoreId: '934850257',
  ),

  /// OsmAnd+ (Android only).
  osmandplus(displayName: 'OsmAnd+', playStoreId: 'net.osmand.plus'),

  /// Tencent / QQ Maps.
  tencent(
    displayName: 'Tencent (QQ Maps)',
    playStoreId: 'com.tencent.map',
    appStoreId: '481623196',
  ),

  /// Petal Maps (Android only).
  petal(displayName: 'Petal Maps', playStoreId: 'com.huawei.maps.app'),

  /// TomTom Go.
  tomtomgo(
    displayName: 'TomTom Go',
    playStoreId: 'com.tomtom.gplay.navapp',
    appStoreId: '884963367',
  ),

  /// TomTom Go Fleet.
  tomtomgofleet(
    displayName: 'TomTom Go Fleet',
    playStoreId: 'com.tomtom.gplay.navapp.gofleet',
  ),

  /// CoPilot.
  copilot(
    displayName: 'CoPilot',
    playStoreId: 'com.alk.copilot.mapviewer',
    appStoreId: '378870891',
  ),

  /// Sygic Truck.
  sygicTruck(
    displayName: 'Sygic Truck',
    playStoreId: 'com.sygic.truck',
    appStoreId: '1005447813',
  ),

  /// Flitsmeister (Android only).
  flitsmeister(displayName: 'Flitsmeister', playStoreId: 'nl.flitsmeister'),

  /// Truckmeister (Android only).
  truckmeister(
    displayName: 'Truckmeister',
    playStoreId: 'nl.flitsmeister.flux',
  ),

  /// Naver Map.
  naver(
    displayName: 'Naver Map',
    playStoreId: 'com.nhn.android.nmap',
    appStoreId: '311867728',
  ),

  /// KakaoMap.
  kakao(
    displayName: 'Kakao Maps',
    playStoreId: 'net.daum.android.map',
    appStoreId: '304608425',
  ),

  /// TMAP.
  tmap(
    displayName: 'TMap',
    playStoreId: 'com.skt.tmap.ku',
    appStoreId: '431589174',
  ),

  /// Moovit.
  moovit(
    displayName: 'Moovit',
    playStoreId: 'com.tranzmate',
    appStoreId: '498477945',
  ),

  /// Neshan.
  neshan(
    displayName: 'Neshan',
    playStoreId: 'org.rajman.neshan.traffic.tehran.navigator',
    appStoreId: '1596368814',
  ),

  /// Air Navigation Pro.
  airnavPro(
    displayName: 'Air Navigation Pro',
    playStoreId: 'com.xample.airnavigation',
    appStoreId: '304684223',
  ),

  /// SPEDION Navigation (Android only).
  spedionNavigation(
    displayName: 'SPEDION Navigation',
    playStoreId: 'de.spedion.mobile.android.spediontrucknavigation',
  ),

  /// Magic Earth.
  magicEarth(
    displayName: 'Magic Earth',
    playStoreId: 'com.generalmagic.magicearth',
    appStoreId: '476085748',
  );

  /// Creates a [MapType] with the given metadata.
  const MapType({
    required this.displayName,
    this.hasUniversalLink = false,
    this.playStoreId,
    this.appStoreId,
  });

  /// Human-readable display name for this map app.
  final String displayName;

  /// Whether this map supports universal links (HTTPS URLs) that work across all platforms, including desktop and web.
  final bool hasUniversalLink;

  /// Google Play Store package identifier (Android).
  final String? playStoreId;

  /// Apple App Store numeric identifier (iOS).
  final String? appStoreId;

  /// SVG icon asset path for this map app.
  String get icon => 'packages/map_launcher/assets/icons/$name.svg';

  /// Google Play Store URL, or `null` if not available on Android.
  String? get playStoreUrl => playStoreId != null
      ? 'https://play.google.com/store/apps/details?id=$playStoreId'
      : null;

  /// Apple App Store URL, or `null` if not available on iOS.
  String? get appStoreUrl =>
      appStoreId != null ? 'https://apps.apple.com/app/id$appStoreId' : null;
}
