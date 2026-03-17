import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Amap (Gaode Maps) — mobile only, directions with origin and travel mode.
class AmapBuilder extends MapUrlBuilder {
  /// Creates an [AmapBuilder].
  const AmapBuilder();

  @override
  MapType get mapType => .amap;

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
