import 'package:flutter/material.dart';
import 'package:map_launcher/src/models.dart';

class Utils {
  static String enumToString(o) {
    if (o == null) return null;
    return o.toString().split('.').last;
  }

  static T enumFromString<T>(Iterable<T> values, String value) {
    return values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => null,
    );
  }

  static String nullOrValue(dynamic nullable, String value) {
    if (nullable == null) return null;
    return value;
  }

  static String buildUrl({
    @required String url,
    @required Map<String, String> queryParams,
  }) {
    return queryParams.entries.fold('$url?', (previousValue, element) {
      if (element.value == null || element.value == '') {
        return previousValue;
      }
      return '$previousValue&${element.key}=${element.value}';
    }).replaceFirst('&', '');
  }

  static String getAmapDirectionsMode(DirectionsMode directionsMode) {
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

  static String getBaiduDirectionsMode(DirectionsMode directionsMode) {
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
}
