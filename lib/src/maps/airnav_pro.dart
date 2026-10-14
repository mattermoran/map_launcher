import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/airnav_pro_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';

/// Air Navigation Pro. No safe passive marker launch contract is known.
class AirNavPro extends MapApp {
  /// Creates a [AirNavPro].
  const AirNavPro();

  @override
  String get id => 'airnavPro';

  @override
  String get name => 'Air Navigation Pro';

  @override
  String? get playStoreId => 'com.xample.airnavigation';

  @override
  String? get appStoreId => '301046057';

  @override
  String? get iosScheme => 'airnavpro://';

  @override
  Uint8List get iconBytes => airnavProIcon;

  @override
  bool get supportsMarkerCoords => false;

  @override
  bool get supportsDirectionsCoords => false;

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
  }) => null;

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => null;
}
