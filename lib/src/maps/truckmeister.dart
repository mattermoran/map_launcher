import 'package:map_launcher/src/maps/flitsmeister.dart';
import 'package:map_launcher/src/models/map_type.dart';

/// Truckmeister — traffic/navigation only.
class TruckmeisterBuilder extends FlitsmeisterBuilder {
  /// Creates a [TruckmeisterBuilder].
  const TruckmeisterBuilder();

  @override
  MapType get mapType => .truckmeister;

  @override
  String get scheme => 'truckmeister';
}
