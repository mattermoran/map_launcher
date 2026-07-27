// ignore_for_file: directives_ordering
import 'dart:convert';
import 'dart:io';

/// Fetches official app icons from App Store / Play Store for all map apps.
///
/// Usage: dart run tool/fetch_icons.dart [--only <id>] [--skip <id>] [--no-cache]
///
/// Sources:
///   - iTunes Lookup API (primary, for maps with appStoreId)
///   - Google Play Store og:image (fallback, for Android-only maps)
///
/// Downloads 512×512 icons, resizes to 256×256, saves to `assets/icons/<id>.png`.
/// Detects changes vs existing icons and prints a diff summary.
void main(List<String> args) async {
  final onlyId = _flagValue(args, '--only');
  final skipIds = _flagValues(args, '--skip');
  final noCache = args.contains('--no-cache');

  final assetsDir = Directory('assets/icons');
  final cacheDir = Directory('.cache/icons');
  assetsDir.createSync(recursive: true);
  cacheDir.createSync(recursive: true);

  // Load existing manifest (if any) to preserve entries for skipped maps
  final manifestFile = File('${assetsDir.path}/manifest.json');
  final manifest = <String, dynamic>{};
  if (manifestFile.existsSync()) {
    try {
      final existing = jsonDecode(manifestFile.readAsStringSync());
      if (existing is Map) manifest.addAll(existing.cast<String, dynamic>());
    } catch (_) {}
  }

  var changed = 0, unchanged = 0, added = 0, failed = 0, skipped = 0;

  final total = onlyId != null
      ? 1
      : _maps.where((m) => !skipIds.contains(m.id)).length;
  var current = 0;

  for (final map in _maps) {
    if (onlyId != null && map.id != onlyId) continue;
    if (skipIds.contains(map.id)) {
      stdout.writeln('⏭  ${map.id}: skipped (--skip)');
      skipped++;
      continue;
    }
    current++;

    final outputFile = File('${assetsDir.path}/${map.id}.png');
    final cacheFile = File('${cacheDir.path}/${map.id}_raw.png');

    try {
      List<int>? rawBytes;
      String? source;

      if (!noCache && cacheFile.existsSync()) {
        // Preserve previously recorded source
        source = (manifest[map.id] as Map?)?['source'] as String?;
      } else {
        if (map.appStoreId != null) {
          rawBytes = await _fetchFromItunes(
            map.appStoreId!,
            country: map.country,
          );
          if (rawBytes != null) source = 'itunes';
        }
        if (rawBytes == null && map.playStoreId != null) {
          rawBytes = await _fetchFromPlayStore(map.playStoreId!);
          if (rawBytes != null) source = 'playstore';
        }
        if (rawBytes != null) cacheFile.writeAsBytesSync(rawBytes);
      }

      if (rawBytes == null) {
        stderr.writeln('✗  ${map.id}: no icon source available');
        failed++;
        continue;
      }

      // Resize to 256x256 using sips (macOS built-in)
      final tempRaw = File('${cacheDir.path}/${map.id}_temp.png');
      tempRaw.writeAsBytesSync(rawBytes);
      final sipsResult = Process.runSync('sips', [
        '-z',
        '256',
        '256',
        '-s',
        'format',
        'png',
        tempRaw.path,
        '--out',
        tempRaw.path,
      ]);
      if (sipsResult.exitCode != 0) {
        stderr.writeln(
          '✗  ${map.id}: sips resize failed: ${sipsResult.stderr}',
        );
        failed++;
        tempRaw.deleteSync();
        continue;
      }

      final resizedBytes = tempRaw.readAsBytesSync();
      tempRaw.deleteSync();

      if (outputFile.existsSync()) {
        final existingBytes = outputFile.readAsBytesSync();
        if (_bytesEqual(existingBytes, resizedBytes)) {
          stdout.writeln(
            '·  [$current/$total] ${map.id}: unchanged [${source ?? '?'}] (${_sizeStr(resizedBytes.length)})',
          );
          unchanged++;
          manifest[map.id] = _manifestEntry(map, source);
          continue;
        }
        final oldSize = existingBytes.length;
        final newSize = resizedBytes.length;
        final delta = newSize - oldSize;
        final sign = delta >= 0 ? '+' : '';
        stdout.writeln(
          'Δ  [$current/$total] ${map.id}: changed [${source ?? '?'}] (${_sizeStr(oldSize)} -> ${_sizeStr(newSize)}, $sign${_sizeStr(delta)})',
        );
        changed++;
      } else {
        stdout.writeln(
          '+  [$current/$total] ${map.id}: new [${source ?? '?'}] (${_sizeStr(resizedBytes.length)})',
        );
        added++;
      }

      outputFile.writeAsBytesSync(resizedBytes);
      manifest[map.id] = _manifestEntry(map, source);
    } catch (e) {
      stderr.writeln('✗  ${map.id}: $e');
      failed++;
    }
  }

  final encoder = JsonEncoder.withIndent('  ');
  manifestFile.writeAsStringSync('${encoder.convert(manifest)}\n');

  stdout.writeln('');
  stdout.writeln(
    'Summary: $added new, $changed changed, $unchanged unchanged, '
    '$skipped skipped, $failed failed',
  );
  stdout.writeln('Manifest: ${manifestFile.path}');
}

