/// Map Launcher. Opens maps on all Flutter platforms.
///
/// Uses universal links (HTTPS URLs), with native app detection
/// on mobile.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:map_launcher/map_launcher.dart';
///
/// // Show a marker (uses Apple Maps on iOS, Google Maps elsewhere)
/// await MapLauncher.marker(.coords(48.85, 2.29, title: 'Eiffel Tower')).show();
///
/// // Show directions
/// await MapLauncher.directions(.coords(48.85, 2.29), mode: .walking).show();
///
/// // Specific app with extras
/// await MapLauncher.marker(.coords(48.85, 2.29)).show(
///   map: .google,
///   extra: GoogleExtra(queryPlaceId: 'ChIJLU7j...'),
/// );
///
/// // Discover available maps
/// final maps = await MapLauncher.marker(.coords(48.85, 2.29))
///     .getSupportedMaps([.apple, .google, .waze]);
/// ```
library;

// Core
export 'src/map_launcher.dart';
export 'src/maps/map_app.dart';
export 'src/models/location.dart';
export 'src/models/map_platform.dart';
export 'src/models/supported_map.dart';
export 'src/models/travel_mode.dart';
export 'src/models/map_launch_exception.dart';
export 'src/requests/directions_request.dart';
export 'src/requests/marker_request.dart';

// Concrete map classes, for typed matching, `is` checks, and switch patterns.
export 'src/maps/airnav_pro.dart';
export 'src/maps/amap.dart';
export 'src/maps/apple_maps.dart';
export 'src/maps/baidu.dart';
export 'src/maps/citymapper.dart';
export 'src/maps/copilot.dart';
export 'src/maps/double_gis.dart';
export 'src/maps/flitsmeister.dart';
export 'src/maps/google_go.dart';
export 'src/maps/google_maps.dart';
export 'src/maps/here.dart';
export 'src/maps/kakao.dart';
export 'src/maps/magic_earth.dart';
export 'src/maps/mappls.dart';
export 'src/maps/mapswithme.dart';
export 'src/maps/mapy_cz.dart';
export 'src/maps/moovit.dart';
export 'src/maps/naver.dart';
export 'src/maps/neshan.dart';
export 'src/maps/osmand.dart';
export 'src/maps/petal.dart';
export 'src/maps/sygic_truck.dart';
export 'src/maps/tencent.dart';
export 'src/maps/tmap.dart';
export 'src/maps/tomtom.dart';
export 'src/maps/waze.dart';
export 'src/maps/yandex_maps.dart';
export 'src/maps/yandex_navi.dart';

// Extras (map-specific parameter helpers)
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
