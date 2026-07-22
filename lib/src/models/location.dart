/// Represents a location that can be either coordinates or a text search query.
///
/// Use with Dart 3.6+ shorthand syntax for ergonomic construction:
/// ```dart
/// MapLauncher.marker(.coords(48.85, 2.29, title: 'Eiffel Tower'))
/// MapLauncher.marker(.search('Coffee shops near me'))
/// ```
sealed class Location {
  const Location();

  /// Creates a coordinate-based location with `lat`, `lng`, and optional `title`.
  static const coords = LocationCoords.new;

  /// Creates a search-based location from a `query` string.
  static const search = LocationSearch.new;
}

/// A coordinate-based location with latitude, longitude, and optional title.
final class LocationCoords extends Location {
  /// Creates a [LocationCoords] with [lat], [lng], and optional [title].
  ///
  /// Throws [ArgumentError] if [lat] is not in range `[-90, 90]`
  /// or [lng] is not in range `[-180, 180]`.
  LocationCoords(this.lat, this.lng, {this.title}) {
    if (lat < -90 || lat > 90) {
      throw ArgumentError.value(lat, 'lat', 'Must be between -90 and 90');
    }
    if (lng < -180 || lng > 180) {
      throw ArgumentError.value(lng, 'lng', 'Must be between -180 and 180');
    }
  }

  /// Latitude in decimal degrees (-90 to 90).
  final double lat;

  /// Longitude in decimal degrees (-180 to 180).
  final double lng;

  /// Optional title for this location (displayed as marker label).
  final String? title;

  /// The coordinates in 'lat,lng' format (e.g. `48.85,2.29`).
  String get latlng => '$lat,$lng';

  /// The coordinates in 'lng,lat' format (e.g. `2.29,48.85`).
  String get lnglat => '$lng,$lat';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationCoords &&
          lat == other.lat &&
          lng == other.lng &&
          title == other.title;

  @override
  int get hashCode => Object.hash(lat, lng, title);

  @override
  String toString() =>
      'LocationCoords($lat, $lng${title != null ? ', title: $title' : ''})';
}

/// A text search-based location (e.g., "Coffee shops near me").
final class LocationSearch extends Location {
  /// Creates a [LocationSearch] with the given [query].
  ///
  /// Throws [ArgumentError] if [query] is empty.
  LocationSearch(this.query) {
    if (query.isEmpty) {
      throw ArgumentError.value(query, 'query', 'Must not be empty');
    }
  }

  /// The search query string.
  final String query;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocationSearch && query == other.query;

  @override
  int get hashCode => query.hashCode;

  @override
  String toString() => 'LocationSearch($query)';
}