Map<String, dynamic> _manifestEntry(_MapEntry map, String? source) => {
  'source': source ?? 'manual',
  'fetched_at': DateTime.now().toUtc().toIso8601String(),
  if (source == 'itunes') 'app_store_id': map.appStoreId,
  if (source == 'itunes') 'country': map.country,
  if (source == 'playstore') 'play_store_id': map.playStoreId,
  if (source == null || source == 'manual')
    'note': 'Converted from SVG or manually sourced',
};

// ---------------------------------------------------------------------------
// iTunes Lookup API
// ---------------------------------------------------------------------------

Future<List<int>?> _fetchFromItunes(
  String appStoreId, {
  String country = 'us',
}) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'https://itunes.apple.com/lookup?id=$appStoreId&country=$country',
    );
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) return null;

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = json['results'] as List;
    if (results.isEmpty) return null;

    // Get artwork URL, prefer 512, fall back to 100
    var artworkUrl = results[0]['artworkUrl512'] as String?;
    artworkUrl ??= results[0]['artworkUrl100'] as String?;
    if (artworkUrl == null) return null;

    // Force 512px by replacing size in URL
    artworkUrl = artworkUrl.replaceAll(RegExp(r'\d+x\d+'), '512x512');

    return _downloadBytes(artworkUrl);
  } finally {
    client.close();
  }
}

// ---------------------------------------------------------------------------
// Play Store og:image scraping
// ---------------------------------------------------------------------------

Future<List<int>?> _fetchFromPlayStore(String packageName) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName&hl=en',
    );
    final request = await client.getUrl(uri);
    request.headers.set(
      'User-Agent',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
          'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    );
    final response = await request.close();
    if (response.statusCode != 200) {
      stderr.writeln(
        '  Play Store returned ${response.statusCode} for $packageName',
      );
      return null;
    }

    final body = await response.transform(utf8.decoder).join();

    // Extract og:image meta tag
    final match = RegExp(
      r'<meta\s+property="og:image"\s+content="([^"]+)"',
    ).firstMatch(body);
    if (match == null) {
      // Try alternate attribute ordering
      final alt = RegExp(
        r'<meta\s+content="([^"]+)"\s+property="og:image"',
      ).firstMatch(body);
      if (alt == null) return null;
      var url = alt.group(1)!;
      // Strip sizing params to get full res
      url = url.replaceAll(RegExp(r'=w\d+-h\d+[^"]*'), '=s512');
      return _downloadBytes(url);
    }

    var url = match.group(1)!;
    // Strip sizing params to get full res
    url = url.replaceAll(RegExp(r'=w\d+-h\d+[^"]*'), '=s512');
    return _downloadBytes(url);
  } finally {
    client.close();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<List<int>> _downloadBytes(String url) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse(url);
    final request = await client.getUrl(uri);
    final response = await request.close();
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    return bytes;
  } finally {
    client.close();
  }
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String _sizeStr(int bytes) {
  if (bytes.abs() < 1024) return '${bytes}B';
  return '${(bytes / 1024).toStringAsFixed(1)}KB';
}

String? _flagValue(List<String> args, String flag) {
  final idx = args.indexOf(flag);
  if (idx >= 0 && idx + 1 < args.length) return args[idx + 1];
  return null;
}

List<String> _flagValues(List<String> args, String flag) {
  final result = <String>[];
  for (var i = 0; i < args.length; i++) {
    if (args[i] == flag && i + 1 < args.length) {
      result.add(args[++i]);
    }
  }
  return result;
}

