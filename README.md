# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher)](https://pub.dev/packages/map_launcher)
[![likes](https://img.shields.io/pub/likes/map_launcher)](https://pub.dev/packages/map_launcher/score)
![Pub Monthly Downloads](https://img.shields.io/pub/dm/map_launcher)
[![pub points](https://img.shields.io/pub/points/map_launcher)](https://pub.dev/packages/map_launcher/score)
[![GitHub stars](https://img.shields.io/github/stars/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/network)

Map Launcher is a Flutter plugin to open maps on **all platforms**: iOS, Android, web, and desktop. Show markers, get directions, or search across 32 supported maps.

Uses universal links (HTTPS URLs), with native app detection on mobile.

|                                Marker                                 |                                Navigation                                 |
| :-------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| ![Marker](https://media.giphy.com/media/YNE1A6jrQQx4fArqKb/giphy.gif) | ![Navigation](https://media.giphy.com/media/gKIAdlbEzTDl6n7IOS/giphy.gif) |

### Supported Maps

| Map                                                                                                                                 | Marker | Search | Directions | Origin | Travel Mode | Waypoints | Platform |
| ----------------------------------------------------------------------------------------------------------------------------------- | :----: | :----: | :--------: | :----: | :---------: | :-------: | -------- |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.svg" width="20"> Google Maps                   |   ✓    |   ✓    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/apple.svg" width="20"> Apple Maps                     |   ✓    |   ✓    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/waze.svg" width="20"> Waze                            |   —    |   —    |     ✓      |   —    |      —      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexMaps.svg" width="20"> Yandex Maps               |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/doubleGis.svg" width="20"> 2GIS                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/here.svg" width="20"> HERE WeGo                       |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapyCz.svg" width="20"> Mapy.cz                       |   ✓    |   —    |     ✓      |   —    |      —      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mappls.svg" width="20"> Mappls                        |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | All      |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/baidu.svg" width="20"> Baidu Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/amap.svg" width="20"> Amap                            |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tencent.svg" width="20"> Tencent (QQ)                 |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexNavi.svg" width="20"> Yandex Navi               |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     ✓     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.svg" width="20"> Google Maps Go                |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/naver.svg" width="20"> Naver Map                      |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/kakao.svg" width="20"> Kakao Maps                     |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tmap.svg" width="20"> TMap                            |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.svg" width="20"> OsmAnd                        |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmandplus.svg" width="20"> OsmAnd+                   |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/petal.svg" width="20"> Petal Maps                     |   ✓    |   —    |     ✓      |   ✓    |      ✓      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.svg" width="20"> MAPS.ME                   |   ✓    |   —    |     —      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/neshan.svg" width="20"> Neshan                        |   ✓    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/copilot.svg" width="20"> CoPilot                      |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/moovit.svg" width="20"> Moovit                        |   —    |   —    |     ✓      |   ✓    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/citymapper.svg" width="20"> Citymapper                |   —    |   —    |     ✓      |   ✓    |      ✓      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgo.svg" width="20"> TomTom Go                   |   —    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgofleet.svg" width="20"> TomTom Go Fleet        |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/sygicTruck.svg" width="20"> Sygic Truck               |   —    |   —    |     ✓      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/flitsmeister.svg" width="20"> Flitsmeister            |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/truckmeister.svg" width="20"> Truckmeister            |   —    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/airnavPro.svg" width="20"> Air Nav Pro                |   ✓    |   —    |     —      |   —    |      —      |     —     | Mobile   |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/spedionNavigation.svg" width="20"> SPEDION Navigation |   ✓    |   —    |     ✓      |   —    |      —      |     —     | Android  |
| <img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/magicEarth.svg" width="20"> Magic Earth               |   ✓    |   —    |     ✓      |   —    |      ✓      |     —     | Mobile   |

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
- [Example — Bottom Sheet Picker](#example--bottom-sheet-picker)
- [Known Issues](#known-issues)
- [Contributing](#contributing)

## Quick Start

```yaml
dependencies:
  map_launcher: ^5.0.0
  flutter_svg: # optional — only needed for map icons
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

// Discover available maps
final maps = await MapLauncher.marker(.coords(59.33, 18.07)).getSupportedMaps();
```

## Setup

### iOS — Add URL schemes to Info.plist

Required for detecting installed native apps:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>baidumap</string>
    <string>iosamap</string>
    <string>waze</string>
    <string>yandexmaps</string>
    <string>yandexnavi</string>
    <string>citymapper</string>
    <string>mapswithme</string>
    <string>osmandmaps</string>
    <string>dgis</string>
    <string>qqmap</string>
    <string>here-location</string>
    <string>tomtomgo</string>
    <string>copilot</string>
    <string>com.sygic.aura</string>
    <string>nmap</string>
    <string>kakaomap</string>
    <string>tmap</string>
    <string>szn-mapy</string>
    <string>mappls</string>
    <string>moovit</string>
    <string>neshan</string>
    <string>airnavpro</string>
    <string>magicearth</string>
</array>
```

### Android — No setup needed

### Web / Desktop — No setup needed

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

```dart
// Maps that support a specific marker request
final marker = MapLauncher.marker(.coords(59.33, 18.07));
final maps = await marker.getSupportedMaps();
for (final map in maps) {
  print('${map.displayName} (installed: ${map.isInstalled})');
}

// Maps that support a specific directions request
final directions = MapLauncher.directions(.coords(59.33, 18.07), mode: .walking);
final navMaps = await directions.getSupportedMaps();

// All maps available on this platform (installed + universal link)
final allAvailable = await MapLauncher.getAvailableMaps();
```

### URL Inspection

```dart
final marker = MapLauncher.marker(.coords(59.33, 18.07, title: 'Gamla Stan'));

// Best URL for this platform (scheme on mobile, universal on web)
final url = marker.getUrl(map: .google);

// Universal (HTTPS) URL — always works in browser
final universal = marker.getUniversalUrl(map: .google);
// → https://www.google.com/maps/search/?api=1&query=59.33%2C18.07

// Native scheme URL — only works with installed app
final scheme = marker.getSchemeUrl(map: .google);
// → comgooglemaps://?q=59.33,18.07

// Preview scheme URL for a different platform
final iosScheme = marker.getSchemeUrl(map: .google, platform: .ios);
final androidScheme = marker.getSchemeUrl(map: .google, platform: .android);
```

### Map Info & Store Links

`MapType` properties are synchronous:

```dart
MapType.waze.displayName  // "Waze"
MapType.waze.icon         // asset path for SVG icon
MapType.waze.appStoreUrl  // "https://apps.apple.com/app/id323229106"
MapType.waze.playStoreUrl // "https://play.google.com/store/apps/details?id=com.waze"
MapType.waze.hasUniversalLink // true
```

### Extras

Typed helper classes for map-specific parameters:

```dart
// Google — Place IDs, navigation mode
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(queryPlaceId: 'ChIJLU7jZClu5kcR4PcOOO6p3I0'),
);

await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .google,
  extra: GoogleExtra(navigate: true, destinationPlaceId: 'ChIJLU7j...'),
);

// Apple — map display type, search bias location
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: AppleExtra(display: AppleMapDisplay.satellite),
);

await MapLauncher.marker(.search('restaurants')).show(
  map: .apple,
  extra: AppleExtra(near: LocationCoords(59.33, 18.07)),
);

// Waze — auto-navigate
await MapLauncher.directions(.coords(59.33, 18.07)).show(
  map: .waze,
  extra: WazeExtra(navigate: true), // explicitly start navigation
);

// Tencent — API key
await MapLauncher.marker(.coords(39.9, 116.4)).show(
  map: .tencent,
  extra: TencentExtra(referer: 'your-app-key'),
);

// Yandex Navigator — auth
await MapLauncher.directions(.coords(55.75, 37.62)).show(
  map: .yandexNavi,
  extra: YandexNaviExtra(client: 'your-client-id', signature: 'your-sig'),
);

// Raw map — works with any map
await MapLauncher.marker(.coords(59.33, 18.07)).show(
  map: .apple,
  extra: {'t': 'k'}, // satellite view via raw params
);
```

## Example — Bottom Sheet Picker

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapPickerSheet extends StatelessWidget {
  final LocationCoords destination;
  final String title;

  const MapPickerSheet({
    required this.destination,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final request = MapLauncher.marker(destination);

    return FutureBuilder<List<SupportedMap>>(
      future: request.getSupportedMaps(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final maps = snapshot.data!;

        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final map in maps)
                  ListTile(
                    onTap: () => request.show(map: map.mapType),
                    title: Text(map.mapType.displayName),
                    leading: SvgPicture.asset(
                      map.mapType.icon,
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
    title: 'Gamla Stan',
  ),
);
```

## Known Issues

- On iOS it's possible to "delete" Apple Maps which actually just removes it from the home screen and does not actually delete it. Because of that Apple Maps will always show up as available on iOS. [More info](https://stackoverflow.com/questions/39603120/how-to-check-if-apple-maps-is-installed)

## Contributing

Pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions and guidelines.
