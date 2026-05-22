import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';
import '../cubits/player_cubit.dart';
import '../cubits/stations_cubit.dart';
import '../cubits/theme_cubit.dart';
import '../widgets/player_bar.dart';
import '../widgets/station_tile.dart';
import 'about_page.dart';
import 'settings_page.dart';

/// Main screen with two tabs: All Stations and Favourites.
/// Handles real-time search (400 ms debounce), theme toggling, and navigation
/// to [SettingsPage]. Reloads the station list when returning from Settings
/// so any restored station reappears immediately.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  bool _showSearch = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<StationsCubit>().loadStations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<StationsCubit>().loadStations(query: query.trim());
    });
  }

  Future<void> _openAbout(BuildContext context, {Widget page = const AboutPage()}) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          final slideOut = Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(1, 0),
          ).animate(CurvedAnimation(
              parent: secondaryAnimation, curve: Curves.easeInOut));
          return SlideTransition(
            position: slideOut,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  void _closeSearch() {
    _debounce?.cancel();
    setState(() => _showSearch = false);
    _searchController.clear();
    context.read<StationsCubit>().loadStations();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerCubit, RadioPlayerState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(state.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: _showSearch
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search stations...',
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                )
              : BlocBuilder<StationsCubit, StationsState>(
                  builder: (context, state) {
                    final count =
                        state is StationsLoaded ? state.stations.length : null;
                    return _TitleButton(
                      count: count,
                      onTap: () => _openAbout(context),
                    );
                  },
                ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.radio), text: 'All Stations'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                final cubit = context.read<StationsCubit>();
                _openAbout(context, page: const SettingsPage())
                    .then((_) => cubit.loadStations());
              },
            ),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) => IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () => context.read<ThemeCubit>().toggle(),
              ),
            ),
            if (_showSearch)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: _closeSearch,
              )
            else
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _showSearch = true),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_StationsTab(), _FavoritesTab()],
              ),
            ),
            BlocBuilder<PlayerCubit, RadioPlayerState>(
              buildWhen: (prev, curr) =>
                  (prev.currentStation == null) !=
                  (curr.currentStation == null),
              builder: (context, state) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: state.currentStation != null
                    ? const PlayerBar(key: ValueKey('bar'))
                    : const SizedBox.shrink(key: ValueKey('none')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleButton extends StatefulWidget {
  final int? count;
  final VoidCallback onTap;

  const _TitleButton({required this.count, required this.onTap});

  @override
  State<_TitleButton> createState() => _TitleButtonState();
}

class _TitleButtonState extends State<_TitleButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _pressed
              ? color.withValues(alpha: 0.05)
              : Colors.transparent,
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.06),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
          border: Border.all(
            color: color.withValues(alpha: _pressed ? 0.0 : 0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.more_vert, size: 16, color: color.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Play jugomo 📻',
                    style: TextStyle(fontSize: 18)),
                if (widget.count != null)
                  Text(
                    '${widget.count} stations',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationsCubit, StationsState>(
      builder: (context, state) {
        if (state is StationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StationsError) {
          return _ErrorView(
            message: state.message,
            onRetry: () => context.read<StationsCubit>().loadStations(),
          );
        }
        if (state is StationsLoaded) {
          if (state.stations.isEmpty) {
            return const _EmptyView(
              message: 'No stations found. Try a different search.',
            );
          }
          return _StationList(
            stations: state.stations,
            onRefresh: () => context.read<StationsCubit>().loadStations(),
            isSearching: state.isSearching,
            permanentIds: state.permanentIds,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationsCubit, StationsState>(
      builder: (context, state) {
        if (state is StationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is StationsLoaded) {
          if (state.favorites.isEmpty) {
            return const _EmptyView(
              message:
                  'No favorites yet.\nTap the heart icon on a station to save it.',
              icon: Icons.favorite_border,
            );
          }
          return _StationList(
            stations: state.favorites,
            onRefresh: () =>
                context.read<StationsCubit>().loadStations(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Scrollable list of stations with pull-to-refresh and swipe-to-ignore.
/// Swipe left (endToStart) to permanently hide a station via [StationsCubit.ignoreStation].
/// Shows a Save button on each item that is a search result not yet in the permanent list.
class _StationList extends StatelessWidget {
  final List<RadioStation> stations;
  final Future<void> Function() onRefresh;
  final bool isSearching;
  final Set<String> permanentIds;

  const _StationList({
    required this.stations,
    required this.onRefresh,
    this.isSearching = false,
    this.permanentIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: stations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final station = stations[index];
          final canSave =
              isSearching && !permanentIds.contains(station.id);
          return Dismissible(
            key: ValueKey(station.id),
            direction: DismissDirection.endToStart,
            background: const SizedBox.shrink(),
            secondaryBackground: Container(
              color: Colors.red.shade700,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, color: Colors.white),
                  SizedBox(height: 4),
                  Text('Ignore',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
            onDismissed: (_) =>
                context.read<StationsCubit>().ignoreStation(station),
            child: StationTile(
              station: station,
              index: index,
              showSaveButton: canSave,
              onSave: canSave
                  ? () => context.read<StationsCubit>().pinStation(station)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Failed to load stations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyView({required this.message, this.icon = Icons.search_off});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
