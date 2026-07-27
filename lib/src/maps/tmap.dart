import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/tmap_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// TMap. Mobile only, directions with origin.
class TMap extends MapApp {
  /// Creates a [TMap].
  const TMap();

  @override
  String get id => 'tmap';

  @override
  String get name => 'TMap';

  @override
  String? get playStoreId => 'com.skt.tmap.ku';

  @override
  String? get appStoreId => '431589174';

  @override
  String? get iosScheme => 'tmap://';

  @override
  Uint8List get iconBytes => tmapIcon;

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
