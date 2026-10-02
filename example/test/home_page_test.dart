import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';
import 'package:map_launcher_example/home_page.dart';

class _FakePlatform extends MapLauncherPlatform {
  _FakePlatform({this.failLaunch = false, this.failDiscovery = false});

  final bool failLaunch;
  bool failDiscovery;

  @override
  Future<Set<String>> getInstalledMaps(List<MapApp> maps) async {
    if (failDiscovery) throw Exception('discovery failed');
    return {MapApp.google.id};
  }

  @override
  Future<void> launch(String url, {String? androidPackageName}) async {
    if (failLaunch) throw Exception('launch failed');
  }
}

void main() {
  late MapLauncherPlatform originalPlatform;

  setUp(() {
    originalPlatform = MapLauncherPlatform.instance;
    MapLauncherPlatform.instance = _FakePlatform();
  });

  tearDown(() => MapLauncherPlatform.instance = originalPlatform);

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();
  }

  testWidgets('discovery failure replaces spinner and can be retried', (
    tester,
  ) async {
    final platform = _FakePlatform(failDiscovery: true);
    MapLauncherPlatform.instance = platform;
    await pumpHome(tester);
    expect(find.text('Could not load available maps.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);

    platform.failDiscovery = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('Could not load available maps.'), findsNothing);
  });

  testWidgets('invalid marker coordinates remain visible and are not applied', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.byTooltip('Edit parameters'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Latitude'),
      '91',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Longitude'),
      'not a number',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(find.text('Must be -90 to 90'), findsOneWidget);
    expect(find.text('Enter a valid number'), findsOneWidget);
    expect(find.text('Edit Parameters'), findsOneWidget);
    expect(find.textContaining('48.8584, 2.2945'), findsOneWidget);
  });

  testWidgets('failed refresh hides stale choices and remains retryable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final platform = _FakePlatform();
    MapLauncherPlatform.instance = platform;
    await pumpHome(tester);
    await tester.tap(find.text('Directions'));
    await tester.pumpAndSettle();
    expect(find.text('Waze'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit parameters'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<TravelMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('walking').last);
    await tester.pumpAndSettle();
    platform.failDiscovery = true;
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Waze'), findsNothing);
    expect(find.text('Could not load available maps.'), findsOneWidget);
    platform.failDiscovery = false;
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load available maps.'), findsNothing);
    expect(find.textContaining('walking'), findsOneWidget);
    expect(find.text('Google Maps'), findsOneWidget);
  });

  testWidgets('blank search remains visible and is not applied', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit parameters'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Search query'),
      '   ',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(find.text('Enter a search query'), findsOneWidget);
    expect(find.text('Edit Parameters'), findsOneWidget);
    expect(find.textContaining('Eiffel Tower'), findsOneWidget);
  });

  testWidgets('launch failures show an actionable message', (tester) async {
    MapLauncherPlatform.instance = _FakePlatform(failLaunch: true);
    await pumpHome(tester);

    await tester.tap(find.text('Google Maps'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not open the map. Please try again.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
