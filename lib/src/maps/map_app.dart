import 'dart:typed_data';

import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

// Import all concrete map classes. These are re-exported from the barrel
// file (lib/map_launcher.dart) via map_app.dart's exports would create a
// circular issue; the barrel file handles the re-export instead.
import 'package:map_launcher/src/maps/airnav_pro.dart';
import 'package:map_launcher/src/maps/amap.dart';
import 'package:map_launcher/src/maps/apple_maps.dart';
import 'package:map_launcher/src/maps/baidu.dart';
import 'package:map_launcher/src/maps/citymapper.dart';
import 'package:map_launcher/src/maps/copilot.dart';
import 'package:map_launcher/src/maps/double_gis.dart';
import 'package:map_launcher/src/maps/flitsmeister.dart';
import 'package:map_launcher/src/maps/google_go.dart';
import 'package:map_launcher/src/maps/google_maps.dart';
import 'package:map_launcher/src/maps/here.dart';
import 'package:map_launcher/src/maps/kakao.dart';
import 'package:map_launcher/src/maps/magic_earth.dart';
import 'package:map_launcher/src/maps/mappls.dart';
import 'package:map_launcher/src/maps/mapswithme.dart';
import 'package:map_launcher/src/maps/mapy_cz.dart';
import 'package:map_launcher/src/maps/moovit.dart';
import 'package:map_launcher/src/maps/naver.dart';
import 'package:map_launcher/src/maps/neshan.dart';
import 'package:map_launcher/src/maps/osmand.dart';
import 'package:map_launcher/src/maps/petal.dart';
import 'package:map_launcher/src/maps/sygic_truck.dart';
import 'package:map_launcher/src/maps/tencent.dart';
import 'package:map_launcher/src/maps/tmap.dart';
import 'package:map_launcher/src/maps/tomtom.dart';
import 'package:map_launcher/src/maps/waze.dart';
import 'package:map_launcher/src/maps/yandex_maps.dart';
import 'package:map_launcher/src/maps/yandex_navi.dart';

/// A map application that can show markers and directions.
///
/// Each concrete subclass represents a specific map app (Google Maps, Waze,
/// etc.) and knows how to generate URLs for markers and directions on that app.
///
/// **Tree shaking:** referencing a static const (e.g. `MapApp.google`) compiles
/// in only that map's code, strings, and icon, nothing else. Use [all] to
/// opt in to every map (at the cost of larger binaries).
///
/// Consumers can also subclass [MapApp] to add support for regional or
/// proprietary map apps not included in the plugin.
abstract class MapApp {
  /// Creates a [MapApp].
  const MapApp();

  // ---------------------------------------------------------------------------
  // Static const instances, one per supported map.
  // Referencing one compiles in exactly that map's code + metadata.
  // ---------------------------------------------------------------------------

  // Tier 1: Universal link maps (all platforms)

  /// Apple Maps.
  static const apple = AppleMaps();

  /// Google Maps.
  static const google = GoogleMaps();

  /// Waze.
  static const waze = Waze();

  /// Yandex Maps.
  static const yandexMaps = YandexMaps();

  /// 2GIS.
  static const doubleGis = DoubleGis();

  /// HERE WeGo.
  static const here = HereWeGo();

  /// Mapy.cz.
  static const mapyCz = MapyCz();

  /// Mappls (MapmyIndia).
  static const mappls = Mappls();

  // Tier 2: Mobile-only maps (URL schemes)

  /// Google Maps Go (Android only).
  static const googleGo = GoogleMapsGo();

  /// Amap / Gaode Maps.
  static const amap = Amap();

  /// Baidu Maps.
  static const baidu = BaiduMaps();

  /// Yandex Navigator.
  static const yandexNavi = YandexNavi();

  /// Citymapper.
  static const citymapper = Citymapper();

  /// Maps.me.
  static const mapswithme = MapsMe();

  /// OsmAnd.
  static const osmand = OsmAnd();

