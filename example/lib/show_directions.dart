import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher_example/maps_sheet.dart';

class ShowDirections extends StatefulWidget {
  const ShowDirections({super.key});

  @override
  State<ShowDirections> createState() => _ShowDirectionsState();
}

class _ShowDirectionsState extends State<ShowDirections> {
  double destinationLatitude = 37.759392;
  double destinationLongitude = -122.5107336;
  String destinationTitle = 'Ocean Beach';

  double originLatitude = 37.8078513;
  double originLongitude = -122.404604;
  String originTitle = 'Pier 33';

  List<Waypoint> waypoints = [
    Waypoint(37.7705112, -122.4108267),
  ];

  DirectionsMode directionsMode = DirectionsMode.driving;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            const FormTitle('Destination'),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration:
                  const InputDecoration(labelText: 'Destination Latitude'),
              initialValue: destinationLatitude.toString(),
              onChanged: (newValue) {
                setState(() {
                  destinationLatitude = double.tryParse(newValue) ?? 0;
                });
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration:
                  const InputDecoration(labelText: 'Destination Longitude'),
              initialValue: destinationLongitude.toString(),
              onChanged: (newValue) {
                setState(() {
                  destinationLongitude = double.tryParse(newValue) ?? 0;
                });
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(labelText: 'Destination Title'),
              initialValue: destinationTitle,
              onChanged: (newValue) {
                setState(() {
                  destinationTitle = newValue;
                });
              },
            ),
            const FormTitle('Origin'),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(
                labelText: 'Origin Latitude (uses current location if empty)',
              ),
              initialValue: originLatitude.toString(),
              onChanged: (newValue) {
                setState(() {
                  originLatitude = double.tryParse(newValue) ?? 0;
                });
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(
                labelText: 'Origin Longitude (uses current location if empty)',
              ),
              initialValue: originLongitude.toString(),
              onChanged: (newValue) {
                setState(() {
                  originLongitude = double.tryParse(newValue) ?? 0;
                });
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: const InputDecoration(labelText: 'Origin Title'),
              initialValue: originTitle,
              onChanged: (newValue) {
                setState(() {
                  originTitle = newValue;
                });
              },
            ),
            WaypointsForm(
              waypoints: waypoints,
              onWaypointsUpdated: (updatedWaypoints) {
                setState(() {
                  waypoints = updatedWaypoints;
                });
              },
            ),
            const FormTitle('Directions Mode'),
            Container(
              alignment: Alignment.centerLeft,
              child: DropdownButton(
                value: directionsMode,
                onChanged: (newValue) {
                  setState(() {
                    directionsMode = newValue as DirectionsMode;
                  });
                },
                items: DirectionsMode.values.map((directionsMode) {
                  return DropdownMenuItem(
                    value: directionsMode,
                    child: Text(directionsMode.toString()),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                MapsSheet.show(
                  context: context,
                  onMapTap: (map) {
                    map.showDirections(
                      destination: Coords(
                        destinationLatitude,
                        destinationLongitude,
                      ),
                      destinationTitle: destinationTitle,
                      origin: Coords(originLatitude, originLongitude),
                      originTitle: originTitle,
                      waypoints: waypoints,
                      directionsMode: directionsMode,
                    );
                  },
                );
              },
              child: const Text('Show Maps'),
            )
          ],
        ),
      ),
    );
  }
}

class FormTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const FormTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}

class WaypointsForm extends StatelessWidget {
  final List<Waypoint> waypoints;
  final void Function(List<Waypoint> waypoints) onWaypointsUpdated;

  const WaypointsForm({
    super.key,
    required this.waypoints,
    required this.onWaypointsUpdated,
  });

  void updateWaypoint(Waypoint waypoint, int index) {
    final tempWaypoints = [...waypoints];
    tempWaypoints[index] = waypoint;
    onWaypointsUpdated(tempWaypoints);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...waypoints.map((waypoint) {
          final waypointIndex = waypoints.indexOf(waypoint);
          return [
            FormTitle(
              'Waypoint #${waypointIndex + 1}',
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red[300]),
                onPressed: () {
                  onWaypointsUpdated([...waypoints]..removeAt(waypointIndex));
                },
              ),
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: InputDecoration(
                labelText: 'Waypoint #${waypointIndex + 1} latitude',
              ),
              initialValue: waypoint.latitude.toString(),
              onChanged: (newValue) {
                updateWaypoint(
                  Waypoint(
                    double.tryParse(newValue) ?? 0,
                    waypoint.longitude,
                    waypoint.title,
                  ),
                  waypointIndex,
                );
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: InputDecoration(
                labelText: 'Waypoint #${waypointIndex + 1} longitude',
              ),
              initialValue: waypoint.longitude.toString(),
              onChanged: (newValue) {
                updateWaypoint(
                  Waypoint(
                    waypoint.latitude,
                    double.tryParse(newValue) ?? 0,
                    waypoint.title,
                  ),
                  waypointIndex,
                );
              },
            ),
            TextFormField(
              autocorrect: false,
              autovalidateMode: AutovalidateMode.disabled,
              decoration: InputDecoration(
                labelText: 'Waypoint #${waypointIndex + 1} title',
              ),
              initialValue: waypoint.title,
              onChanged: (newValue) {
                updateWaypoint(
                  Waypoint(waypoint.latitude, waypoint.longitude, newValue),
                  waypointIndex,
                );
              },
            ),
          ];
        }).expand((element) => element),
        const SizedBox(height: 20),
        Row(children: [
          MaterialButton(
            child: const Text(
              'Add Waypoint',
              style: TextStyle(
                // color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              onWaypointsUpdated([...waypoints, Waypoint(0, 0)]);
            },
          ),
        ]),
      ],
    );
  }
}
