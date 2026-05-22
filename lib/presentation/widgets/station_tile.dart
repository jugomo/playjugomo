import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/radio_station.dart';
import '../cubits/player_cubit.dart';
import '../cubits/stations_cubit.dart';

/// List item for a single radio station.
///
/// Shows the active playback state (equalizer animation, bold name, primary colour)
/// and lets the user toggle the favourite heart.
/// When [showSaveButton] is true (search result not yet in the permanent list),
/// the favourite button is replaced by a Save (playlist_add) button.
/// The optional [index] adds a retro-font row number before the avatar.
class StationTile extends StatelessWidget {
  final RadioStation station;
  final int? index;
  final bool showSaveButton;
  final VoidCallback? onSave;

  const StationTile({
    super.key,
    required this.station,
    this.index,
    this.showSaveButton = false,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, RadioPlayerState>(
      builder: (context, playerState) {
        final isCurrentStation = playerState.currentStation?.id == station.id;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index != null)
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${index! + 1}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.vt323(
                        fontSize: 20,
                        color: isCurrentStation
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                if (index != null) const SizedBox(width: 8),
                _StationFavicon(
                  favicon: station.favicon,
                  isPlaying: isCurrentStation && playerState.isPlaying,
                ),
              ],
            ),
          title: Text(
            station.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight:
                  isCurrentStation ? FontWeight.bold : FontWeight.normal,
              color: isCurrentStation
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          subtitle: _TagsRow(country: station.country, tags: station.tags),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSaveButton)
                IconButton(
                  icon: Icon(Icons.playlist_add,
                      color: Theme.of(context).colorScheme.primary),
                  tooltip: 'Add to list',
                  onPressed: onSave,
                )
              else ...[
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
                  onPressed: () =>
                      context.read<StationsCubit>().toggleFavorite(station),
                ),
              ],
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

class _TagsRow extends StatelessWidget {
  final String country;
  final String tags;

  const _TagsRow({required this.country, required this.tags});

  @override
  Widget build(BuildContext context) {
    final tagList = tags
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(2)
        .toList();

    final items = [
      if (country.isNotEmpty) country,
      ...tagList,
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Wrap(
        spacing: 4,
        runSpacing: 3,
        children: items.map((item) => _TagChip(label: item)).toList(),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: cs.onSurfaceVariant),
      ),
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
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          child: favicon.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    favicon,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.radio, size: 28),
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
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.65),
            ),
            child: const Center(child: _EqualizerBars()),
          ),
      ],
    );
  }
}

/// Three animated bars that simulate an equalizer graphic.
/// Each bar runs an independent [AnimationController] with a different duration
/// so they animate out of phase, giving a natural audio-reactive appearance.
class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars();

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350 + i * 120),
      )..repeat(reverse: true);
    });
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.25, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_animations),
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 4,
              height: 16 * _animations[i].value,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
