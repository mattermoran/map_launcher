import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/amap_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Amap (Gaode Maps). Mobile only, directions with origin and travel mode.
class Amap extends MapApp {
  /// Creates a [Amap].
  const Amap();

  @override
  String get id => 'amap';

  @override
  String get name => 'Amap';

  @override
  String? get playStoreId => 'com.autonavi.minimap';

  @override
  String? get appStoreId => '461703208';

  @override
  String? get iosScheme => 'iosamap://';

  @override
  Uint8List get iconBytes => amapIcon;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => null;

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) {
    final prefix = platform == .ios ? 'ios' : 'android';
    return buildUrl(
      url: '${prefix}amap://viewMap',
      queryParams: {
        'sourceApplication': 'map_launcher',
        'poiname': coords.title ?? '',
        'lat': coords.lat.toString(),
        'lon': coords.lng.toString(),
        'dev': '0',
      },
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    final prefix = platform == .ios ? 'ios' : 'android';
    return buildUrl(
      url: '${prefix}amap://route/plan/',
      queryParams: {
        'sourceApplication': 'map_launcher',
        'dlat': destination.lat.toString(),
        'dlon': destination.lng.toString(),
        'dname': destination.title ?? '',
        if (origin != null) ...{
          'slat': origin.lat.toString(),
          'slon': origin.lng.toString(),
          'sname': origin.title ?? '',
        },
        't': switch (travelMode) {
          .driving => '0',
          .transit => '1',
          .walking => '2',
          .bicycling => '3',
          null => '0',
        },
      },
    );
  }
}
