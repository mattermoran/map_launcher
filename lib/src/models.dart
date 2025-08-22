import 'package:map_launcher/src/map_launcher.dart';

/// Defines the map types supported by this plugin.
enum MapType {
  /// Apple Maps.
  /// Available on iOS only.
  apple,

  /// Google Maps.
  google,

  /// Google Maps Go.
  /// Available on Android only.
  googleGo,

  /// Amap (Gaode Maps).
  amap,

  /// Baidu Maps.
  baidu,

  /// Waze.
  waze,

  /// Yandex Maps.
  yandexMaps,

  /// Yandex Navi.
  yandexNavi,

  /// Citymapper.
  citymapper,

  /// Maps.me.
  mapswithme,

  /// OsmAnd.
  osmand,

  /// OsmAnd+.
  /// Available on Android only.
  osmandplus,

  /// 2GIS.
  doubleGis,

  /// Tencent (QQ Maps).
  tencent,

  /// HERE WeGo.
  here,

  /// Petal Maps.
  /// Available on Android only.
  petal,

  /// TomTom Go.
  tomtomgo,

  /// TomTom Go Fleet.
  tomtomgofleet,

  /// CoPilot.
  copilot,

  /// Sygic Truck.
  sygicTruck,

  /// Flitsmeister.
  /// Available on Android only.
  flitsmeister,

  /// Truckmeister.
  /// Available on Android only.
  truckmeister,

  /// Naver Map.
  naver,

  /// KakaoMap.
  kakao,

  /// TMAP.
  tmap,

  /// MapyCZ.
  mapyCz,

  /// MAPPLS MapmyIndia.
  mappls,

  /// Moovit.
  moovit,

  /// Neshan.
  neshan,
}

/// Defines the supported modes of transportation for [AvailableMap.showDirections].
enum DirectionsMode {
  /// Travel by car or truck.
  driving,

  /// Travel on foot.
  walking,

  /// Travel using public transit.
  transit,

  /// Travel by bicycle.
  bicycling,
}

/// Represents latitude and longitude coordinates.
class Coords {
  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// Creates a [Coords] instance with the given [latitude] and [longitude].
  Coords(this.latitude, this.longitude);

  /// Returns a string representation of the coordinates in the form
  /// `"latitude,longitude"`.
  ///
  /// Example:
  /// ```dart
  /// final coords = Coords(59.3293, 18.0686);
  /// print(coords.latlng); // "59.3293,18.0686"
  /// ```
  String get latlng => '$latitude,$longitude';

  /// Returns a string representation of the coordinates in the form
  /// `"longitude,latitude"`.
  ///
  /// Example:
  /// ```dart
  /// final coords = Coords(59.3293, 18.0686);
  /// print(coords.lnglat); // "18.0686,59.3293"
  /// ```
  String get lnglat => '$longitude,$latitude';
}

/// Represents a waypoint with coordinates and an optional title.
class Waypoint {
  /// The coordinates of this waypoint.
  final Coords coords;

  /// An optional title for this waypoint.
  final String? title;

  /// Creates a [Waypoint] with [latitude], [longitude], and an optional [title].
  Waypoint(double latitude, double longitude, [this.title])
    : coords = Coords(latitude, longitude);

  /// Latitude in decimal degrees.
  double get latitude => coords.latitude;

  /// Longitude in decimal degrees.
  double get longitude => coords.longitude;
}

/// Represents an installed map application that can be launched.
class AvailableMap {
  /// Display name of the map application.
  String mapName;

  /// The type of the map application.
  MapType mapType;

  /// Path to the map icon asset (SVG).
  ///
  /// To display this icon in your app, use the
  /// [`flutter_svg`](https://pub.dev/packages/flutter_svg) package:
  ///
  /// ```dart
  /// import 'package:flutter_svg/flutter_svg.dart';
  ///
  /// SvgPicture.asset(
  ///   map.icon,
  ///   height: 30,
  ///   width: 30,
  /// );
  /// ```
  String icon;

  /// Creates an [AvailableMap] with [mapName], [mapType], and [icon].
  AvailableMap({
    required this.mapName,
    required this.mapType,
    required this.icon,
  });

  /// Creates an [AvailableMap] instance from a JSON object.
  static AvailableMap fromJson(dynamic json) {
    final MapType mapType = MapType.values.byName(json['mapType']);
    return AvailableMap(
      mapName: json['mapName'],
      mapType: mapType,
      icon: 'packages/map_launcher/assets/icons/${json['mapType']}.svg',
    );
  }

  /// Launches this map and shows a marker at the given [coords].
  ///
  /// - [coords]: Coordinates where the marker should be placed.
  /// - [title]: Title for the marker.
  /// - [description]: Optional description for the marker.
  /// - [zoom]: Optional zoom level for the map (default is 16).
  /// - [extraParams]: Extra map-specific query parameters.
  Future<void> showMarker({
    required Coords coords,
    required String title,
    String? description,
    int zoom = 16,
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

  /// Launches this map and shows directions to the given [destination].
  ///
  /// - [destination]: Coordinates of the destination.
  /// - [destinationTitle]: Optional label for the destination.
  /// - [origin]: Optional starting point. If not provided, the map app may use the current location.
  /// - [originTitle]: Optional label for the origin.
  /// - [waypoints]: A list of intermediate waypoints along the route.
  /// - [directionsMode]: Mode of transport (defaults to [DirectionsMode.driving]).
  /// - [extraParams]: Extra map-specific query parameters.
  Future<void> showDirections({
    required Coords destination,
    String? destinationTitle,
    Coords? origin,
    String? originTitle,
    List<Waypoint>? waypoints,
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
    return 'AvailableMap { mapName: $mapName, mapType: ${mapType.name} }';
  }
}
