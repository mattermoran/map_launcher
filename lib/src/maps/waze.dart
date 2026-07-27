import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/waze_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Waze. Navigation only, coordinates, single destination.
class Waze extends MapApp {
  /// Creates a [Waze].
  const Waze();

  @override
  String get id => 'waze';

  @override
  String get name => 'Waze';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.waze';

  @override
  String? get appStoreId => '323229106';

  @override
  String? get iosScheme => 'waze://';

  @override
  Uint8List get iconBytes => wazeIcon;

  @override
  bool get supportsMarkerCoords => false;

  @override
  bool supportsTravelMode(TravelMode mode) => mode == .driving;
  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => buildUrl(
    url: 'https://waze.com/ul',
    queryParams: {'ll': destination.latlng, 'navigate': 'yes'},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'waze://',
    queryParams: {'ll': destination.latlng, 'navigate': 'yes'},
  );
}
