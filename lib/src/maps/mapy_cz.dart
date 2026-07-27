import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/mapy_cz_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Mapy.cz. Coordinates only, destination only.
class MapyCz extends MapApp {
  /// Creates a [MapyCz].
  const MapyCz();

  @override
  String get id => 'mapyCz';

  @override
  String get name => 'Mapy.cz';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'cz.seznam.mapy';

  @override
  String? get appStoreId => '411411020';

  @override
  String? get iosScheme => 'szn-mapy://';

  @override
  Uint8List get iconBytes => mapyCzIcon;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) => buildUrl(
    url: 'https://mapy.cz/zakladni',
    queryParams: {
      'id': coords.lnglat,
      if (zoom != null) 'z': zoom.toString(),
      'source': 'coor',
    },
  );

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => buildUrl(
    url: 'https://mapy.cz/zakladni',
    queryParams: {'id': destination.lnglat, 'source': 'rout'},
  );
}
