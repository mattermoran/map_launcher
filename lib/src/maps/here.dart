import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/here_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// HERE WeGo. Supports coordinates, directions with origin and travel mode.
class HereWeGo extends MapApp {
  /// Creates a [HereWeGo].
  const HereWeGo();

  @override
  String get id => 'here';

  @override
  String get name => 'HERE WeGo';

  @override
  bool get hasUniversalLink => true;

  @override
  String? get playStoreId => 'com.here.app.maps';

  @override
  String? get appStoreId => '955837609';

  @override
  String? get iosScheme => 'here-location://';

  @override
  Uint8List get iconBytes => hereIcon;

  @override
  String markerUrl(LocationCoords coords, {int? zoom}) {
    final title = coords.title != null
        ? ',${Uri.encodeComponent(coords.title!)}'
        : '';
    return buildUrl(
      url: 'https://share.here.com/l/${coords.latlng}$title',
      queryParams: {if (zoom != null) 'z': zoom.toString()},
    );
  }

  @override
  String directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) {
    final originPart = origin != null
        ? '${origin.latlng},${Uri.encodeComponent(origin.title ?? '')}/'
        : '';
    return buildUrl(
      url: 'https://share.here.com/r/$originPart${destination.latlng}',
      queryParams: {
        if (travelMode != null)
          'm': switch (travelMode) {
            .driving => 'd',
            .walking => 'w',
            .transit => 'pt',
            .bicycling => 'b',
          },
      },
    );
  }
}
