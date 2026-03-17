import 'package:map_launcher/map_launcher.dart';

abstract final class DemoData {
  static final destination = LocationCoords(
    48.8584,
    2.2945,
    title: 'Eiffel Tower',
  );
  static final origin = LocationCoords(48.8606, 2.3376, title: 'Louvre Museum');
}
