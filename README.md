# Map Launcher

[![pub package](https://img.shields.io/pub/v/map_launcher.svg)](https://pub.dartlang.org/packages/map_launcher)

Map Launcher is a flutter plugin to find available maps installed on a device and launch them with a marker for specified location.

![DEMO](https://media.giphy.com/media/dZ3h6sP5BaCaYm9VaC/giphy.gif)

Currently supported maps:
  - Google Maps
  - Baidu Maps
  - Amap (Gaode Maps)
  - Apple Maps (iOS only)


## Get started


### Add dependency

```yaml
dependencies:
  map_launcher: any
```

### For iOS add url schemes in Info.plist file

```plist
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>baidumap</string>
    <string>iosamap</string>
</array>
```


## Usage

### Basic example

```dart
import 'package:map_launcher/map_launcher.dart';

final availableMaps = await MapLauncher.installedMaps;
print(availableMaps); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

await availableMaps.first.showMarker(
  coords: Coords(31.233568, 121.505504),
  title: "Shanghai Tower",
  description: "Asia's tallest building",
);

```


### Example using bottom sheet

```dart
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

void main() => runApp(MapLauncherDemo());

class MapLauncherDemo extends StatelessWidget {
  openMapsSheet(context) async {
    try {
      final title = "Shanghai Tower";
      final description = "Asia's tallest building";
      final coords = Coords(31.233568, 121.505504);
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
                          description: description,
                        ),
                        title: Text(map.mapName),
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


## Contributing
Pull requests are welcome.