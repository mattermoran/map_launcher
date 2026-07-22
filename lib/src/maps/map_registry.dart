import 'dart:collection';

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
import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/maps/mappls.dart';
import 'package:map_launcher/src/maps/mapswithme.dart';
import 'package:map_launcher/src/maps/mapy_cz.dart';
import 'package:map_launcher/src/maps/moovit.dart';
import 'package:map_launcher/src/maps/naver.dart';
import 'package:map_launcher/src/maps/neshan.dart';
import 'package:map_launcher/src/maps/osmand.dart';
import 'package:map_launcher/src/maps/petal.dart';
import 'package:map_launcher/src/maps/spedion_navigation.dart';
import 'package:map_launcher/src/maps/sygic_truck.dart';
import 'package:map_launcher/src/maps/tencent.dart';
import 'package:map_launcher/src/maps/tmap.dart';
import 'package:map_launcher/src/maps/tomtom.dart';
import 'package:map_launcher/src/maps/truckmeister.dart';
import 'package:map_launcher/src/maps/waze.dart';
import 'package:map_launcher/src/maps/yandex_maps.dart';
import 'package:map_launcher/src/maps/yandex_navi.dart';
import 'package:map_launcher/src/models/map_type.dart';

/// Registry of all known map URL builders.
class MapRegistry {
  MapRegistry._();

  static final Map<MapType, MapUrlBuilder> _builders = {
    // Tier 1: Universal link maps
    .apple: const AppleMapsBuilder(),
    .google: const GoogleMapsBuilder(),
    .waze: const WazeBuilder(),
    .yandexMaps: const YandexMapsBuilder(),
    .doubleGis: const DoubleGisBuilder(),
    .here: const HereWeGoBuilder(),
    .mapyCz: const MapyCzBuilder(),
    .mappls: const MapplsBuilder(),

    // Tier 2: Mobile-only maps
    .googleGo: const GoogleMapsGoBuilder(),
    .amap: const AmapBuilder(),
    .baidu: const BaiduMapsBuilder(),
    .yandexNavi: const YandexNaviBuilder(),
    .citymapper: const CitymapperBuilder(),
    .mapswithme: const MapsMeBuilder(),
    .osmand: const OsmAndBuilder(),
    .osmandplus: const OsmAndPlusBuilder(),
    .tencent: const TencentMapsBuilder(),
    .petal: const PetalMapsBuilder(),
    .tomtomgo: const TomTomGoBuilder(),
    .tomtomgofleet: const TomTomGoFleetBuilder(),
    .copilot: const CoPilotBuilder(),
    .sygicTruck: const SygicTruckBuilder(),
    .flitsmeister: const FlitsmeisterBuilder(),
    .truckmeister: const TruckmeisterBuilder(),
    .naver: const NaverMapBuilder(),
    .kakao: const KakaoMapBuilder(),
    .tmap: const TMapBuilder(),
    .moovit: const MoovitBuilder(),
    .neshan: const NeshanBuilder(),
    .airnavPro: const AirNavProBuilder(),
    .spedionNavigation: const SpedionNavigationBuilder(),
    .magicEarth: const MagicEarthBuilder(),
  };

  /// Returns the [MapUrlBuilder] for the given [map].
  static MapUrlBuilder? getBuilder(MapType map) => _builders[map];

  /// All map types with a registered builder.
  static final List<MapType> supportedMaps = UnmodifiableListView(
    _builders.keys,
  );

  /// Map types with universal link support.
  static final List<MapType> universalLinkMaps = UnmodifiableListView(
    _builders.keys.where((t) => t.hasUniversalLink),
  );
}
