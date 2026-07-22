import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Yandex Maps — coordinates, directions with origin, waypoints, travel mode.
class YandexMapsBuilder extends MapUrlBuilder {
  /// Creates a [YandexMapsBuilder].
  const YandexMapsBuilder();

  @override
  bool get supportsWaypoints => true;

  @override
  MapType get mapType => .yandexMaps;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) => buildUrl(
    url: 'https://yandex.com/maps/',
    queryParams: {
      'pt': coords.lnglat,
      if (zoom != null) 'z': zoom.toString(),
      'l': 'map',
    },
  );

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) {
    final rtext = [
      if (origin != null) origin.latlng,
      if (waypoints != null) ...waypoints.map((w) => w.latlng),
      destination.latlng,
    ].join('~');
    return buildUrl(
      url: 'https://yandex.com/maps/',
      queryParams: {
        'rtext': rtext,
        if (travelMode != null) 'rtt': _modeStr(travelMode),
      },
    );
  }

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'yandexmaps://maps.yandex.com/',
    queryParams: {
      'pt': coords.lnglat,
      if (zoom != null) 'z': zoom.toString(),
      'l': 'map',
    },
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) {
    final rtext = [
      if (origin != null) origin.latlng,
      if (waypoints != null) ...waypoints.map((w) => w.latlng),
      destination.latlng,
    ].join('~');
    return buildUrl(
      url: 'yandexmaps://maps.yandex.com/',
      queryParams: {
        'rtext': rtext,
        if (travelMode != null) 'rtt': _modeStr(travelMode),
      },
    );
  }

  static String _modeStr(TravelMode? m) => switch (m) {
    .driving => 'auto',
    .walking => 'pd',
    .transit => 'mt',
    .bicycling => 'bc',
    null => 'auto',
  };
}
