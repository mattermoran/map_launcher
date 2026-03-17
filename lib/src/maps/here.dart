import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// HERE WeGo — coordinates, directions with origin and travel mode.
class HereWeGoBuilder extends MapUrlBuilder {
  /// Creates a [HereWeGoBuilder].
  const HereWeGoBuilder();

  @override
  MapType get mapType => .here;

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
