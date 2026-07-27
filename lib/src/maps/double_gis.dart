import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/double_gis_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

/// 2GIS. Supports coordinates, directions with origin and travel mode.
class DoubleGis extends MapApp {
  /// Creates a [DoubleGis].
  const DoubleGis();

  @override
  String get id => 'doubleGis';

  @override
  String get name => '2GIS';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'ru.dublgis.dgismobile';

  @override
  String? get appStoreId => '481627348';

  @override
  String? get iosScheme => 'dgis://';

  @override
  Uint8List get iconBytes => doubleGisIcon;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) =>
      'https://2gis.ru/geo/${coords.lnglat}';

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) {
    final mode = _modeStr(travelMode);
    return [
      'https://2gis.ru/routeSearch/rsType/$mode',
      if (origin != null) 'from/${origin.lnglat}',
      'to/${destination.lnglat}',
    ].join('/');
  }

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => 'dgis://2gis.ru/geo/${coords.lnglat}';

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    final mode = _modeStr(travelMode);
    return [
      'dgis://2gis.ru/routeSearch/rsType/$mode',
      if (origin != null) 'from/${origin.lnglat}',
      'to/${destination.lnglat}',
    ].join('/');
  }

  static String _modeStr(TravelMode? m) => switch (m) {
    .driving => 'car',
    .walking => 'pedestrian',
    .transit => 'bus',
    .bicycling => 'bicycle',
    null => 'car',
  };
}
