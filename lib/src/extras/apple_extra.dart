import 'dart:collection';

import 'package:map_launcher/src/models/location.dart';

/// Display mode for Apple Maps.
enum AppleMapDisplay {
  /// Standard map view.
  standard,

  /// Satellite imagery.
  satellite,

  /// Satellite with roads overlay.
  hybrid,

  /// Transit lines and stations.
  transit,
}

/// Apple Maps-specific URL parameters.
///
/// Use with the `extra` parameter on any request:
/// ```dart
/// MapLauncher.marker(.coords(48.85, 2.29)).show(
///   map: .apple,
///   extra: AppleExtra(display: AppleMapDisplay.satellite),
/// );
/// ```
class AppleExtra extends MapView<String, String> {
  /// Creates Apple Maps extra parameters.
  ///
  /// - [display]: Map display mode (standard, satellite, hybrid, transit).
  /// - [near]: Location hint to bias search results.
  AppleExtra({AppleMapDisplay? display, LocationCoords? near})
    : super({
        if (display != null)
          't': switch (display) {
            .standard => 'm',
            .satellite => 'k',
            .hybrid => 'h',
            .transit => 'r',
          },
        if (near != null) 'near': near.latlng,
      });
}
