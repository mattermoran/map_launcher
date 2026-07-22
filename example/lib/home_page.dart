import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:map_launcher/map_launcher_platform_interface.dart';

import 'demo_data.dart';

enum _MapStatus { installed, supported, notInstalled, notSupported }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  // Editable params
  double _destLat = DemoData.destination.lat;
  double _destLng = DemoData.destination.lng;
  String _destTitle = DemoData.destination.title ?? '';
  double _originLat = DemoData.origin.lat;
  double _originLng = DemoData.origin.lng;
  String _originTitle = DemoData.origin.title ?? '';
  TravelMode _travelMode = TravelMode.driving;
  String _searchQuery = 'Eiffel Tower';

  List<SupportedMap>? _allMaps;
  List<SupportedMap>? _markerMaps;
  List<SupportedMap>? _directionsMaps;
  List<SupportedMap>? _searchMaps;

  LocationCoords get _dest =>
      LocationCoords(_destLat, _destLng, title: _destTitle);
  LocationCoords get _origin =>
      LocationCoords(_originLat, _originLng, title: _originTitle);

  @override
  void initState() {
    super.initState();
    _loadMaps();
  }

  Future<void> _loadMaps() async {
    final all = await MapLauncher.getAvailableMaps();
    final marker = await MapLauncher.marker(_dest).getSupportedMaps();
    final directions = await MapLauncher.directions(
      _dest,
      from: _origin,
      mode: _travelMode,
    ).getSupportedMaps();
    final search = await MapLauncher.marker(
      LocationSearch(_searchQuery),
    ).getSupportedMaps();

    if (mounted) {
      setState(() {
        _allMaps = all;
        _markerMaps = marker;
        _directionsMaps = directions;
        _searchMaps = search;
      });
    }
  }

  String get _markerSubtitle =>
      '$_destTitle (${_destLat.toStringAsFixed(4)}, ${_destLng.toStringAsFixed(4)})';
  String get _directionsSubtitle =>
      '$_originTitle → $_destTitle · ${_travelMode.name}';
  String get _searchSubtitle => '"$_searchQuery"';


  List<_MapEntry> _entriesFor(List<SupportedMap>? supported) {
    final supportedSet =
        supported?.map((m) => m.mapType).toSet() ?? <MapType>{};
    final availableMap = {
      for (final m in _allMaps ?? <SupportedMap>[]) m.mapType: m,
    };

    final entries = MapType.values.map((mt) {
      final isSupported = supportedSet.contains(mt);
      final available = availableMap[mt];
      final isAvailable = available != null;
      final isInstalled = available?.isInstalled ?? false;

      final _MapStatus status;
      if (isSupported && isInstalled) {
        status = _MapStatus.installed;
      } else if (isSupported) {
        status = _MapStatus.supported;
      } else if (isAvailable) {
        status = _MapStatus.notSupported;
      } else {
        status = _MapStatus.notInstalled;
      }

      return _MapEntry(mapType: mt, status: status);
    }).toList();

    entries.sort((a, b) => a.status.index.compareTo(b.status.index));
    return entries;
  }


  String? _storeUrlFor(MapType mapType) => switch (defaultTargetPlatform) {
    .iOS || .macOS => mapType.appStoreUrl,
    .android => mapType.playStoreUrl,
    _ => mapType.appStoreUrl ?? mapType.playStoreUrl,
  };

  void _showInstallDialog(MapType mapType) {
    final storeUrl = _storeUrlFor(mapType);
    if (storeUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mapType.displayName),
        content: Text(
          '${mapType.displayName} is not installed. '
          'Would you like to open the store page?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              MapLauncherPlatform.instance.launch(storeUrl);
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _showOpenOrInstallSheet(MapType mapType, VoidCallback onOpen) {
    final storeUrl = _storeUrlFor(mapType);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const .symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const .only(left: 24, right: 24, bottom: 16),
                child: Text(
                  mapType.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Open in browser'),
                subtitle: const Text('Use universal link'),
                onTap: () {
                  Navigator.pop(context);
                  onOpen();
                },
              ),
              if (storeUrl != null)
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Install app'),
                  subtitle: const Text('Open store page'),
                  onTap: () {
                    Navigator.pop(context);
                    MapLauncherPlatform.instance.launch(storeUrl);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(_MapEntry entry, Future<void> Function() launch) {
    switch (entry.status) {
      case .installed:
        launch();
      case .supported:
        _showOpenOrInstallSheet(entry.mapType, launch);
      case .notInstalled:
        _showInstallDialog(entry.mapType);
      case .notSupported:
        break;
    }
  }


  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: .only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _EditForm(
          tab: _tab,
          destLat: _destLat,
          destLng: _destLng,
          destTitle: _destTitle,
          originLat: _originLat,
          originLng: _originLng,
          originTitle: _originTitle,
          travelMode: _travelMode,
          searchQuery: _searchQuery,
          onApply:
              ({
                required double destLat,
                required double destLng,
                required String destTitle,
                required double originLat,
                required double originLng,
                required String originTitle,
                required TravelMode travelMode,
                required String searchQuery,
              }) {
                setState(() {
                  _destLat = destLat;
                  _destLng = destLng;
                  _destTitle = destTitle;
                  _originLat = originLat;
                  _originLng = originLng;
                  _originTitle = originTitle;
                  _travelMode = travelMode;
                  _searchQuery = searchQuery;
                });
                _loadMaps();
              },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        _MapGrid(
          title: 'Marker',
          entries: _entriesFor(_markerMaps),
          subtitle: _markerSubtitle,
          loading: _allMaps == null,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () => MapLauncher.marker(_dest).show(map: entry.mapType),
          ),
        ),
        _MapGrid(
          title: 'Directions',
          entries: _entriesFor(_directionsMaps),
          subtitle: _directionsSubtitle,
          loading: _allMaps == null,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () => MapLauncher.directions(
              _dest,
              from: _origin,
              mode: _travelMode,
            ).show(map: entry.mapType),
          ),
        ),
        _MapGrid(
          title: 'Search',
          entries: _entriesFor(_searchMaps),
          subtitle: _searchSubtitle,
          loading: _allMaps == null,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () => MapLauncher.marker(
              LocationSearch(_searchQuery),
            ).show(map: entry.mapType),
          ),
        ),
        _MapGrid(
          title: 'Install',
          entries: MapType.values
              .map((mt) => _MapEntry(mapType: mt, status: _MapStatus.supported))
              .toList(),
          subtitle: 'Tap to open store page',
          loading: _allMaps == null,
          showInstallIcon: true,
          onTap: (entry) {
            final url = _storeUrlFor(entry.mapType);
            if (url != null) MapLauncherPlatform.instance.launch(url);
          },
        ),
      ][_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.pin_drop_outlined),
            selectedIcon: Icon(Icons.pin_drop),
            label: 'Marker',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_outlined),
            selectedIcon: Icon(Icons.directions),
            label: 'Directions',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Install',
          ),
        ],
      ),
    );
  }
}


