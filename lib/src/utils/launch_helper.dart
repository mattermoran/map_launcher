import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher/src/models/map_type.dart';
import 'package:map_launcher/src/models/supported_map.dart';

/// Appends [extraParams] to [url] as query parameters.
///
/// Uses [Uri] for proper encoding, then appends to the URL as a string.
/// Works uniformly for all URL types (HTTP, custom schemes, geo:, etc.).
/// Correctly handles URLs with fragments (#) by inserting params before them.
/// Returns [url] unchanged if [extraParams] is null or empty.
String appendQueryParams(String url, Map<String, String>? extraParams) {
  if (extraParams == null || extraParams.isEmpty) return url;

  // Separate fragment if present — params must go before it.
  final fragmentIndex = url.indexOf('#');
  final baseUrl = fragmentIndex >= 0 ? url.substring(0, fragmentIndex) : url;
  final fragment = fragmentIndex >= 0 ? url.substring(fragmentIndex) : '';

  // Use Uri to get properly encoded query string.
  final queryString = Uri(queryParameters: extraParams).query;
  final separator = baseUrl.contains('?') ? '&' : '?';
  return '$baseUrl$separator$queryString$fragment';
}

/// Resolves the best map from a list of supported maps.
/// Prefers platform default (Apple on iOS, Google elsewhere),
/// then installed maps, then any available.
Future<MapType?> resolveBestMap(
  Future<List<SupportedMap>> Function() getSupportedMaps,
) async {
  final maps = await getSupportedMaps();
  if (maps.isEmpty) return null;

  final platform = MapLauncherPlatform.instance.platform;
  final MapType defaultMap = platform == .ios ? .apple : .google;
  final defaultMatch = maps.where((m) => m.mapType == defaultMap).firstOrNull;
  if (defaultMatch != null) return defaultMatch.mapType;

  final installed = maps.where((m) => m.isInstalled).firstOrNull;
  if (installed != null) return installed.mapType;

  return maps.first.mapType;
}
