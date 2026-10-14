import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';

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

  double _destLat = DemoData.destination.lat;
  double _destLng = DemoData.destination.lng;
  String _destTitle = DemoData.destination.title ?? '';
  double _originLat = DemoData.origin.lat;
  double _originLng = DemoData.origin.lng;
  String _originTitle = DemoData.origin.title ?? '';
  TravelMode _travelMode = TravelMode.driving;
  String _searchQuery = 'Eiffel Tower';

  List<AvailableMap>? _allMaps;
  List<SupportedMap>? _markerMaps;
  List<SupportedMap>? _directionsMaps;
  List<SupportedMap>? _searchMaps;
  Object? _loadError;
  int _loadGeneration = 0;

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
    final generation = ++_loadGeneration;
    setState(() {
      _allMaps = null;
      _markerMaps = null;
      _directionsMaps = null;
      _searchMaps = null;
      _loadError = null;
    });
    try {
      final all = await MapLauncher.getAvailableMaps(DemoData.maps);
      final marker = await MapLauncher.marker(_dest)
          .getSupportedMaps(DemoData.maps);
      final directions = await MapLauncher.directions(
        _dest,
        from: _origin,
        mode: _travelMode,
      ).getSupportedMaps(DemoData.maps);
      final search = await MapLauncher.marker(LocationSearch(_searchQuery))
          .getSupportedMaps(DemoData.maps);

      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _allMaps = all;
        _markerMaps = marker;
        _directionsMaps = directions;
        _searchMaps = search;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _loadError = error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not check available maps.'),
          action: SnackBarAction(label: 'Retry', onPressed: _loadMaps),
        ),
      );
    }
  }

  Future<void> _launch(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open the map. Please try again.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _launch(action),
          ),
        ),
      );
    }
  }

  String get _markerSubtitle =>
      '$_destTitle (${_destLat.toStringAsFixed(4)}, ${_destLng.toStringAsFixed(4)})';
  String get _directionsSubtitle =>
      '$_originTitle → $_destTitle · ${_travelMode.name}';
  String get _searchSubtitle => '"$_searchQuery"';

  List<_MapEntry> _entriesFor(List<SupportedMap>? supported) {
    final supportedIds = supported?.map((m) => m.map.id).toSet() ?? <String>{};
    final availableMap = {
      for (final m in _allMaps ?? <AvailableMap>[]) m.map.id: m,
    };

    final entries = DemoData.maps.map((mapApp) {
      final isSupported = supportedIds.contains(mapApp.id);
      final available = availableMap[mapApp.id];
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

      return _MapEntry(map: mapApp, status: status);
    }).toList();

    entries.sort((a, b) => a.status.index.compareTo(b.status.index));
    return entries;
  }

  String? _storeUrlFor(MapApp map) => switch (defaultTargetPlatform) {
    .iOS || .macOS => map.appStoreUrl,
    .android => map.playStoreUrl,
    _ => map.appStoreUrl ?? map.playStoreUrl,
  };

  void _showInstallDialog(MapApp map) {
    final storeUrl = _storeUrlFor(map);
    if (storeUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(map.name),
        content: Text(
          '${map.name} is not installed. '
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
              _launch(() => MapLauncherPlatform.instance.launch(storeUrl));
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  void _showOpenOrInstallSheet(MapApp map, Future<void> Function() onOpen) {
    final storeUrl = _storeUrlFor(map);

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
                  map.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Open in browser'),
                subtitle: const Text('Use universal link'),
                onTap: () {
                  Navigator.pop(context);
                  _launch(onOpen);
                },
              ),
              if (storeUrl != null)
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Install app'),
                  subtitle: const Text('Open store page'),
                  onTap: () {
                    Navigator.pop(context);
                    _launch(
                      () => MapLauncherPlatform.instance.launch(storeUrl),
                    );
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
        _launch(launch);
      case .supported:
        _showOpenOrInstallSheet(entry.map, launch);
      case .notInstalled:
        _showInstallDialog(entry.map);
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
          loadError: _loadError != null,
          onRetry: _loadMaps,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () => MapLauncher.marker(_dest).show(map: entry.map),
          ),
        ),
        _MapGrid(
          title: 'Directions',
          entries: _entriesFor(_directionsMaps),
          subtitle: _directionsSubtitle,
          loading: _allMaps == null,
          loadError: _loadError != null,
          onRetry: _loadMaps,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () => MapLauncher.directions(
              _dest,
              from: _origin,
              mode: _travelMode,
            ).show(map: entry.map),
          ),
        ),
        _MapGrid(
          title: 'Search',
          entries: _entriesFor(_searchMaps),
          subtitle: _searchSubtitle,
          loading: _allMaps == null,
          loadError: _loadError != null,
          onRetry: _loadMaps,
          onEdit: _showEditSheet,
          onTap: (entry) => _handleTap(
            entry,
            () =>
                MapLauncher.marker(LocationSearch(_searchQuery))
                    .show(map: entry.map),
          ),
        ),
        _MapGrid(
          title: 'Install',
          entries: DemoData.maps
              .map((m) => _MapEntry(map: m, status: _MapStatus.supported))
              .toList(),
          subtitle: 'Tap to open store page',
          loading: _allMaps == null,
          loadError: _loadError != null,
          onRetry: _loadMaps,
          showInstallIcon: true,
          onTap: (entry) {
            final url = _storeUrlFor(entry.map);
            if (url != null) {
              _launch(() => MapLauncherPlatform.instance.launch(url));
            }
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
  const _MapEntry({required this.map, required this.status});
  final MapApp map;
  final _MapStatus status;
}

class _MapGrid extends StatelessWidget {
  const _MapGrid({
    required this.title,
    required this.entries,
    required this.subtitle,
    required this.onTap,
    required this.loading,
    required this.loadError,
    required this.onRetry,
    this.onEdit,
    this.showInstallIcon = false,
  });

  final String title;
  final List<_MapEntry> entries;
  final String subtitle;
  final void Function(_MapEntry entry) onTap;
  final bool loading;
  final bool loadError;
  final VoidCallback onRetry;
  final VoidCallback? onEdit;
  final bool showInstallIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (loading) {
      if (loadError) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load available maps.'),
              const SizedBox(height: 8),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final usable = entries
        .where((e) => e.status == .installed || e.status == .supported)
        .length;

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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      entry.map.iconBytes,
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.map.name,
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
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) return;

    widget.onApply(
      destLat: double.parse(_destLatC.text),
      destLng: double.parse(_destLngC.text),
      destTitle: _destTitleC.text,
      originLat: double.parse(_originLatC.text),
      originLng: double.parse(_originLngC.text),
      originTitle: _originTitleC.text,
      travelMode: _mode,
      searchQuery: _searchC.text.trim(),
    );
    Navigator.pop(context);
  }

  String? _coordinateError(String? value, {required bool latitude}) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || !number.isFinite) return 'Enter a valid number';
    final limit = latitude ? 90 : 180;
    if (number < -limit || number > limit) {
      return latitude ? 'Must be -90 to 90' : 'Must be -180 to 180';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Parameters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              if (tab == 0 || tab == 1) ...[
                Text(
                  tab == 1 ? 'Destination' : 'Location',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _destLatC,
                        validator: (value) =>
                            _coordinateError(value, latitude: true),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _destLngC,
                        validator: (value) =>
                            _coordinateError(value, latitude: false),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
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

              if (tab == 1) ...[
                const SizedBox(height: 20),
                Text('Origin', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _originLatC,
                        validator: (value) =>
                            _coordinateError(value, latitude: true),
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _originLngC,
                        validator: (value) =>
                            _coordinateError(value, latitude: false),
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
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
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _mode = v);
                  },
                ),
              ],

              if (tab == 2) ...[
                TextFormField(
                  controller: _searchC,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a search query'
                      : null,
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
      ),
    );
  }
}
