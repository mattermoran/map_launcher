import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/tencent_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

import 'package:map_launcher/src/utils/url_builder.dart';

/// Tencent (QQ Maps). Mobile only, directions with origin and travel mode.
class TencentMaps extends MapApp {
  /// Creates a [TencentMaps].
  const TencentMaps();

  @override
  String get id => 'tencent';

  @override
  String get name => 'Tencent (QQ Maps)';

  @override
  String? get playStoreId => 'com.tencent.map';

  @override
  String? get appStoreId => '481623196';

  @override
  String? get iosScheme => 'qqmap://';

  @override
  Uint8List get iconBytes => tencentIcon;

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
