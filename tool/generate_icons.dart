// ignore_for_file: directives_ordering
import 'dart:convert';
import 'dart:io';

/// Generates Dart icon files from PNG assets as base64-encoded Uint8List.
///
/// Usage: dart run tool/generate_icons.dart
///
/// Reads each PNG file from assets/icons/ and generates a corresponding
/// Dart file in lib/src/maps/icons/ containing the icon as a lazily
/// decoded Uint8List.
///
/// The generated `final Uint8List` (not a getter) ensures stable object
/// identity, critical for Flutter's Image.memory() cache which keys on
/// the Uint8List instance. A getter calling base64Decode() each time
/// would defeat the cache and re-decode on every rebuild.
void main() {
  final assetsDir = Directory('assets/icons');
  final outputDir = Directory('lib/src/maps/icons');

  if (!assetsDir.existsSync()) {
    stderr.writeln('Error: ${assetsDir.path} does not exist');
    exit(1);
  }

  outputDir.createSync(recursive: true);

  final pngFiles =
      assetsDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (pngFiles.isEmpty) {
    stderr.writeln('Error: no PNG files found in ${assetsDir.path}');
    exit(1);
  }

  var totalSize = 0;

  for (final pngFile in pngFiles) {
    final baseName = pngFile.uri.pathSegments.last.replaceAll('.png', '');
    final snakeName = _camelToSnake(baseName);
    final camelName = baseName;
    final varName = '${camelName}Icon';

    final pngBytes = pngFile.readAsBytesSync();
    final b64 = base64Encode(pngBytes);
    totalSize += pngBytes.length;

    final wrapped = _wrapString(b64, 76);

    final dartContent =
        """// GENERATED from assets/icons/$baseName.png. Do not edit.
// Regenerate with: dart run tool/generate_icons.dart

import 'dart:convert';
import 'dart:typed_data';

/// PNG icon for the $baseName map app (256×256).
///
/// Lazily decoded on first access; stable identity for Flutter's image cache.
final Uint8List $varName = base64Decode(
  '$wrapped',
);
""";

    final outputFile = File('${outputDir.path}/${snakeName}_icon.dart');
    outputFile.writeAsStringSync(dartContent);
    stdout.writeln(
      'Generated ${outputFile.path} (${_sizeStr(pngBytes.length)} PNG, '
      '${_sizeStr(b64.length)} base64)',
    );
  }

  stdout.writeln('');
  stdout.writeln(
    'Done: ${pngFiles.length} icons generated, '
    '${_sizeStr(totalSize)} total PNG size.',
  );
}

String _camelToSnake(String input) {
  return input
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => '_${m[1]!.toLowerCase()}')
      .replaceAll(RegExp(r'^_'), '');
}

String _wrapString(String s, int width) {
  // Adjacent string literals (joined at compile time) instead of real newlines.
  if (s.length <= width) return s;

  final buf = StringBuffer();
  for (var i = 0; i < s.length; i += width) {
    final end = (i + width < s.length) ? i + width : s.length;
    if (i > 0) buf.write("'\n  '");
    buf.write(s.substring(i, end));
  }
  return buf.toString();
}

String _sizeStr(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  return '${(bytes / 1024).toStringAsFixed(1)}KB';
}
