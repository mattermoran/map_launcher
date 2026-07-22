import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

/// 2GIS — coordinates, directions with origin and travel mode.
class DoubleGisBuilder extends MapUrlBuilder {
  /// Creates a [DoubleGisBuilder].
  const DoubleGisBuilder();

  @override
  MapType get mapType => .doubleGis;

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
