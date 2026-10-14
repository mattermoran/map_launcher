import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/models/map_launch_exception.dart';
import 'package:map_launcher/src/models/supported_map.dart';

import 'package:map_launcher/map_launcher_platform_interface.dart';

/// Appends [extraParams] to [url] as query parameters.
///
/// Uses [Uri] for proper encoding, then appends to the URL as a string.
/// Works uniformly for all URL types (HTTP, custom schemes, geo:, etc.).
/// Correctly handles URLs with fragments (#) by inserting params before them.
/// Returns [url] unchanged if [extraParams] is null or empty.
/// Identical existing parameters are kept once. Conflicting extras throw
/// [ArgumentError] instead of creating an ambiguous duplicate key.
/// Existing bytes are never re-encoded (important for signed URLs).
String appendQueryParams(String url, Map<String, String>? extraParams) {
  if (extraParams == null || extraParams.isEmpty) return url;

  // Separate fragment if present. Params must go before it.
  final fragmentIndex = url.indexOf('#');
  final baseUrl = fragmentIndex >= 0 ? url.substring(0, fragmentIndex) : url;
  final fragment = fragmentIndex >= 0 ? url.substring(fragmentIndex) : '';

  // Google's navigation intent puts its parameters directly after the colon.
  final opaqueNavigation =
      baseUrl.startsWith('google.navigation:') && !baseUrl.contains('?');
  final queryIndex = opaqueNavigation
      ? baseUrl.indexOf(':')
      : baseUrl.indexOf('?');
  final additions = Map<String, String>.of(extraParams);
  if (queryIndex >= 0) {
    final query = baseUrl.substring(queryIndex + 1);
    final existing = Uri(query: query).queryParametersAll;
    for (final entry in extraParams.entries) {
      final values = existing[entry.key];
      if (values != null) {
        if (values.length != 1 || values.single != entry.value) {
          throw ArgumentError(
            'Extra parameter "${entry.key}" conflicts with a URL parameter.',
          );
        }
        additions.remove(entry.key);
      }
    }
  }
  if (additions.isEmpty) return url;

  // Use Uri to get properly encoded query string.
  final queryString = Uri(queryParameters: additions).query;
  final separator = queryIndex >= 0 ? '&' : '?';
  return '$baseUrl$separator$queryString$fragment';
}

/// Launches a map, retrying its universal URL without an Android package target.
/// All platform launch failures are exposed as [MapLaunchException].
Future<void> launchMapUrl({
  required MapApp map,
  required String url,
  required String? universalUrl,
  Map<String, String>? extra,
}) async {
  final platform = MapLauncherPlatform.instance;
  final packageName = platform.platform == .android ? map.playStoreId : null;
  final useUniversal = map.requiresUniversalUrl(extra ?? const {});
  if (useUniversal && universalUrl == null) {
    throw UnsupportedError(
      '${map.name} requires a universal URL for these extras.',
    );
  }
  final primaryUrl = appendQueryParams(
    useUniversal ? universalUrl! : url,
    extra,
  );
  map.validateLaunchUrl(primaryUrl);
  // Validate fallback configuration before any external side effect.
  final fallbackUrl = universalUrl == null
      ? null
      : appendQueryParams(universalUrl, extra);
  if (fallbackUrl != null) map.validateLaunchUrl(fallbackUrl);
  try {
    await platform.launch(primaryUrl, androidPackageName: packageName);
  } on Exception catch (error) {
    if (fallbackUrl != null &&
        (fallbackUrl != primaryUrl || packageName != null)) {
      try {
        await platform.launch(fallbackUrl);
        return;
      } on Exception catch (fallbackError) {
        throw MapLaunchException(
          'Failed to launch ${map.name}',
          url: fallbackUrl,
          cause: fallbackError,
        );
      }
    }
    throw MapLaunchException(
      'Failed to launch ${map.name}',
      url: primaryUrl,
      cause: error,
    );
  }
}

/// Only Apple + Google are unconditionally compiled into every app. They are
/// deliberate: globally safe brands, tiny, and they keep the one-liner
/// `MapLauncher.marker(...).show()` working with zero configuration.
const _defaultMaps = <MapApp>[.apple, .google];

/// Resolves the best map from a list of supported maps.
/// Prefers platform default (Apple on iOS, Google elsewhere),
/// then installed maps, then any available.
Future<MapApp?> resolveBestMap(
  Future<List<SupportedMap>> Function() getSupportedMaps,
) async {
  final maps = await getSupportedMaps();
  if (maps.isEmpty) return null;

  final platform = MapLauncherPlatform.instance.platform;
  final MapApp defaultMap = platform == .ios ? .apple : .google;
  final defaultMatch = maps.where((m) => m.map.id == defaultMap.id).firstOrNull;
  if (defaultMatch != null) return defaultMatch.map;

  final installed = maps.where((m) => m.isInstalled).firstOrNull;
  if (installed != null) return installed.map;

  return maps.first.map;
}

/// Returns the list of default maps used by bare `show()` calls.
List<MapApp> get defaultMaps => _defaultMaps;
