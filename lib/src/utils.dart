import 'package:collection/collection.dart' show IterableExtension;
import 'package:map_launcher/src/models.dart';

class Utils {
  static String? enumToString(o) {
    if (o == null) return null;
    return o.toString().split('.').last;
  }

  static T? enumFromString<T>(Iterable<T> values, String? value) {
    return values.firstWhereOrNull(
      (type) => type.toString().split('.').last == value
    );
  }

  static String? nullOrValue(dynamic nullable, String value) {
    if (nullable == null) return null;
    return value;
  }

  static String buildUrl({
    required String url,
    required Map<String, String?> queryParams,
  }) {
    return queryParams.entries.fold('$url?', (dynamic previousValue, element) {
      if (element.value == null || element.value == '') {
        return previousValue;
      }
      return '$previousValue&${element.key}=${element.value}';
    }).replaceFirst('&', '');
  }

  static String getAmapDirectionsMode(DirectionsMode? directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return '0';
      case DirectionsMode.transit:
        return '1';
      case DirectionsMode.walking:
        return '2';
      case DirectionsMode.bicycling:
        return '3';
      default:
        return '0';
    }
  }

  static String getBaiduDirectionsMode(DirectionsMode? directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return 'driving';
      case DirectionsMode.transit:
        return 'transit';
      case DirectionsMode.walking:
        return 'walking';
      case DirectionsMode.bicycling:
        return 'riding';
      default:
        return 'driving';
    }
  }

  static String getMapsMeDirectionsMode(DirectionsMode directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return 'vehicle';
      case DirectionsMode.transit:
        return 'transit';
      case DirectionsMode.walking:
        return 'pedestrian';
      case DirectionsMode.bicycling:
        return 'bicycle';
      default:
        return 'vehicle';
    }
  }

  static String getYandexMapsDirectionsMode(DirectionsMode? directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return 'auto';
      case DirectionsMode.transit:
        return 'mt';
      case DirectionsMode.walking:
        return 'pd';
      case DirectionsMode.bicycling:
        return 'auto';
      default:
        return 'auto';
    }
  }

  static String getDoubleGisDirectionsMode(DirectionsMode? directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return 'car';
      case DirectionsMode.transit:
        return 'bus';
      case DirectionsMode.walking:
        return 'pedestrian';
      default:
        return 'auto';
    }
  }

  static String getTencentDirectionsMode(DirectionsMode? directionsMode) {
    switch (directionsMode) {
      case DirectionsMode.driving:
        return 'drive';
      case DirectionsMode.transit:
        return 'bus';
      case DirectionsMode.walking:
        return 'walk';
      case DirectionsMode.bicycling:
        return 'bike';
      default:
        return 'auto';
    }
  }
}
