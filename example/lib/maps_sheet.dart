import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';

Future<void> showMapsSheet({
  required BuildContext context,
  required Function(AvailableMap map) onMapTap,
}) async {
  final maps = await MapLauncher.getInstalledMaps();
  // ignore: use_build_context_synchronously
  if (!context.mounted) return;

  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return MapsSheet(
        maps: maps,
        onMapTap: onMapTap,
      );
    },
  );
}

class MapsSheet extends StatelessWidget {
  const MapsSheet({
    super.key,
    required this.maps,
    required this.onMapTap,
  });

  final List<AvailableMap> maps;
  final Function(AvailableMap map) onMapTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.5,
          ),
          itemCount: maps.length,
          itemBuilder: (context, index) {
            final map = maps[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onMapTap(map),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: SvgPicture.asset(
                      map.icon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    map.mapName,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
