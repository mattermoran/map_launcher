/// Defines the map types supported by this plugin
enum MapType {
  /// Apple Maps
  /// Only available on iOS
  apple,

  /// Google Maps
  google,

  /// Google Maps Go
  /// Only available on Android
  googleGo,

  /// Amap (Gaode Maps)
  amap,

  /// Baidu Maps
  baidu,

  /// Waze
  waze,

  /// Yandex Maps
  yandexMaps,

  /// Yandex Navi
  yandexNavi,

  /// Citymapper
  citymapper,

  /// Maps.me
  mapswithme,

  /// OsmAnd
  osmand,

  /// OsmAnd+
  /// Only available on Android
  osmandplus,

  /// DoubleGis
  doubleGis,

  /// Tencent (QQ Maps)
  tencent,

  /// HERE WeGo
  here,

  /// Petal Maps
  /// Only available on Android
  petal,

  /// TomTom Go
  tomtomgo,

  /// TomTom Go Fleet
  tomtomgofleet,

  /// CoPilot
  copilot,

  /// Sygic Truck
  sygicTruck,

  /// Flitsmeister
  /// Only available on Android
  flitsmeister,

  /// Truckmeister
  /// Only available on Android
  truckmeister,

  /// Naver Map
  naver,

  /// KakaoMap
  kakao,

  /// TMAP
  tmap,

  /// MapyCZ
  mapyCz,
}

/// Defines the supported modes of transportation for [showDirections]
enum DirectionsMode {
  /// Driving
  driving,

  /// Walking
  walking,

  /// Transit
  transit,

  /// Bicycling
  bicycling,
}

class Location {
  Location.coords({
    required this.latitude,
    required this.longitude,
    this.title,
    this.description,
  }) : searchQuery = null;

  Location.searchQuery({
    required this.searchQuery,
    this.title,
    this.description,
  })  : latitude = null,
        longitude = null;

  final double? latitude;
  final double? longitude;
  final String? searchQuery;
  final String? title;
  final String? description;
}

/// Class that holds all the information needed to launch a map
class AvailableMap {
  /// Converts a JSON object to an [AvailableMap]
  AvailableMap.fromJson(Map<String, dynamic> json)
      : mapName = json['mapName'] as String,
        mapType = MapType.values.firstWhere(
          (type) => type.name == json['mapType'],
        ),
        icon = 'packages/map_launcher/assets/icons/${json['mapType']}.svg';

  /// Name of the map
  String mapName;

  /// Type of the map
  MapType mapType;

  /// Icon of the map
  String icon;

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapType: ${mapType.name} }';
  }
}
