import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/moovit_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Moovit. Mobile only, directions with origin.
class Moovit extends MapApp {
  /// Creates a [Moovit].
  const Moovit();

  @override
  String get id => 'moovit';

  @override
  String get name => 'Moovit';

  @override
  String? get playStoreId => 'com.tranzmate';

  @override
  String? get appStoreId => '498477945';

  @override
  String? get iosScheme => 'moovit://';

  @override
  Uint8List get iconBytes => moovitIcon;

  @override
  bool get supportsMarkerCoords => false;

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
    url: 'moovit://nearby',
    queryParams: {'lat': coords.lat.toString(), 'lon': coords.lng.toString()},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'moovit://directions',
    queryParams: {
      'dest_lat': destination.lat.toString(),
      'dest_lon': destination.lng.toString(),
      if (destination.title != null) 'dest_name': destination.title!,
      if (origin != null) ...{
        'orig_lat': origin.lat.toString(),
        'orig_lon': origin.lng.toString(),
        if (origin.title != null) 'orig_name': origin.title!,
      },
    },
  );
}
