import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/player_cubit.dart';

/// Persistent playback bar anchored to the bottom of the screen.
/// The volume row can be collapsed with the chevron button to save space.
/// Hidden (by the parent) when no station has been selected yet.
class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key});

  @override
  State<PlayerBar> createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
  bool _volumeExpanded = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, RadioPlayerState>(
      builder: (context, state) {
        if (state.currentStation == null) return const SizedBox.shrink();

        final cubit = context.read<PlayerCubit>();
        final station = state.currentStation!;
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.isLoading)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _favicon(station.favicon, context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            station.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (station.country.isNotEmpty)
                            Text(
                              station.country,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _volumeExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () =>
                          setState(() => _volumeExpanded = !_volumeExpanded),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      onPressed:
                          state.isLoading ? null : cubit.togglePlayPause,
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _volumeExpanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_down, size: 20),
                              onPressed: cubit.volumeDown,
                              visualDensity: VisualDensity.compact,
                            ),
                            Expanded(
                              child: Slider(
                                value: state.volume,
                                min: 0.0,
                                max: 1.0,
                                onChanged: cubit.setVolume,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 20),
                              onPressed: cubit.volumeUp,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _favicon(String url, BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: url.isNotEmpty
          ? ClipOval(
              child: Image.network(
                url,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.radio, size: 22),
              ),
            )
          : const Icon(Icons.radio, size: 22),
    );
  }
}
