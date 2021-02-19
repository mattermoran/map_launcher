# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher.svg)](https://pub.dartlang.org/packages/map_launcher)
[![likes](https://badges.bar/map_launcher/likes)](https://pub.dev/packages/map_launcher/score)
[![popularity](https://badges.bar/map_launcher/popularity)](https://pub.dev/packages/map_launcher/score)
[![pub points](https://badges.bar/map_launcher/pub%20points)](https://pub.dev/packages/map_launcher/score)
[![GitHub stars](https://img.shields.io/github/stars/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/mattermoran/map_launcher?logo=github)](https://github.com/mattermoran/map_launcher/network)

Map Launcher is a flutter plugin to find available maps installed on a device and launch them with a marker or show directions.

|                                Marker                                 |                                Navigation                                 |
| :-------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| ![Marker](https://media.giphy.com/media/YNE1A6jrQQx4fArqKb/giphy.gif) | ![Navigation](https://media.giphy.com/media/gKIAdlbEzTDl6n7IOS/giphy.gif) |

Currently supported maps:
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.svg" width="25"> Google Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/apple.svg" width="25"> Apple Maps (iOS only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.svg" width="25"> Google Maps GO (Android only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/baidu.svg" width="25"> Baidu Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/amap.svg" width="25"> Amap (Gaode Maps)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/waze.svg" width="25"> Waze
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexMaps.svg" width="25"> Yandex Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexNavi.svg" width="25"> Yandex Navigator
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/citymapper.svg" width="25"> Citymapper
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.svg" width="25"> Maps.me
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.svg" width="25"> OsmAnd
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/doubleGis.svg" width="25"> 2GIS
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tencent.svg" width="25"> Tencent (QQ Maps)

## Migrating to v1

Breaking change: map_launcher does not depend on flutter_svg anymore which means you will have to add flutter_svg in your project if you want to use images.

This should allow you to use any version of flutter_svg and it also fixes bunch of issues related to that like [#45](https://github.com/mattermoran/map_launcher/issues/45), [#40](https://github.com/mattermoran/map_launcher/issues/40), etc

The `icon` property from `AvailableMap` now returns `String` instead of `ImageProvider` so to get it working all you have to do is to go from

```dart
Image(
  image: map.icon,
)
```

to

```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  map.icon,
)
```

## Get started

### Add dependency

```yaml
dependencies:
  map_launcher: ^2.0.0-nullsafety
  flutter_svg: # only if you want to use icons as they are svgs
```

### For iOS add url schemes in Info.plist file

```
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
</array>
```

## Usage

### Get list of installed maps and launch first

```dart
import 'package:map_launcher/map_launcher.dart';

final availableMaps = await MapLauncher.installedMaps;
print(availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

await availableMaps.first.showMarker(
  coords: Coords(37.759392, -122.5107336),
  title: "Ocean Beach",
);

```

### Check if map is installed and launch it

```dart
import 'package:map_launcher/map_launcher.dart';

if (await MapLauncher.isMapAvailable(MapType.google)) {
  await MapLauncher.showMarker(
    mapType: MapType.google,
    coords: coords,
    title: title,
    description: description,
  );
}

```

## API

### Show Marker

| option        | type                  | required | default |
| ------------- | --------------------- | -------- | ------- |
| `mapType`     | `MapType`             | yes      | -       |
| `coords`      | `Coords(lat, long)`   | yes      | -       |
| `title`       | `String`              | no       | `''`    |
| `description` | `String`              | no       | `''`    |
| `zoom`        | `Int`                 | no       | 16      |
| `extraParams` | `Map<String, String>` | no       | `{}`    |

##### Maps

| `mapType`     | `coords`                                                                 | `title`                                        | `description` | `zoom`       | `extraParams` |
| ------------- | ------------------------------------------------------------------------ | ---------------------------------------------- | ------------- | ------------ | ------------- |
| `.google`     | ✓                                                                        | iOS only <br /> see Known Issues section below | ✗             | ✓            | ✓             |
| `.apple`      | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.googleGo`   | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.amap`       | ✓                                                                        | ✓                                              | ✓             | Android only | ✓             |
| `.baidu`      | ✓                                                                        | ✓                                              | ✓             | ✓            | ✓             |
| `.waze`       | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.yandexMaps` | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.yandexNavi` | ✓                                                                        | ✓                                              | ✗             | ✓            | ✓             |
| `.citymapper` | ✓ <br /> does not support marker <br /> shows directions instead         | ✓                                              | ✗             | ✗            | ✓             |
| `.mapswithme` | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.osmand`     | ✓                                                                        | iOS only                                       | ✗             | Android only | ✓             |
| `.doubleGis`  | ✓ <br /> android does not support marker <br /> shows directions instead | ✗                                              | ✗             | ✗            | ✓             |
| `.tencent`    | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |

### Show Directions

| option             | type                      | required | default          |
| ------------------ | ------------------------- | -------- | ---------------- |
| `mapType`          | `MapType`                 | yes      | -                |
| `destination`      | `Coords(lat, long)`       | yes      | -                |
| `destinationTitle` | `String`                  | no       | `'Destination'`  |
| `origin`           | `Coords(lat, long)`       | no       | Current Location |
| `originTitle`      | `String`                  | no       | `'Origin'`       |
| `directionsMode`   | `DirectionsMode`          | no       | `.driving`       |
| `waypoints`        | `List<Coords(lat, long)>` | no       | `null`           |
| `extraParams`      | `Map<String, String>`     | no       | `{}`             |

##### Maps

| `mapType`     | `destination` | `destinationTitle` | `origin`                     | `originTitle` | `directionsMode` | `waypoints`                                  | `extraParams` |
| ------------- | ------------- | ------------------ | ---------------------------- | ------------- | ---------------- | -------------------------------------------- | ------------- |
| `.google`     | ✓             | ✗                  | ✓                            | ✗             | ✓                | ✓ (up to 8 on iOS and unlimited? on android) | ✓             |
| `.apple`      | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.googleGo`   | ✓             | ✗                  | ✓                            | ✗             | ✓                | ✓                                            | ✓             |
| `.amap`       | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.baidu`      | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.waze`       | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.yandexMaps` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.yandexNavi` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.citymapper` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.mapswithme` | ✓             | ✓                  | only shows marker            | ✗             | ✗                | ✗                                            | ✓             |
| `.osmand`     | ✓             | iOS only           | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.doubleGis`  | ✓             | ✗                  | ✓                            | ✗             | ✗                | ✗                                            | ✓             |
| `.tencent`    | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |


### Extra Params
It's possible to pass some map specific query params like api keys etc using `extraParams` option

Here are known params for some maps:

| `mapType`          | `extraParams`                             |
| ------------------ | ----------------------------------------- |
| `.tencent`         | `{ 'referer': '' }`                       |
| `.yandexNavi`      | `{ 'client': '', 'signature': '' }`       |

## Example

### Using with bottom sheet

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MapLauncherDemo());

class MapLauncherDemo extends StatelessWidget {
  openMapsSheet(context) async {
    try {
      final coords = Coords(37.759392, -122.5107336);
      final title = "Ocean Beach";
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Launcher Demo'),
        ),
        body: Center(child: Builder(
          builder: (context) {
            return MaterialButton(
              onPressed: () => openMapsSheet(context),
              child: Text('Show Maps'),
            );
          },
        )),
      ),
    );
  }
}
```

## Known issues

- Google Maps for Android have a bug that setting label for a marker doesn't work. See more on [Google Issue Tracker](https://issuetracker.google.com/issues/129726279)

- On iOS it's possible to "delete" Apple Maps which actually just removes it from homescreen and does not actually delete it. Because of that Apple Maps will always show up as available on iOS. You can read more about it [here](https://stackoverflow.com/questions/39603120/how-to-check-if-apple-maps-is-installed)

## Contributing

Pull requests are welcome.
