import 'package:map_launcher/src/maps/map_url_builder.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// Mapy.cz — coordinates only, destination only.
class MapyCzBuilder extends MapUrlBuilder {
  /// Creates a [MapyCzBuilder].
  const MapyCzBuilder();

  @override
  MapType get mapType => .mapyCz;

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
