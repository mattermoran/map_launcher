import 'package:map_launcher/src/models.dart';

class Utils {
  /// Returns an [Enum] from [String]
  static T enumFromString<T extends Enum>(Iterable<T> values, String value) {
    return values.firstWhere((type) => type.name == value);
  }

  static String? nullOrValue(dynamic nullable, String value) {
    if (nullable == null) return null;
    return value;
  }

  /// Constructs a url from [url] and [queryParams]
  static String buildUrl({
    required String url,
    required Map<String, String?> queryParams,
  }) {
    return queryParams.entries
        .fold('$url?', (dynamic previousValue, element) {
          if (element.value == null || element.value == '') {
            return previousValue;
          }
          return '$previousValue&${element.key}=${element.value}';
        })
        .replaceFirst('&', '');
  }

  /// Returns [DirectionsMode] for [MapType.amap]
  static String getAmapDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => '0',
      DirectionsMode.transit => '1',
      DirectionsMode.walking => '2',
      DirectionsMode.bicycling => '3',
      _ => '0',
    };
  }

  /// Returns [DirectionsMode] for [MapType.baidu]
  static String getBaiduDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'driving',
      DirectionsMode.transit => 'transit',
      DirectionsMode.walking => 'walking',
      DirectionsMode.bicycling => 'riding',
      _ => 'driving',
    };
  }

  /// Returns [DirectionsMode] for [MapType.mapswithme]
  static String getMapsMeDirectionsMode(DirectionsMode directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'vehicle',
      DirectionsMode.transit => 'transit',
      DirectionsMode.walking => 'pedestrian',
      DirectionsMode.bicycling => 'bicycle',
    };
  }

  /// Returns [DirectionsMode] for [MapType.yandexMaps]
  static String getYandexMapsDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'auto',
      DirectionsMode.transit => 'mt',
      DirectionsMode.walking => 'pd',
      DirectionsMode.bicycling => 'auto',
      _ => 'auto',
    };
  }

  /// Returns [DirectionsMode] for [MapType.doubleGis]
  static String getDoubleGisDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'car',
      DirectionsMode.transit => 'bus',
      DirectionsMode.walking => 'pedestrian',
      _ => 'auto',
    };
  }

  /// Returns [DirectionsMode] for [MapType.tencent]
  static String getTencentDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'drive',
      DirectionsMode.transit => 'bus',
      DirectionsMode.walking => 'walk',
      DirectionsMode.bicycling => 'bike',
      _ => 'auto',
    };
  }

  /// Returns [DirectionsMode] for [MapType.here]
  static String getHereDirectionsMode(DirectionsMode? directionsMode) {
    return switch (directionsMode) {
      DirectionsMode.driving => 'd',
      DirectionsMode.transit => 'pt',
      DirectionsMode.walking => 'w',
      DirectionsMode.bicycling => 'b',
      _ => 'd',
    };
  }
}
