import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';

/// Guards the sync between the PNG source files in assets/icons/ and the
/// generated base64-encoded Uint8List in lib/src/maps/icons/.
///
/// The generator reads each PNG and base64-encodes it, so decoded bytes
/// must match the source file exactly.
/// If this fails after updating an icon, run: dart run tool/generate_icons.dart
void main() {
  group('icon sync', () {
    for (final map in MapApp.all) {
      test(map.id, () {
        final file = File('assets/icons/${map.id}.png');
        expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');
        final fileBytes = file.readAsBytesSync();
        expect(
          map.iconBytes,
          fileBytes,
          reason:
              '${map.id} icon out of sync with ${file.path}. '
              'run: dart run tool/generate_icons.dart',
        );
      });
    }

    test('no orphan PNG files', () {
      final ids = MapApp.all.map((m) => m.id).toSet();
      final orphans = Directory('assets/icons')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .map((f) => f.uri.pathSegments.last.replaceAll('.png', ''))
          .where((id) => !ids.contains(id));
      expect(orphans, isEmpty);
    });
  });
}
