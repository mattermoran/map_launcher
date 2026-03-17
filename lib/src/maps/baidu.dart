import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Baidu Maps — mobile only, directions with origin and travel mode.
class BaiduMapsBuilder extends MapUrlBuilder {
  /// Creates a [BaiduMapsBuilder].
  const BaiduMapsBuilder();

  @override
  MapType get mapType => .baidu;

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
    url: 'baidumap://map/marker',
    queryParams: {
      'location': coords.latlng,
      'title': coords.title ?? '',
      'traffic': 'on',
      'src': 'com.map_launcher',
      'coord_type': 'gcj02',
      if (zoom != null) 'zoom': zoom.toString(),
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
    url: 'baidumap://map/direction',
    queryParams: {
      'destination':
          'latlng:${destination.latlng}|name:${Uri.encodeComponent(destination.title ?? '')}',
      if (origin != null)
        'origin':
            'latlng:${origin.latlng}|name:${Uri.encodeComponent(origin.title ?? '')}',
      'coord_type': 'gcj02',
      'src': 'com.map_launcher',
      'mode': switch (travelMode) {
        .driving => 'driving',
        .walking => 'walking',
        .transit => 'transit',
        .bicycling => 'riding',
        null => 'driving',
      },
    },
  );
}
