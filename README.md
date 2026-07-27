# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher)](https://pub.dev/packages/map_launcher)
[![likes](https://img.shields.io/pub/likes/map_launcher)](https://pub.dev/packages/map_launcher/score)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/map_launcher)
[![pub points](https://img.shields.io/pub/points/map_launcher)](https://pub.dev/packages/map_launcher/score)
[![GitHub stars](https://img.shields.io/github/stars/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/network)

Map Launcher is a Flutter plugin to open maps on **all platforms**: iOS, Android, web, and desktop. Show markers, get directions, or search across 30 supported maps.

Uses universal links (HTTPS URLs), with native app detection on mobile.

Maps are tree-shakeable: **only the maps you reference are compiled into your app**. No URL schemes, package names, store ids, or icons of unused maps ever ship in your binary. See [Binary Size & App Store Compliance](#binary-size--app-store-compliance).

|                                Marker                                 |                                Navigation                                 |
| :-------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| ![Marker](https://media.giphy.com/media/YNE1A6jrQQx4fArqKb/giphy.gif) | ![Navigation](https://media.giphy.com/media/gKIAdlbEzTDl6n7IOS/giphy.gif) |

### Supported Maps

| Map                                                                                                                                 | Marker | Search | Directions | Origin | Travel Mode | Waypoints | Platform |
| ----------------------------------------------------------------------------------------------------------------------------------- | :----: | :----: | :--------: | :----: | :---------: | :-------: | -------- |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.png" width="20"> Google Maps                   |   ✓    |   ✓    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/apple.png" width="20"> Apple Maps                     |   ✓    |   ✓    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/waze.png" width="20"> Waze                            |   —    |   —    |     ✓      |   —    |      —      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexMaps.png" width="20"> Yandex Maps               |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/doubleGis.png" width="20"> 2GIS                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/here.png" width="20"> HERE WeGo                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapyCz.png" width="20"> Mapy.cz                       |   ✓    |   —    |     ✓      |   —    |      —      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mappls.png" width="20"> Mappls                        |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/baidu.png" width="20"> Baidu Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/amap.png" width="20"> Amap                            |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tencent.png" width="20"> Tencent (QQ)                 |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexNavi.png" width="20"> Yandex Navi               |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/googleGo.png" width="20"> Google Maps Go                |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/naver.png" width="20"> Naver Map                      |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/kakao.png" width="20"> Kakao Maps                     |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tmap.png" width="20"> TMap                            |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.png" width="20"> OsmAnd                        |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmandplus.png" width="20"> OsmAnd+                   |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/petal.png" width="20"> Petal Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.png" width="20"> MAPS.ME                   |   ✓    |   —    |     —      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/neshan.png" width="20"> Neshan                        |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/copilot.png" width="20"> CoPilot                      |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/moovit.png" width="20"> Moovit                        |   —    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/citymapper.png" width="20"> Citymapper                |   —    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgo.png" width="20"> TomTom Go                   |   —    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgofleet.png" width="20"> TomTom Go Fleet        |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/sygicTruck.png" width="20"> Sygic Truck               |   —    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/flitsmeister.png" width="20"> Flitsmeister            |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/airnavPro.png" width="20"> Air Nav Pro                |   ✓    |   —    |     —      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/magicEarth.png" width="20"> Magic Earth               |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Mobile   |

**Platform:** **All** = universal links (iOS, Android, web, desktop) • **Mobile** = native app (iOS + Android) • **Android** = Android only

## Table of Contents

- [Quick Start](#quick-start)
- [Setup](#setup)
- [API](#api)
  - [Markers](#markers)
  - [Directions](#directions)
  - [Choosing a Map](#choosing-a-map)
  - [Discovering Maps](#discovering-maps)
  - [URL Inspection](#url-inspection)
  - [Map Info & Store Links](#map-info--store-links)
  - [Extras](#extras)
- [Example: Bottom Sheet Picker](#example--bottom-sheet-picker)
- [Binary Size & App Store Compliance](#binary-size--app-store-compliance)
- [Custom Maps](#custom-maps)
- [Migrating from 5.x](#migrating-from-5x)
- [Known Issues](#known-issues)
- [Contributing](#contributing)

## Quick Start

```yaml
dependencies:
  map_launcher: ^6.0.0
```

```dart
import 'package:map_launcher/map_launcher.dart';

// Show a marker (opens the best available map)
await MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan')).show();

// Show directions
await MapLauncher.directions(.coords(59.33, 18.07), mode: .walking).show();

// Search
await MapLauncher.marker(.search('Fika near Södermalm')).show();

// Specific map
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);

// Discover available maps (pass the maps your app supports)
final maps = await MapLauncher.marker(.coords(59.33, 18.07))
    .getSupportedMaps([.apple, .google, .waze]);
await maps.first.show();
```

## Setup

### iOS: Add URL schemes to Info.plist

Required for detecting installed native apps. **Add only the schemes for the
maps your app uses**. Each entry is visible to App Store review, so keep the
list as short as your map list:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>  <!-- Google Maps -->
    <!-- Add more only if you use them:
    <string>waze</string>              Waze
    <string>iosamap</string>            Amap
    <string>baidumap</string>           Baidu Maps
    <string>yandexmaps</string>         Yandex Maps
    <string>yandexnavi</string>         Yandex Navigator
    <string>citymapper</string>         Citymapper
    <string>mapswithme</string>         MAPS.ME
    <string>osmandmaps</string>         OsmAnd
    <string>dgis</string>               2GIS
    <string>qqmap</string>              Tencent (QQ Maps)
    <string>here-location</string>      HERE WeGo
    <string>tomtomgo</string>           TomTom Go
    <string>copilot</string>            CoPilot
    <string>com.sygic.aura</string>     Sygic Truck
    <string>nmap</string>               Naver Map
    <string>kakaomap</string>           Kakao Maps
    <string>tmap</string>               TMap
    <string>szn-mapy</string>           Mapy.cz
    <string>mappls</string>             Mappls
    <string>moovit</string>             Moovit
    <string>neshan</string>             Neshan
    <string>airnavpro</string>          Air Navigation Pro
    <string>magicearth</string>         Magic Earth
    -->
</array>
```

Apple Maps needs no entry. Each map's scheme is also available in code as
`MapApp.<name>.iosScheme`.

If you pass a map to discovery but forget its plist entry, debug builds print
a warning naming the exact scheme to add. Without the entry the map can
never be detected, which is otherwise indistinguishable from "not installed".

### Android: No setup needed

The plugin ships a `<queries>` manifest block so installed map apps are
visible to detection. If you want your merged manifest to list only the maps
you use, remove entries in your app's `AndroidManifest.xml`:

```xml
<queries>
  <package android:name="org.rajman.neshan.traffic.tehran.navigator"
           tools:node="remove" />
</queries>
```

### Web / Desktop: No setup needed

## API

### Markers

```dart
// By coordinates
await MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan')).show();

// With zoom level
await MapLauncher.marker(.coords(59.33, 18.07), zoom: 14).show();

// By search query (Google & Apple Maps)
await MapLauncher.marker(.search('Vasa Museum Stockholm')).show();
```

### Error Handling

`show()` throws `MapLaunchException` if the map cannot be opened:

```dart
try {
  await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);
} on MapLaunchException catch (e) {
  print('Failed to open map: $e');
}
```

### Directions

```dart
// Basic
await MapLauncher.directions(.coords(59.33, 18.07)).show();

// With origin, mode, and waypoints
await MapLauncher.directions(
  .coords(59.33, 18.07),
  from: .coords(59.33, 18.10, title: 'Djurgården'),
  mode: .walking,
  waypoints: [.coords(59.32, 18.08)],
).show();

// Search-based destination
await MapLauncher.directions(.search('Vasa Museum')).show();

// Search-based origin
await MapLauncher.directions(
  .coords(59.33, 18.07),
  from: .search('Stockholm Central'),
).show();
```

### Choosing a Map

```dart
// Specific map
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: .google);

// If map is omitted, the best available map is used automatically:
// • iOS/macOS → Apple Maps
// • Other platforms → Google Maps
// • Falls back to web if native app unavailable
```

### Discovering Maps

Discovery takes the list of maps your app supports. Only the maps you
reference are compiled into your binary. Declare the list once as a
constant and reuse it:

```dart
const myMaps = <MapApp>[.apple, .google, .waze, .citymapper];

// Maps that support a specific marker request
final marker = MapLauncher.marker(.coords(59.33, 18.07));
final maps = await marker.getSupportedMaps(myMaps);
for (final map in maps) {
  print('${map.name} (installed: ${map.isInstalled})');
}
await maps.first.show(); // launches the marker request with that map

// Maps that support a specific directions request
final directions = MapLauncher.directions(.coords(59.33, 18.07), mode: .walking);
final navMaps = await directions.getSupportedMaps(myMaps);

// All maps available on this platform (installed + universal link)
final allAvailable = await MapLauncher.getAvailableMaps(myMaps);

// Every supported map (opts out of tree shaking, see
// "Binary Size & App Store Compliance" below)
final everything = await MapLauncher.getAvailableMaps(MapApp.all);
```

### URL Inspection

```dart
final marker = MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan'));

// Best URL for this platform (scheme on mobile, universal on web)
final url = marker.getUrl(map: .google);

// Universal (HTTPS) URL, always works in browser
final universal = marker.getUniversalUrl(map: .google);
// → https://www.google.com/maps/search/?api=1&query=59.33%2C18.07

// Native scheme URL, only works with installed app
final scheme = marker.getSchemeUrl(map: .google);
// → comgooglemaps://?q=59.33,18.07

// Preview scheme URL for a different platform
final iosScheme = marker.getSchemeUrl(map: .google, platform: .ios);
final androidScheme = marker.getSchemeUrl(map: .google, platform: .android);
```

### Map Info & Store Links

`MapApp` properties are synchronous:

```dart
MapApp.waze.name          // "Waze"
MapApp.waze.id            // "waze", stable and safe to persist in preferences
MapApp.waze.iconBytes    // PNG bytes, use with Image.memory()
MapApp.waze.appStoreUrl   // "https://apps.apple.com/app/id323229106"
MapApp.waze.playStoreUrl  // "https://play.google.com/store/apps/details?id=com.waze"
MapApp.waze.hasUniversalLink // true
```

### Extras

Typed helper classes for map-specific parameters:

```dart
// Google: Place IDs, navigation mode
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(queryPlaceId: 'ChIJLU7jZClu5kcR4PcOOO6p3I0'),
);

await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(navigate: true, destinationPlaceId: 'ChIJLU7j...'),
);

// Apple: map display type, search bias location
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: AppleExtra(display: AppleMapDisplay.satellite),
);

await MapLauncher.marker(.search('restaurants')).show(
  map: .apple,
  extra: AppleExtra(near: LocationCoords(59.33, 18.07)),
);

// Waze: auto-navigate
await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .waze,
  extra: WazeExtra(navigate: true),
);

// Tencent: API key
await MapLauncher.marker(.coords(39.9, 116.4)).show(
  map: .tencent,
  extra: TencentExtra(referer: 'your-app-key'),
);

// Yandex Navigator: auth
await MapLauncher.directions(.coords(55.75, 37.62)).show(
  map: .yandexNavi,
  extra: YandexNaviExtra(client: 'your-client-id', signature: 'your-sig'),
);

// Raw map, works with any map
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: {'t': 'k'}, // satellite view via raw params
);
```

## Example: Bottom Sheet Picker

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class MapPickerSheet extends StatelessWidget {
  final LocationCoords destination;

  const MapPickerSheet({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final request = MapLauncher.marker(destination);

    return FutureBuilder<List<SupportedMap>>(
      future: request.getSupportedMaps([.apple, .google, .waze, .citymapper]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final maps = snapshot.data!;

        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final map in maps)
                  ListTile(
                    onTap: () => map.show(),
                    title: Text(map.name),
                    leading: Image.memory(map.iconBytes,
                      height: 30,
                      width: 30,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Usage
showModalBottomSheet(
  context: context,
  builder: (_) => MapPickerSheet(
    destination: .coords(59.33, 18.07, title: 'Gamla Stan'),
  ),
);
```

## Binary Size & App Store Compliance

Each map is a const object, and **only the maps your code references are
compiled into your app**: their URL strings, package names, store ids, and
icons. Everything else is removed by Dart's tree shaking in release builds.

This matters beyond binary size: App Store review scans binaries for
references to embargoed services, and there is precedent for apps being
rejected over identifiers they never actually used. With 6.0, if you don't
reference a map, nothing about it exists in your build.

Things to know:

- `MapApp.all` references every map, so using it opts out of tree shaking.
  All 30 maps' identifiers will ship in your binary. Prefer an explicit list.
- Your `LSApplicationQueriesSchemes` is part of your app, not the plugin.
  Declare only the schemes you use and prune stale ones (see [Setup](#setup)).
- The plugin's Android `<queries>` entries can be removed per map with
  `tools:node="remove"` if you want a minimal manifest (see [Setup](#setup)).

## Custom Maps

Subclass `MapApp` to add a map the plugin doesn't ship. No fork needed:

```dart
class AcmeMaps extends MapApp {
  const AcmeMaps();

  @override
  String get id => 'acmeMaps';

  @override
  String get name => 'Acme Maps';

  @override
  String? get playStoreId => 'com.acme.maps';

  @override
  String? get iosScheme => 'acmemaps://';

  @override
  Uint8List get iconBytes => myIconPngBytes;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) =>
      'https://maps.acme.com/?ll=${coords.latlng}';

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => 'https://maps.acme.com/directions?to=${destination.latlng}';
}

// Works everywhere a built-in map does:
await MapLauncher.marker(.coords(59.33, 18.07)).show(map: const AcmeMaps());
final maps = await request.getSupportedMaps([.google, const AcmeMaps()]);
```

Override the scheme-URL methods and capability flags (`supportsWaypoints`,
`supportsMarkerSearch`, ...) as needed. See any map in
[`lib/src/maps/`](lib/src/maps/) for a template.

For a custom map to be **detected** as installed, add its identifiers to your
own app config. The plugin's bundled entries only cover built-in maps:

- **iOS**: add its scheme to `LSApplicationQueriesSchemes` (debug builds warn
  if you forget).
- **Android**: add a `<queries>` entry to your `AndroidManifest.xml`:

  ```xml
  <queries>
    <package android:name="com.acme.maps" />
  </queries>
  ```

  Note there is no warning for this on Android. The OS gives apps no way to
  check their own `<queries>`, so a missing entry looks exactly like "app
  not installed". Launching (`show(map: const AcmeMaps())`) works either way;
  only detection needs these entries.

## Migrating from 5.x

Call sites like `show(map: .google)` compile unchanged. The full guide is in
[MIGRATION.md](MIGRATION.md). The short version:

| 5.x | 6.0 |
| --- | --- |
| `MapType.google` | `MapApp.google` |
| `getSupportedMaps()` | `getSupportedMaps([.apple, .google, .waze])` |
| `MapLauncher.getAvailableMaps()` | `MapLauncher.getAvailableMaps(myMaps)` |
| `map.mapType` | `map.map` |
| `map.displayName` | `map.name` |
| `SvgPicture.asset(map.icon)` | `Image.memory(map.iconBytes)` |
| `MapType.values.byName(saved)` | `myMaps.firstWhere((m) => m.id == saved)` |

## Known Issues

- On iOS it's possible to "delete" Apple Maps which actually just removes it from the home screen and does not actually delete it. Because of that Apple Maps will always show up as available on iOS. [More info](https://stackoverflow.com/questions/39603120/how-to-check-if-apple-maps-is-installed)

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions and guidelines.
