@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  final script = File('tool/fetch_icons.dart').absolute.path;
  late Directory fixture;
  late File resizer;

  setUp(() async {
    fixture = Directory.systemTemp.createTempSync('map-launcher-icons-');
    Directory('${fixture.path}/.cache/icons').createSync(recursive: true);
    File(
      '${fixture.path}/.cache/icons/google_raw.png',
    ).writeAsBytesSync([1, 2, 3]);
    Directory('${fixture.path}/bin').createSync();
    resizer = File(
      '${fixture.path}/bin/${Platform.isMacOS ? 'sips' : 'magick'}',
    );
    // The fake resizer leaves bytes unchanged so these tests need no image tool
    // or network. Real image conversion is outside the cache contract.
    resizer.writeAsStringSync('#!/bin/sh\nexit 0\n');
    final result = await Process.run('chmod', ['+x', resizer.path]);
    expect(result.exitCode, 0);
  });

  tearDown(() => fixture.deleteSync(recursive: true));

  Future<ProcessResult> fetch() => Process.run(
    'dart',
    [script, '--only', 'google'],
    workingDirectory: fixture.path,
    environment: {
      'PATH': '${fixture.path}/bin:${Platform.environment['PATH']}',
    },
  );

  test(
    'cached bytes are reused on consecutive runs',
    () async {
      final first = await fetch();
      expect(first.exitCode, 0, reason: '${first.stderr}');
      expect(
        File('${fixture.path}/assets/icons/google.png').readAsBytesSync(),
        [1, 2, 3],
      );
      final second = await fetch();
      expect(second.exitCode, 0, reason: '${second.stderr}');
      expect(second.stdout, contains('1 unchanged'));
    },
    skip: Platform.isWindows ? 'Uses a POSIX fake executable' : false,
  );

  test(
    'resize failures exit nonzero and clean temporary files',
    () async {
      resizer.writeAsStringSync('#!/bin/sh\nexit 1\n');
      final result = await fetch();
      expect(result.exitCode, 1);
      expect(result.stdout, contains('1 failed'));
      expect(
        File('${fixture.path}/.cache/icons/google_temp.png').existsSync(),
        isFalse,
      );
    },
    skip: Platform.isWindows ? 'Uses a POSIX fake executable' : false,
  );
}