// ---------------------------------------------------------------------------
// Map manifest, source of truth for store IDs
// ---------------------------------------------------------------------------

class _MapEntry {
  final String id;
  final String? appStoreId;
  final String? playStoreId;
  final String country; // iTunes country code for geo-restricted apps
  const _MapEntry(
    this.id, {
    this.appStoreId,
    this.playStoreId,
    this.country = 'us',
  });
}

const _maps = <_MapEntry>[
  _MapEntry('apple', appStoreId: '915056765'),
  _MapEntry(
    'google',
    appStoreId: '585027354',
    playStoreId: 'com.google.android.apps.maps',
  ),
  _MapEntry('waze', appStoreId: '323229106', playStoreId: 'com.waze'),
  _MapEntry(
    'yandexMaps',
    appStoreId: '313877526',
    playStoreId: 'ru.yandex.yandexmaps',
    country: 'ru',
  ),
  _MapEntry(
    'doubleGis',
    appStoreId: '481627348',
    playStoreId: 'ru.dublgis.dgismobile',
    country: 'ru',
  ),
  _MapEntry('here', appStoreId: '955837609', playStoreId: 'com.here.app.maps'),
  _MapEntry(
    'mapyCz',
    appStoreId: '411411020',
    playStoreId: 'cz.seznam.mapy',
    country: 'cz',
  ),
  _MapEntry(
    'mappls',
    appStoreId: '370210646',
    playStoreId: 'com.mmi.maps',
    country: 'in',
  ),
  _MapEntry('googleGo', playStoreId: 'com.google.android.apps.mapslite'),
  _MapEntry(
    'amap',
    appStoreId: '461703208',
    playStoreId: 'com.autonavi.minimap',
    country: 'cn',
  ),
  _MapEntry(
    'baidu',
    appStoreId: '452186370',
    playStoreId: 'com.baidu.BaiduMap',
    country: 'cn',
  ),
  _MapEntry(
    'yandexNavi',
    appStoreId: '474500851',
    playStoreId: 'ru.yandex.yandexnavi',
    country: 'ru',
  ),
  _MapEntry(
    'citymapper',
    appStoreId: '469463298',
    playStoreId: 'com.citymapper.app.release',
  ),
  _MapEntry(
    'mapswithme',
    appStoreId: '510623322',
    playStoreId: 'com.mapswithme.maps.pro',
  ),
  _MapEntry('osmand', appStoreId: '934850257', playStoreId: 'net.osmand'),
  _MapEntry('osmandplus', playStoreId: 'net.osmand.plus'),
  _MapEntry(
    'tencent',
    appStoreId: '481623196',
    playStoreId: 'com.tencent.map',
    country: 'cn',
  ),
  _MapEntry('petal', playStoreId: 'com.huawei.maps.app'),
  _MapEntry(
    'tomtomgo',
    appStoreId: '884963367',
    playStoreId: 'com.tomtom.gplay.navapp',
  ),
  _MapEntry('tomtomgofleet', playStoreId: 'com.tomtom.gplay.navapp.gofleet'),
  _MapEntry(
    'copilot',
    appStoreId: '378870891',
    playStoreId: 'com.alk.copilot.mapviewer',
  ),
  _MapEntry(
    'sygicTruck',
    appStoreId: '1005447813',
    playStoreId: 'com.sygic.truck',
    country: 'de',
  ),
  _MapEntry('flitsmeister', playStoreId: 'nl.flitsmeister'),
  _MapEntry(
    'naver',
    appStoreId: '311867728',
    playStoreId: 'com.nhn.android.nmap',
    country: 'kr',
  ),
  _MapEntry(
    'kakao',
    appStoreId: '304608425',
    playStoreId: 'net.daum.android.map',
    country: 'kr',
  ),
  _MapEntry(
    'tmap',
    appStoreId: '431589174',
    playStoreId: 'com.skt.tmap.ku',
    country: 'kr',
  ),
  _MapEntry('moovit', appStoreId: '498477945', playStoreId: 'com.tranzmate'),
  _MapEntry(
    'neshan',
    appStoreId: '1596368814',
    playStoreId: 'org.rajman.neshan.traffic.tehran.navigator',
    country: 'ir',
  ),
  _MapEntry(
    'airnavPro',
    appStoreId: '304684223',
    playStoreId: 'com.xample.airnavigation',
  ),
  _MapEntry(
    'magicEarth',
    appStoreId: '476085748',
    playStoreId: 'com.generalmagic.magicearth',
  ),
];
