@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher_desktop.dart';

String _encodeCommand(String script) => base64Encode([
  for (final unit in script.codeUnits) ...[unit & 0xff, unit >> 8],
]);

void main() {
  const urls = [
    'https://maps.example/?a=1&b=2',
    'https://maps.example/?q=Södermalm 😀&x=%26%20',
    r'''https://maps.example/%USERNAME%?q="'; Write-Output INJECTED; #''',
    r'https://maps.example/?q=$(Write-Output INJECTED)`&x=%PATH%',
  ];

  test(
    'desktop rejects non-web and malformed URLs before starting a process',
    () async {
      final desktop = MapLauncherDesktop();
      for (final url in [
        '',
        'relative/path',
        'https:',
        'https:///path',
        'file:///tmp/app.exe',
        'javascript:alert(1)',
        'custom:launch',
        'https://maps.example/\u0000ignored',
      ]) {
        await expectLater(
          desktop.launch(url),
          throwsArgumentError,
          reason: url,
        );
      }
    },
  );

  for (final url in urls) {
    test('Windows invocation keeps URL out of executable source: $url', () {
      final args = MapLauncherDesktop.windowsLaunchArguments(url);
      expect(args.take(3), [
        '-NoProfile',
        '-NonInteractive',
        '-EncodedCommand',
      ]);
      final bytes = ByteData.sublistView(base64Decode(args.last));
      final script = String.fromCharCodes([
        for (var i = 0; i < bytes.lengthInBytes; i += 2)
          bytes.getUint16(i, Endian.little),
      ]);
      expect(script, isNot(contains(url)));
      final encodedUrl = RegExp(
        r"FromBase64String\('([A-Za-z0-9+/=]+)'\)",
      ).firstMatch(script)!.group(1)!;
      expect(utf8.decode(base64Decode(encodedUrl)), url);
      expect(script, contains("\$ErrorActionPreference = 'Stop'"));
    });
  }

  // On Windows, exercise Windows PowerShell itself. Linux can run the same
  // parser-level regressions with PowerShell Core, without opening a browser.
  final powershell = Platform.isWindows
      ? 'powershell.exe'
      : Platform.environment['POWERSHELL_EXECUTABLE'];

  group(
    'PowerShell runtime',
    () {
      test(
        'metacharacters and Unicode reach Start-Process as literal data',
        () async {
          for (final url in urls) {
            final command = MapLauncherDesktop.windowsLaunchArguments(url).last;
            final script =
                '''
function Start-Process {
  param([string] \$FilePath)
  [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(\$FilePath))
}
& ([ScriptBlock]::Create([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('$command'))))
''';
            final result = await Process.run(powershell!, [
              '-NoProfile',
              '-NonInteractive',
              '-EncodedCommand',
              _encodeCommand(script),
            ]);
            expect(result.exitCode, 0, reason: '${result.stderr}');
            expect(
              (result.stdout as String).trim(),
              base64Encode(utf8.encode(url)),
            );
          }
        },
      );

      test('a failed handler produces a nonzero exit status', () async {
        final command = MapLauncherDesktop.windowsLaunchArguments(
          urls.first,
        ).last;
        final script =
            '''
function Start-Process { throw 'No browser handler' }
& ([ScriptBlock]::Create([Text.Encoding]::Unicode.GetString([Convert]::FromBase64String('$command'))))
''';
        final result = await Process.run(powershell!, [
          '-NoProfile',
          '-NonInteractive',
          '-EncodedCommand',
          _encodeCommand(script),
        ]);
        expect(result.exitCode, isNot(0));
      });
    },
    skip: powershell == null
        ? 'PowerShell is not installed on this platform'
        : false,
  );
}
