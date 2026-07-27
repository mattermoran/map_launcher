import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/sygic_truck_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Sygic Truck. Mobile only, destination only, pipe-separated URL.
class SygicTruck extends MapApp {
  /// Creates a [SygicTruck].
  const SygicTruck();

  @override
  String get id => 'sygicTruck';

  @override
  String get name => 'Sygic Truck';

  @override
  String? get playStoreId => 'com.sygic.truck';

  @override
  String? get appStoreId => '1005447813';

  @override
  String? get iosScheme => 'com.sygic.aura://';

  @override
  Uint8List get iconBytes => sygicTruckIcon;

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
    url: [
      'com.sygic.aura://coordinate',
      coords.lng,
      coords.lat,
      'show',
    ].join('|'),
    queryParams: {},
  );

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: [
      'com.sygic.aura://coordinate',
      destination.lng,
      destination.lat,
      'drive',
    ].join('|'),
    queryParams: {},
  );
}