class _MapEntry {
  const _MapEntry({required this.mapType, required this.status});
  final MapType mapType;
  final _MapStatus status;
}


class _MapGrid extends StatelessWidget {
  const _MapGrid({
    required this.title,
    required this.entries,
    required this.subtitle,
    required this.onTap,
    required this.loading,
    this.onEdit,
    this.showInstallIcon = false,
  });

  final String title;
  final List<_MapEntry> entries;
  final String subtitle;
  final void Function(_MapEntry entry) onTap;
  final bool loading;
  final VoidCallback? onEdit;
  final bool showInstallIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final usable = entries.where((e) => e.status != .notSupported).length;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Text(title),
          actions: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: 'Edit parameters',
                onPressed: onEdit,
              ),
          ],
        ),
        SliverPadding(
          padding: const .symmetric(horizontal: 16),
          sliver: SliverList.list(
            children: [
              Padding(
                padding: const .only(left: 4, bottom: 12),
                child: Text(
                  '$usable of ${entries.length} maps · $subtitle',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 500 ? 5 : 4;
                  final itemWidth =
                      (constraints.maxWidth - (crossAxisCount - 1) * 8) /
                      crossAxisCount;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entries.map((entry) {
                      final isTappable = entry.status != .notSupported;
                      return SizedBox(
                        width: itemWidth,
                        child: Opacity(
                          opacity: isTappable ? 1.0 : 0.35,
                          child: InkWell(
                            borderRadius: .circular(12),
                            onTap: isTappable ? () => onTap(entry) : null,
                            child: Padding(
                              padding: const .symmetric(
                                vertical: 8,
                                horizontal: 2,
                              ),
                              child: Column(
                                mainAxisSize: .min,
                                children: [
                                  SvgPicture.asset(
                                    entry.mapType.icon,
                                    height: 40,
                                    width: 40,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.mapType.displayName,
                                    textAlign: .center,
                                    maxLines: 2,
                                    overflow: .ellipsis,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (showInstallIcon)
                                    Icon(
                                      Icons.open_in_new,
                                      size: 12,
                                      color: colors.primary,
                                    )
                                  else
                                    _StatusLabel(status: entry.status),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}


class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final _MapStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9);

    return switch (status) {
      _MapStatus.installed => Text(
        'Installed',
        style: style?.copyWith(color: colors.primary),
      ),
      _MapStatus.supported => Text(
        'Universal',
        style: style?.copyWith(color: colors.outline),
      ),
      _MapStatus.notInstalled => Text(
        'Not installed',
        style: style?.copyWith(color: colors.error),
      ),
      _MapStatus.notSupported => const SizedBox.shrink(),
    };
  }
}


class _EditForm extends StatefulWidget {
  const _EditForm({
    required this.tab,
    required this.destLat,
    required this.destLng,
    required this.destTitle,
    required this.originLat,
    required this.originLng,
    required this.originTitle,
    required this.travelMode,
    required this.searchQuery,
    required this.onApply,
  });

  final int tab;
  final double destLat, destLng;
  final String destTitle;
  final double originLat, originLng;
  final String originTitle;
  final TravelMode travelMode;
  final String searchQuery;
  final void Function({
    required double destLat,
    required double destLng,
    required String destTitle,
    required double originLat,
    required double originLng,
    required String originTitle,
    required TravelMode travelMode,
    required String searchQuery,
  })
  onApply;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _destLatC;
  late final TextEditingController _destLngC;
  late final TextEditingController _destTitleC;
  late final TextEditingController _originLatC;
  late final TextEditingController _originLngC;
  late final TextEditingController _originTitleC;
  late final TextEditingController _searchC;
  late TravelMode _mode;

  @override
  void initState() {
    super.initState();
    _destLatC = TextEditingController(text: widget.destLat.toString());
    _destLngC = TextEditingController(text: widget.destLng.toString());
    _destTitleC = TextEditingController(text: widget.destTitle);
    _originLatC = TextEditingController(text: widget.originLat.toString());
    _originLngC = TextEditingController(text: widget.originLng.toString());
    _originTitleC = TextEditingController(text: widget.originTitle);
    _searchC = TextEditingController(text: widget.searchQuery);
    _mode = widget.travelMode;
  }

  @override
  void dispose() {
    _destLatC.dispose();
    _destLngC.dispose();
    _destTitleC.dispose();
    _originLatC.dispose();
    _originLngC.dispose();
    _originTitleC.dispose();
    _searchC.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onApply(
      destLat: double.tryParse(_destLatC.text) ?? widget.destLat,
      destLng: double.tryParse(_destLngC.text) ?? widget.destLng,
      destTitle: _destTitleC.text,
      originLat: double.tryParse(_originLatC.text) ?? widget.originLat,
      originLng: double.tryParse(_originLngC.text) ?? widget.originLng,
      originTitle: _originTitleC.text,
      travelMode: _mode,
      searchQuery: _searchC.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Edit Parameters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Marker + Directions: destination
            if (tab == 0 || tab == 1) ...[
              Text(
                tab == 1 ? 'Destination' : 'Location',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _destLatC,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _destLngC,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destTitleC,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],

            // Directions: origin + mode
            if (tab == 1) ...[
              const SizedBox(height: 20),
              Text('Origin', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _originLatC,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _originLngC,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _originTitleC,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TravelMode>(
                initialValue: _mode,
                decoration: const InputDecoration(
                  labelText: 'Travel Mode',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: TravelMode.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _mode = v);
                },
              ),
            ],

            // Search: query
            if (tab == 2) ...[
              TextField(
                controller: _searchC,
                decoration: const InputDecoration(
                  labelText: 'Search query',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],

            const SizedBox(height: 20),
            FilledButton(onPressed: _apply, child: const Text('Apply')),
          ],
        ),
      ),
    );
  }
}
