/// Map Launcher — open maps on all Flutter platforms.
///
/// Uses universal links (HTTPS URLs), with native app detection
/// on mobile.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:map_launcher/map_launcher.dart';
///
/// // Show a marker
/// await MapLauncher.marker(.coords(48.85, 2.29, title: 'Eiffel Tower')).show();
///
/// // Show directions
/// await MapLauncher.directions(.coords(48.85, 2.29), mode: .walking).show();
///
/// // Search
/// await MapLauncher.marker(.search('Coffee shops near me')).show();
///
/// // Specific app with extras
/// await MapLauncher.marker(.coords(48.85, 2.29)).show(
///   map: .google,
///   extra: GoogleExtra(queryPlaceId: 'ChIJLU7j...'),
/// );
///
/// // Discover available maps
/// final maps = await MapLauncher.marker(.coords(48.85, 2.29)).getSupportedMaps();
/// ```
library;

export 'src/map_launcher.dart';
export 'src/models/location.dart';
export 'src/models/map_platform.dart';
export 'src/models/map_type.dart';
export 'src/models/supported_map.dart';
export 'src/models/travel_mode.dart';
export 'src/models/map_launch_exception.dart';
export 'src/requests/directions_request.dart';
export 'src/requests/marker_request.dart';

// Extras — map-specific parameter helpers
export 'src/extras/apple_extra.dart';
export 'src/extras/google_extra.dart';
export 'src/extras/tencent_extra.dart';
export 'src/extras/waze_extra.dart';
export 'src/extras/yandex_navi_extra.dart';

// Flutter's generated plugin registrant imports from this barrel file
// (it ignores the fileName field in pubspec.yaml for dartPluginClass).
// Conditional export: on native platforms, export the real desktop class;
// on web, export an empty stub so dart:io stays out of the import chain.
export 'map_launcher_desktop_stub.dart'
    if (dart.library.io) 'map_launcher_desktop.dart';

