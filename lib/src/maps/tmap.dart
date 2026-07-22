import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// TMap — mobile only, directions with origin.
class TMapBuilder extends MapUrlBuilder {
  /// Creates a [TMapBuilder].
  const TMapBuilder();

  @override
  MapType get mapType => .tmap;

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
    url: 'tmap://viewmap',
    queryParams: {
      if (coords.title != null) 'name': coords.title!,
      'x': coords.lng.toString(),
      'y': coords.lat.toString(),
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
    url: 'tmap://route',
    queryParams: {
      if (origin != null) ...{
        if (origin.title != null) 'startname': origin.title!,
        'startx': origin.lng.toString(),
        'starty': origin.lat.toString(),
      },
      if (destination.title != null) 'goalname': destination.title!,
      'goaly': destination.lat.toString(),
      'goalx': destination.lng.toString(),
      'carType': '1',
    },
  );
}