  /// OsmAnd+ (Android only).
  static const osmandplus = OsmAndPlus();

  /// Tencent / QQ Maps.
  static const tencent = TencentMaps();

  /// Petal Maps (Android only).
  static const petal = PetalMaps();

  /// TomTom Go.
  static const tomtomgo = TomTomGo();

  /// TomTom Go Fleet.
  static const tomtomgofleet = TomTomGoFleet();

  /// CoPilot.
  static const copilot = CoPilot();

  /// Sygic Truck.
  static const sygicTruck = SygicTruck();

  /// Flitsmeister (Android only).
  static const flitsmeister = Flitsmeister();

  /// Naver Map.
  static const naver = NaverMap();

  /// KakaoMap.
  static const kakao = KakaoMap();

  /// TMAP.
  static const tmap = TMap();

  /// Moovit.
  static const moovit = Moovit();

  /// Neshan.
  static const neshan = Neshan();

  /// Air Navigation Pro.
  static const airnavPro = AirNavPro();

  /// Magic Earth.
  static const magicEarth = MagicEarth();

  /// Every supported map.
  ///
  /// **Warning:** referencing this list opts out of tree shaking. All map
  /// classes, their URL strings, and their icons will ship in the binary.
  static const all = <MapApp>[
    apple,
    google,
    waze,
    yandexMaps,
    doubleGis,
    here,
    mapyCz,
    mappls,
    googleGo,
    amap,
    baidu,
    yandexNavi,
    citymapper,
    mapswithme,
    osmand,
    osmandplus,
    tencent,
    petal,
    tomtomgo,
    tomtomgofleet,
    copilot,
    sygicTruck,
    flitsmeister,
    naver,
    kakao,
    tmap,
    moovit,
    neshan,
    airnavPro,
    magicEarth,
  ];

  // ---------------------------------------------------------------------------
  // Identity & metadata
  // ---------------------------------------------------------------------------

  /// Stable identifier for this map (e.g. `'google'`, `'neshan'`).
  ///
  /// Matches the old `MapType` enum name. Safe to persist in user preferences.
  String get id;

  /// Human-readable display name (e.g. `'Google Maps'`).
  String get name;

  /// Whether this map supports universal links (HTTPS URLs) that work
  /// across all platforms, including desktop and web.
  bool get hasUniversalLink => false;

  /// Google Play Store package identifier (Android).
  ///
  /// Also used as the Android package name for intent targeting and
  /// installed-app detection.
  String? get playStoreId => null;

  /// Apple App Store numeric identifier (iOS).
  String? get appStoreId => null;

  /// iOS URL scheme for `canOpenURL` detection (e.g. `'comgooglemaps://'`).
  ///
  /// Null for maps that don't use a custom URL scheme on iOS (e.g. Apple Maps,
  /// which is always available).
  String? get iosScheme => null;

  /// App icon as PNG bytes (256×256).
  ///
  /// Use with `Image.memory(map.iconBytes)` from Flutter, no extra
  /// dependencies needed.
  Uint8List get iconBytes;

  /// Whether this map is always available on [platform] without detection.
  ///
  /// Returns `true` for Apple Maps on iOS (built-in, no `canOpenURL` needed).
  bool isAlwaysAvailable(MapPlatform platform) => false;

  /// Google Play Store URL, or `null` if not available on Android.
  String? get playStoreUrl => playStoreId != null
      ? 'https://play.google.com/store/apps/details?id=$playStoreId'
      : null;

  /// Apple App Store URL, or `null` if not available on iOS.
  String? get appStoreUrl =>
      appStoreId != null ? 'https://apps.apple.com/app/id$appStoreId' : null;

  // ---------------------------------------------------------------------------
  // URL building: universal links (HTTPS)
  // ---------------------------------------------------------------------------

  /// Builds a universal link (HTTPS) for showing a marker.
  ///
  /// Returns `null` if not supported.
  String? markerUrl(LocationCoords coords, {int? zoom});

