import 'package:map_launcher/src/map_launcher.dart';
import 'package:map_launcher/src/utils.dart';

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
}

/// Defines the supported modes of transportation for [showDirections]
enum DirectionsMode {
  driving,
  walking,
  transit,
  bicycling,
  TWO_WHEELER
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
  static AvailableMap? fromJson(json) {
    final MapType? mapType =
        Utils.enumFromString(MapType.values, json['mapType']);
    if (mapType != null) {
      return AvailableMap(
        mapName: json['mapName'],
        mapType: mapType,
        icon: 'packages/map_launcher/assets/icons/${json['mapType']}.svg',
      );
    } else {
      return null;
    }
  }

  /// Launches current map and shows marker at `coords`
  Future<void> showMarker({
    required Coords coords,
    required String title,
    String? description,
    int? zoom,
    Map<String, String>? extraParams,
  }) {
    return MapLauncher.showMarker(
      mapType: mapType,
      coords: coords,
      title: title,
      description: description,
      zoom: zoom,
      extraParams: extraParams,
    );
  }

  /// Launches current map and shows directions to `destination`
  Future<void> showDirections({
    required Coords destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Coords>? waypoints,
    DirectionsMode directionsMode = DirectionsMode.driving,
    Map<String, String>? extraParams,
  }) {
    return MapLauncher.showDirections(
      mapType: mapType,
      destination: destination,
      destinationTitle: destinationTitle,
      origin: origin,
      originTitle: originTitle,
      waypoints: waypoints,
      directionsMode: directionsMode,
      extraParams: extraParams,
    );
  }

  @override
  String toString() {
    return 'AvailableMap { mapName: $mapName, mapType: ${Utils.enumToString(mapType)} }';
  }
}
