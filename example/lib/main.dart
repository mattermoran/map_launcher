import 'package:flutter/material.dart';
import 'package:map_launcher_example/show_directions.dart';
import 'package:map_launcher_example/show_marker.dart';

void main() => runApp(const MapLauncherDemo());

class MapLauncherDemo extends StatefulWidget {
  const MapLauncherDemo({super.key});

  @override
  State<MapLauncherDemo> createState() => _MapLauncherDemoState();
}

enum LaunchMode { marker, directions }

class _MapLauncherDemoState extends State<MapLauncherDemo> {
  int selectedTabIndex = 0;

  List<Widget> widgets = [const ShowMarker(), const ShowDirections()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Map Launcher Demo'),
        ),
        body: widgets[selectedTabIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedTabIndex,
          onTap: (newTabIndex) => setState(() {
            selectedTabIndex = newTabIndex;
          }),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.pin_drop),
              label: 'Marker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions),
              label: 'Directions',
            ),
          ],
        ),
      ),
    );
  }
}
