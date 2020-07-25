import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

void main() => runApp(MapLauncherDemo());

class MapLauncherDemo extends StatefulWidget {
  @override
  _MapLauncherDemoState createState() => _MapLauncherDemoState();
}

enum LaunchMode { marker, directions }

class _MapLauncherDemoState extends State<MapLauncherDemo> {
  LaunchMode _launchMode = LaunchMode.marker;

  openMapsSheet(context) async {
    try {
      final title = "Shanghai Tower";
      final description = "Asia's tallest building";
      final coords = Coords(31.233568, 121.505504);
      final availableMaps = await MapLauncher.installedMaps;

      print(availableMaps);

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: <Widget>[
                      Text('Launch Mode: '),
                      Spacer(),
                      Row(
                        children: <Widget>[
                          Text('Marker'),
                          Radio(
                            value: LaunchMode.marker,
                            groupValue: _launchMode,
                            onChanged: (LaunchMode value) {
                              setState(() {
                                _launchMode = value;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: <Widget>[
                          Text('Directions'),
                          Radio(
                            value: LaunchMode.directions,
                            groupValue: _launchMode,
                            onChanged: (LaunchMode value) {
                              setState(() {
                                _launchMode = value;
                              });
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Wrap(
                        children: <Widget>[
                          for (var map in availableMaps)
                            ListTile(
                              onTap: () {
                                if (_launchMode == LaunchMode.directions) {
                                  map.showDirections(
                                    destination: coords,
                                    destinationTitle: 'My Cool Destination',
                                    origin: Coords(31.234518, 121.505604),
                                    originTitle: 'My Cool Origin',
                                    directionsMode: DirectionsMode.driving,
                                  );
                                } else {
                                  map.showMarker(
                                    coords: coords,
                                    title: title,
                                    description: description,
                                  );
                                }
                              },
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
                ),
              ],
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
