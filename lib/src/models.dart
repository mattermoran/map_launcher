/// Defines the map types supported by this plugin
enum MapType {
  apple,
  google,
  googleGo,
  amap,
  baidu,
  waze,
  yandexMaps,
  yandexNavi,
  citymapper,
  mapswithme,
  osmand,
  osmandplus,
  doubleGis,
  tencent,
  here,
  petal,
  tomtomgo,
  copilot,
}

/// Defines the supported modes of transportation for [showDirections]
enum DirectionsMode {
  driving,
  walking,
  transit,
  bicycling,
}

/// Class that holds latitude and longitude coordinates
class Coords {
  final double latitude;
  final double longitude;

  Coords(this.latitude, this.longitude);
}

/// Class that holds all the information needed to launch a map
class AvailableMap {
  String mapName;
  MapType mapType;
  String icon;

  AvailableMap({
    required this.mapName,
    required this.mapType,
    required this.icon,
  });

  /// Parses json object to [AvailableMap]
  static AvailableMap fromJson(json) {
    final mapType = MapType.values.firstWhere(
      (mapType) => mapType.name == json['mapType'],
    );
    return AvailableMap(
      mapName: json['mapName'],
      mapType: mapType,
      icon: 'packages/map_launcher/assets/icons/${json['mapType']}.svg',
    );
  }

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapType: ${mapType.name} }';
  }
}

class MapMarkerParams {
  MapMarkerParams({
    required this.mapType,
    required this.coords,
    required this.title,
    this.description,
    this.zoom = 16,
    this.extraParams = const {},
  });

  final MapType mapType;
  final Coords coords;
  final String title;
  final String? description;
  final int zoom;
  final Map<String, String> extraParams;
}

class MapDirectionsParams {
  MapDirectionsParams({
    required this.mapType,
    required this.destination,
    this.destinationTitle,
    this.origin,
    this.originTitle,
    this.waypoints,
    this.directionsMode,
    this.extraParams = const {},
  });

  final MapType mapType;
  final Coords destination;
  final String? destinationTitle;
  final Coords? origin;
  final String? originTitle;
  final List<Coords>? waypoints;
  final DirectionsMode? directionsMode;
  final Map<String, String> extraParams;
}
