import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/copilot_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// CoPilot. Mobile only, destination only.
class CoPilot extends MapApp {
  /// Creates a [CoPilot].
  const CoPilot();

  @override
  String get id => 'copilot';

  @override
  String get name => 'CoPilot';

  @override
  String? get playStoreId => 'com.alk.copilot.mapviewer';

  @override
  String? get appStoreId => '378870891';

  @override
  String? get iosScheme => 'copilot://';

  @override
  Uint8List get iconBytes => copilotIcon;

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
    url: 'copilot://mydestination',
    queryParams: {
      'type': 'LOCATION',
      'action': 'VIEW',
      'marker': coords.latlng,
      if (coords.title != null) 'name': coords.title!,
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
    url: 'copilot://mydestination',
    queryParams: {
      'type': 'LOCATION',
      'action': 'GOTO',
      'name': destination.title ?? '',
      'lat': destination.lat.toString(),
      'long': destination.lng.toString(),
    },
  );
}
