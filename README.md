# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher.svg)](https://pub.dartlang.org/packages/map_launcher)

Map Launcher is a flutter plugin to find available maps installed on a device and launch them with a marker or show directions.

|                                Marker                                 |                                Navigation                                 |
| :-------------------------------------------------------------------: | :-----------------------------------------------------------------------: |
| ![Marker](https://media.giphy.com/media/YNE1A6jrQQx4fArqKb/giphy.gif) | ![Navigation](https://media.giphy.com/media/gKIAdlbEzTDl6n7IOS/giphy.gif) |

Currently supported maps:
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/google.svg" width="25"> Google Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/apple.svg" width="25"> Apple Maps (iOS only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/baidu.svg" width="25"> Baidu Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/amap.svg" width="25"> Amap (Gaode Maps)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/waze.svg" width="25"> Waze
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexMaps.svg" width="25"> Yandex Maps
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/yandexNavi.svg" width="25"> Yandex Navigator
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/citymapper.svg" width="25"> Citymapper
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.svg" width="25"> Maps.me
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.svg" width="25"> OsmAnd

## Get started

### Add dependency

```yaml
dependencies:
  map_launcher: ^0.11.0
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
    <string>mapsme</string>
    <string>osmandmaps</string>
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

| option        | type                | required | default |
| ------------- | ------------------- | -------- | ------- |
| `mapType`     | `MapType`           | yes      | -       |
| `coords`      | `Coords(lat, long)` | yes      | -       |
| `title`       | `String`            | no       | `''`    |
| `description` | `String`            | no       | `''`    |
| `zoom`        | `Int`               | no       | 16      |

##### Maps

| `mapType`     | `coords`                                                         | `title`                                        | `description` | `zoom`       |
| ------------- | ---------------------------------------------------------------- | ---------------------------------------------- | ------------- | ------------ |
| `.google`     | ✓                                                                | iOS only <br /> see Known Issues section below | ✗             | ✓            |
| `.apple`      | ✓                                                                | ✓                                              | ✗             | ✗            |
| `.amap`       | ✓                                                                | ✓                                              | ✓             | Android only |
| `.baidu`      | ✓                                                                | ✓                                              | ✓             | ✓            |
| `.waze`       | ✓                                                                | ✗                                              | ✗             | ✓            |
| `.yandexMaps` | ✓                                                                | ✗                                              | ✗             | ✓            |
| `.yandexNavi` | ✓                                                                | ✓                                              | ✗             | ✓            |
| `.citymapper` | ✓ <br /> does not support marker <br /> shows directions instead | ✓                                              | ✗             | ✗            |
| `.mapswithme` | ✓                                                                | ✓                                              | ✗             | ✗            |
| `.osmand`     | ✓                                                                | iOS only                                       | ✗             | Android only |

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

##### Maps

| `mapType`     | `destination` | `destinationTitle` | `origin`                     | `originTitle` | `directionsMode` | `waypoints` |
| ------------- | ------------- | ------------------ | ---------------------------- | ------------- | ---------------- | ----------- |
| `.google`     | ✓             | ✗                  | ✓                            | ✗             | ✓                | ✓           |
| `.apple`      | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.amap`       | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.baidu`      | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.waze`       | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗           |
| `.yandexMaps` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.yandexNavi` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.citymapper` | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗           |
| `.mapswithme` | ✓             | ✓                  | only shows marker            | ✗             | ✗                | ✗           |
| `.osmand`     | ✓             | iOS only           | always uses current location | ✗             | ✗                | ✗           |

## Example

### Using with bottom sheet

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

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
                        leading: Image(
                          image: map.icon,
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

## Contributing

Pull requests are welcome.
