import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher_example/maps_sheet.dart';

class ShowDirections extends StatefulWidget {
  const ShowDirections({Key key}) : super(key: key);

  @override
  _ShowDirectionsState createState() => _ShowDirectionsState();
}

class _ShowDirectionsState extends State<ShowDirections> {
  double destinationLatitude = 37.759392;
  double destinationLongitude = -122.5107336;
  String destinationTitle = 'Ocean Beach';

  double originLatitude = 37.8078513;
  double originLongitude = -122.404604;
  String originTitle = 'Pier 33';

  DirectionsMode directionsMode = DirectionsMode.driving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Destination Latitude'),
            initialValue: destinationLatitude.toString(),
            onChanged: (newValue) {
              setState(() {
                destinationLatitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Destination Longitude'),
            initialValue: destinationLongitude.toString(),
            onChanged: (newValue) {
              setState(() {
                destinationLongitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Destination Title'),
            initialValue: destinationTitle,
            onChanged: (newValue) {
              setState(() {
                destinationTitle = newValue;
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(
              labelText: 'Origin Latitude (uses current location if empty)',
            ),
            initialValue: originLatitude.toString(),
            onChanged: (newValue) {
              setState(() {
                originLatitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(
              labelText: 'Origin Longitude (uses current location if empty)',
            ),
            initialValue: originLongitude.toString(),
            onChanged: (newValue) {
              setState(() {
                originLongitude = double.tryParse(newValue);
              });
            },
          ),
          TextFormField(
            autocorrect: false,
            autovalidate: false,
            decoration: InputDecoration(labelText: 'Origin Title'),
            initialValue: originTitle,
            onChanged: (newValue) {
              setState(() {
                originTitle = newValue;
              });
            },
          ),
          SizedBox(height: 5),
          Container(
            alignment: Alignment.centerLeft,
            child: DropdownButton(
              value: directionsMode,
              onChanged: (newValue) {
                setState(() {
                  directionsMode = newValue;
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
          SizedBox(height: 20),
          MaterialButton(
            onPressed: () {
              MapsSheet.show(
                context: context,
                onMapTap: (map) {
                  map.showDirections(
                    destination:
                        Coords(destinationLatitude, destinationLongitude),
                    destinationTitle: destinationTitle,
                    origin: Coords(originLatitude, originLongitude),
                    originTitle: originTitle,
                    directionsMode: directionsMode,
                  );
                },
              );
            },
            child: Text('Show Maps'),
          )
        ],
      ),
    );
  }
}
