// ignore_for_file: prefer_const_constructors

import 'package:check_platform_name/check_platform_name.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttium/fluttium.dart';
import 'package:mocktail/mocktail.dart';

class _MockTester extends Mock implements Tester {}

class _MockSemanticsNode extends Mock implements SemanticsNode {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

void main() {
  group('CheckPlatformName', () {
    late Tester tester;
    late SemanticsNode node;

    setUp(() {
      tester = _MockTester();
      node = _MockSemanticsNode();

      when(() => tester.find(any())).thenAnswer((_) async => node);
    });

    test('executes returns true if node was found', () async {
      final action = CheckPlatformName();

      expect(await action.execute(tester), isTrue);
    });

    test('executes returns false if node was not found', () async {
      when(() => tester.find(any())).thenAnswer((_) async => null);

      final action = CheckPlatformName();

      expect(await action.execute(tester), isFalse);
    });

    test('show correct description for every platform', () {
      bool isTrue() => true;
      bool isFalse() => false;

      final testCases = [
        (
          'Android',
          CheckPlatformName(
            isAndroid: isTrue,
            isIOS: isFalse,
            isWeb: isFalse(),
            isWindows: isFalse,
            isLinux: isFalse,
            isMacOS: isFalse,
          )
        ),
        (
          'iOS',
          CheckPlatformName(
            isAndroid: isFalse,
            isIOS: isTrue,
            isWeb: isFalse(),
            isWindows: isFalse,
            isLinux: isFalse,
            isMacOS: isFalse,
          )
        ),
        (
          'Web',
          CheckPlatformName(
            isAndroid: isFalse,
            isIOS: isFalse,
            isWeb: isTrue(),
            isWindows: isFalse,
            isLinux: isFalse,
            isMacOS: isFalse,
          )
        ),
        (
          'Linux',
          CheckPlatformName(
            isAndroid: isFalse,
            isIOS: isFalse,
            isWeb: isFalse(),
            isWindows: isFalse,
            isLinux: isTrue,
            isMacOS: isFalse,
          )
        ),
        (
          'MacOS',
          CheckPlatformName(
            isAndroid: isFalse,
            isIOS: isFalse,
            isWeb: isFalse(),
            isWindows: isFalse,
            isLinux: isFalse,
            isMacOS: isTrue,
          )
        ),
        (
          'Windows',
          CheckPlatformName(
            isAndroid: isFalse,
            isIOS: isFalse,
            isWeb: isFalse(),
            isWindows: isTrue,
            isLinux: isFalse,
            isMacOS: isFalse,
          )
        ),
      ];

      for (final testCase in testCases) {
        expect(
          testCase.$2.description(),
          equals('Check platform name: "${testCase.$1}"'),
        );
      }
    });

    test('throws UnsupportedError on unknown platform', () {
      final action = CheckPlatformName(
        isAndroid: () => false,
        isIOS: () => false,
        isWeb: false,
        isWindows: () => false,
        isLinux: () => false,
        isMacOS: () => false,
      );

      expect(action.description, throwsUnsupportedError);
    });
  });
}
