import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/radio_station.dart';
import '../cubits/player_cubit.dart';
import '../cubits/stations_cubit.dart';

/// List item for a radio station. Shows the active playback state
/// and allows toggling the station as a favourite.
class StationTile extends StatelessWidget {
  final RadioStation station;

  const StationTile({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, RadioPlayerState>(
      builder: (context, playerState) {
        final isCurrentStation = playerState.currentStation?.id == station.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: _StationFavicon(favicon: station.favicon, isPlaying: isCurrentStation && playerState.isPlaying),
          title: Text(
            station.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isCurrentStation ? FontWeight.bold : FontWeight.normal,
              color: isCurrentStation ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          subtitle: Text(
            [station.country, station.tags].where((s) => s.isNotEmpty).join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentStation && playerState.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isCurrentStation)
                Icon(
                  playerState.isPlaying ? Icons.graphic_eq : Icons.pause,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  station.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: station.isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () {
                  context.read<StationsCubit>().toggleFavorite(station);
                },
              ),
            ],
          ),
          onTap: () {
            context.read<PlayerCubit>().play(station);
          },
        );
      },
    );
  }
}

class _StationFavicon extends StatelessWidget {
  final String favicon;
  final bool isPlaying;

  const _StationFavicon({required this.favicon, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: favicon.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    favicon,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.radio, size: 28),
                  ),
                )
              : const Icon(Icons.radio, size: 28),
        ),
        if (isPlaying)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            child: Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
      ],
    );
  }
}