  /// Builds a universal link (HTTPS) for showing a marker via text search.
  ///
  /// Returns `null` if not supported.
  String? markerSearchUrl(String query) => null;

  /// Builds a universal link (HTTPS) for showing directions.
  ///
  /// Returns `null` if not supported.
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  });

  /// Builds a universal link (HTTPS) for showing directions via text search.
  ///
  /// Returns `null` if not supported.
  String? directionsSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
  }) => null;

  // ---------------------------------------------------------------------------
  // URL building: native scheme URLs (mobile-only)
  // ---------------------------------------------------------------------------

  /// Builds a URL scheme link for showing a marker (mobile-only).
  ///
  /// Returns `null` if no scheme-based URL is available.
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for showing a marker via text search (mobile-only).
  ///
  /// Returns `null` if not supported.
  String? markerSchemeSearchUrl(
    String query, {
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for showing directions (mobile-only).
  ///
  /// Returns `null` if no scheme-based URL is available.
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => null;

  /// Builds a URL scheme link for directions via text search (mobile-only).
  ///
  /// Returns `null` if not supported.
  String? directionsSchemeSearchUrl(
    String query, {
    LocationCoords? origin,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => null;

  // ---------------------------------------------------------------------------
  // Capability flags
  // ---------------------------------------------------------------------------

  /// Whether this map supports markers via coordinates.
  bool get supportsMarkerCoords => true;

  /// Whether this map supports markers via text search query.
  bool get supportsMarkerSearch => false;

  /// Whether this map supports directions via coordinates.
  bool get supportsDirectionsCoords => true;

  /// Whether this map supports directions via text search query.
  bool get supportsDirectionsSearch => false;

  /// Whether this map supports waypoints in directions.
  bool get supportsWaypoints => false;

  /// Whether this map supports the given [mode] for directions.
  bool supportsTravelMode(TravelMode mode) => true;

  // ---------------------------------------------------------------------------
  // Best-URL helpers (scheme preferred on mobile, universal fallback)
  // ---------------------------------------------------------------------------

  /// Returns the best URL for a marker.
  ///
  /// When [platform] is non-null (mobile): prefers scheme (native app),
  /// falls back to universal. When `null` (web/desktop): uses universal only.
  String? bestMarkerUrl(Location location, {int? zoom, MapPlatform? platform}) {
    return switch (location) {
      LocationCoords coords => () {
        if (platform != null) {
          final scheme = markerSchemeUrl(
            coords,
            zoom: zoom,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return markerUrl(coords, zoom: zoom);
      }(),
      LocationSearch search => () {
        if (platform != null) {
          final scheme = markerSchemeSearchUrl(
            search.query,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return markerSearchUrl(search.query);
      }(),
    };
  }

  /// Returns the best URL for directions.
  ///
  /// When [platform] is non-null (mobile): prefers scheme (native app),
  /// falls back to universal. When `null` (web/desktop): uses universal only.
  String? bestDirectionsUrl({
    required Location destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    MapPlatform? platform,
  }) {
    return switch (destination) {
      LocationCoords coords => () {
        if (platform != null) {
          final scheme = directionsSchemeUrl(
            destination: coords,
            origin: origin,
            waypoints: waypoints,
            travelMode: travelMode,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return directionsUrl(
          destination: coords,
          origin: origin,
          waypoints: waypoints,
          travelMode: travelMode,
        );
      }(),
      LocationSearch search => () {
        if (platform != null) {
          final scheme = directionsSchemeSearchUrl(
            search.query,
            origin: origin,
            travelMode: travelMode,
            platform: platform,
          );
          if (scheme != null) return scheme;
        }
        return directionsSearchUrl(
          search.query,
          origin: origin,
          travelMode: travelMode,
        );
      }(),
    };
  }

  @override
  String toString() => 'MapApp($id)';
}
