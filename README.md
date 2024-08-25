# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher)](https://pub.dartlang.org/packages/map_launcher)
[![likes](https://img.shields.io/pub/likes/map_launcher)](https://pub.dev/packages/map_launcher/score)
[![popularity](https://img.shields.io/pub/popularity/map_launcher)](https://pub.dev/packages/map_launcher/score)
[![pub points](https://img.shields.io/pub/points/map_launcher)](https://pub.dev/packages/map_launcher/score)
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
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapswithme.svg" width="25"> Maps.me (iOS only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmand.svg" width="25"> OsmAnd
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/osmandplus.svg" width="25"> OsmAnd+ (Android only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/doubleGis.svg" width="25"> 2GIS
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tencent.svg" width="25"> Tencent (QQ Maps)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/here.svg" width="25"> HERE WeGo
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/petal.svg" width="25"> Petal Maps (Android only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgo.svg" width="25"> TomTom Go
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tomtomgofleet.svg" width="25"> TomTom Go Fleet
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/copilot.svg" width="25"> CoPilot
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/flitsmeister.svg" width="25"> Flitsmeister (Android only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/truckmeister.svg" width="25"> Truckmeister (Android only)
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/sygicTruck.svg" width="25"> Sygic Truck
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/naver.svg" width="25"> Naver Map
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/kakao.svg" width="25"> KakaoMap
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/tmap.svg" width="25"> TMAP
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mapyCz.svg" width="25"> Mapy.cz
</br><img src="https://github.com/mattermoran/map_launcher/raw/master/assets/icons/mappls.svg" width="25"> Mappls MapmyIndia

## Get started

### Add dependency

```yaml
dependencies:
  map_launcher: ^3.5.0
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
    <string>here-location</string>
    <string>tomtomgo</string>
    <string>copilot</string>
    <string>com.sygic.aura</string>
    <string>nmap</string>
    <string>kakaomap</string>
    <string>tmap</string>
    <string>szn-mapy</string>
    <string>mappls</string>
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

| `mapType`       | `coords`                                                                 | `title`                                        | `description` | `zoom`       | `extraParams` |
|-----------------|--------------------------------------------------------------------------|------------------------------------------------|---------------|--------------|---------------|
| `.google`       | ✓                                                                        | iOS only <br /> see Known Issues section below | ✗             | ✓            | ✓             |
| `.apple`        | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.googleGo`     | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.amap`         | ✓                                                                        | ✓                                              | ✓             | Android only | ✓             |
| `.baidu`        | ✓                                                                        | ✓                                              | ✓             | ✓            | ✓             |
| `.waze`         | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.yandexMaps`   | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.yandexNavi`   | ✓                                                                        | ✓                                              | ✗             | ✓            | ✓             |
| `.citymapper`   | ✓ <br /> does not support marker <br /> shows directions instead         | ✓                                              | ✗             | ✗            | ✓             |
| `.mapswithme`   | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.osmand`       | ✓                                                                        | iOS only                                       | ✗             | ✓            | ✓             |
| `.osmandplus`   | ✓                                                                        | iOS only                                       | ✗             | ✓            | ✓             |
| `.doubleGis`    | ✓ <br /> android does not support marker <br /> shows directions instead | ✗                                              | ✗             | ✗            | ✓             |
| `.tencent`      | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.here`         | ✓                                                                        | ✓                                              | ✗             | ✓            | ✓             |
| `.petalMaps`    | ✓                                                                        | ✗                                              | ✗             | ✓            | ✓             |
| `.tomtomgo`     | ✓ <br /> iOS does not support marker <br /> shows directions instead     | ✗                                              | ✗             | ✗            | ✓             |
| `.copilot`      | ✓                                                                        | ✓                                              | ✗             | ✗            | ✓             |
| `.flitsmeister` | ✓ <br /> does not support marker <br /> shows directions instead         | ✗                                              | ✗             | ✗            | ✗             |
| `.truckmeister` | ✓ <br /> does not support marker <br /> shows directions instead         | ✗                                              | ✗             | ✗            | ✗             |
| `.sygicTruck`   | ✓ <br /> does not support marker <br /> shows directions instead         | ✗                                              | ✗             | ✗            | ✗             |
| `.mappls`       | ✓                                                                        | ✗                                              | ✗             | ✗            | ✗             |

### Show Directions

| option             | type                                 | required | default          |
| ------------------ | ------------------------------------ | -------- | ---------------- |
| `mapType`          | `MapType`                            | yes      | -                |
| `destination`      | `Coords(lat, long)`                  | yes      | -                |
| `destinationTitle` | `String`                             | no       | `'Destination'`  |
| `origin`           | `Coords(lat, long)`                  | no       | Current Location |
| `originTitle`      | `String`                             | no       | `'Origin'`       |
| `directionsMode`   | `DirectionsMode`                     | no       | `.driving`       |
| `waypoints`        | `List<Waypoint(lat, long, String?)>` | no       | `null`           |
| `extraParams`      | `Map<String, String>`                | no       | `{}`             |

##### Maps

| `mapType`       | `destination` | `destinationTitle` | `origin`                     | `originTitle` | `directionsMode` | `waypoints`                                  | `extraParams` |
|-----------------|---------------|--------------------|------------------------------|---------------|------------------|----------------------------------------------|---------------|
| `.google`       | ✓             | ✗                  | ✓                            | ✗             | ✓                | ✓ (up to 8 on iOS and unlimited? on android) | ✓             |
| `.apple`        | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✓                                            | ✓             |
| `.googleGo`     | ✓             | ✗                  | ✓                            | ✗             | ✓                | ✓                                            | ✓             |
| `.amap`         | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.baidu`        | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.waze`         | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.yandexMaps`   | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.yandexNavi`   | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.citymapper`   | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.mapswithme`   | ✓             | ✓                  | only shows marker            | ✗             | ✗                | ✗                                            | ✓             |
| `.osmand`       | ✓             | iOS only           | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.osmandplus`   | ✓             | iOS only           | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.doubleGis`    | ✓             | ✗                  | ✓                            | ✗             | ✗                | ✗                                            | ✓             |
| `.tencent`      | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.here`         | ✓             | ✗                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.petalMaps`    | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✗                                            | ✓             |
| `.tomtomgo`     | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.copilot`      | ✓             | ✓                  | always uses current location | ✗             | ✗                | ✗                                            | ✓             |
| `.flitsmeister` | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✗             |
| `.truckmeister` | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✗             |
| `.sygicTruck`   | ✓             | ✗                  | always uses current location | ✗             | ✗                | ✗                                            | ✗             |
| `.mappls`       | ✓             | ✓                  | ✓                            | ✓             | ✓                | ✓                                            | ✗             |

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

- *[Fixed in Google maps 11.12](https://issuetracker.google.com/issues/129726279#comment175)* Google Maps for Android have a bug that setting label for a marker doesn't work. See more on [Google Issue Tracker](https://issuetracker.google.com/issues/129726279)

- On iOS it's possible to "delete" Apple Maps which actually just removes it from homescreen and does not actually delete it. Because of that Apple Maps will always show up as available on iOS. You can read more about it [here](https://stackoverflow.com/questions/39603120/how-to-check-if-apple-maps-is-installed)

## Contributing

Pull requests are welcome.
