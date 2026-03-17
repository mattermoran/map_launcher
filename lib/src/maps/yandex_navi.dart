import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Yandex Navigator — mobile only, directions with origin and waypoints.
class YandexNaviBuilder extends MapUrlBuilder {
  /// Creates a [YandexNaviBuilder].
  const YandexNaviBuilder();

  @override
  bool get supportsWaypoints => true;

  @override
  MapType get mapType => .yandexNavi;

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
  }) => buildUrl(
    url: 'yandexnavi://show_point_on_map',
    queryParams: {
      'lat': coords.lat.toString(),
      'lon': coords.lng.toString(),
      if (zoom != null) 'zoom': zoom.toString(),
      'no-balloon': '0',
      if (coords.title != null) 'desc': coords.title!,
    },
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'yandexnavi://build_route_on_map',
    queryParams: {
      'lat_to': destination.lat.toString(),
      'lon_to': destination.lng.toString(),
      if (origin != null) ...{
        'lat_from': origin.lat.toString(),
        'lon_from': origin.lng.toString(),
      },
      if (waypoints != null)
        for (var i = 0; i < waypoints.length; i++) ...{
          'lat_via_$i': waypoints[i].lat.toString(),
          'lon_via_$i': waypoints[i].lng.toString(),
        },
    },
  );
}
