import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// Tencent (QQ Maps) — mobile only, directions with origin and travel mode.
class TencentMapsBuilder extends MapUrlBuilder {
  /// Creates a [TencentMapsBuilder].
  const TencentMapsBuilder();

  @override
  MapType get mapType => .tencent;

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
    final t = coords.title != null ? ';title:${coords.title}' : '';
    return buildUrl(
      url: 'qqmap://map/marker',
      queryParams: {'marker': 'coord:${coords.latlng}$t'},
    );
  }

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'qqmap://map/routeplan',
    queryParams: {
      if (origin != null) ...{
        if (origin.title != null) 'from': origin.title!,
        'fromcoord': origin.latlng,
      },
      if (destination.title != null) 'to': destination.title!,
      'tocoord': destination.latlng,
      'type': switch (travelMode) {
        .driving => 'drive',
        .walking => 'walk',
        .transit => 'bus',
        .bicycling => 'bike',
        null => 'drive',
      },
    },
  );
}
