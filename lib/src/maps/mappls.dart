import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Mappls (MapmyIndia) — coordinates, directions with travel mode.
class MapplsBuilder extends MapUrlBuilder {
  /// Creates a [MapplsBuilder].
  const MapplsBuilder();

  @override
  MapType get mapType => .mappls;

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
