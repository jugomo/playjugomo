import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';
import '../cubits/player_cubit.dart';
import '../cubits/stations_cubit.dart';
import '../widgets/player_bar.dart';
import '../widgets/station_tile.dart';

/// Main screen with two tabs: all stations and favourites.
/// Shows playback errors via a [SnackBar].
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
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<StationsCubit>().loadStations(query: query.trim());
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
                  onSubmitted: _onSearch,
                )
              : const Text('Play jugomo 📻'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.radio), text: 'All Stations'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
            ],
          ),
          actions: [
            if (_showSearch)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _showSearch = false);
                  _searchController.clear();
                  context.read<StationsCubit>().loadStations();
                },
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
            const PlayerBar(),
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
          return _StationList(stations: state.stations);
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
          return _StationList(stations: state.favorites);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StationList extends StatelessWidget {
  final List<RadioStation> stations;

  const _StationList({required this.stations});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: stations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => StationTile(station: stations[index]),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
