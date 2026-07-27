import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/mappls_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Mappls (MapmyIndia). Supports coordinates, directions with travel mode.
class Mappls extends MapApp {
  /// Creates a [Mappls].
  const Mappls();

  @override
  String get id => 'mappls';

  @override
  String get name => 'Mappls';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.mmi.maps';

  @override
  String? get appStoreId => '370210646';

  @override
  String? get iosScheme => 'mappls://';

  @override
  Uint8List get iconBytes => mapplsIcon;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) =>
      'https://www.mappls.com/location/${coords.latlng}';

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) {
    final label = destination.title != null
        ? ',${Uri.encodeComponent(destination.title!)}'
        : '';
    return buildUrl(
      url: 'https://mappls.com/navigation',
      queryParams: {
        'places': '${destination.latlng}$label',
        if (travelMode != null)
          'mode': switch (travelMode) {
            .driving => 'driving',
            .walking => 'walking',
            .transit => 'transit',
            .bicycling => 'biking',
          },
      },
    );
  }
}
